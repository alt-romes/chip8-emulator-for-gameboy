include "hardware.inc"

include "common.asm"

include "operations.asm"
include "rom.asm"
include "ram.asm"
include "interrupt_handlers.asm"

section "header", ROM0[$100] ; Memory type ROM0 and the address where the section must be placed ($100)

entry_point: ; execution begins here
    di ; disable interrupts : we don't need interrupts 
    jp start ; leave this tiny space : execution starts at $100, but the header starts at $104

rept $150 - $104 ; Header spans $104 - $14F, but *rgbfix* sets the header for us
    db 0         ; So we set everything as 0
endr


    ; Kill rst vector $30 and replace it with jp hl. Now (rst $30) will do basically (call hl)
section "rstvectors", ROM0[$30]
    ld b, b ; debug
    jp hl

section "vblank-handler", ROM0[$40]
    ; VBLANK Handler
    jp vblank_handler    

section "main", ROM0[$150]

start:

include "init.asm"

.main_loop

    ; Reset the number of cycles left in this frame 
    ld a, $8
    ld [cycles_left_in_frame], a ; Run 8 pseudo-cpu cycles every frame, only then halt and wait for VBLANK

.cycle
    ; Get program counter ( 2 bytes )
    ld a, [program_counter] ; Get the first (high) byte of the program counter
    ld b, a ; b has highest byte
    ld a, [program_counter+1] ; Fetch the second byte of the program counter
    ld c, a ; bc now has the program counter
    ; Add program counter to position of chip8's memory (bc + hl) to get physical address of chip8's current instruction
    ld hl, memory
    ; The following code is actually useless bc i could do add hl, bc ...
    add l   ; Add lower byte of memory position (l) to lower byte of the program counter
    ld l, a ; Set result in l
    ld a, b
    adc h   ; Add higher byte of memory position (h) to higher byte of program counter b + carry from previous addition
    ld h, a ; Set result in h. hl now has the memory address of the current memory address of chip8
    ; Fetch opcode ( 2 bytes ) from chip8's memory
    ld a, [hli] ; Get highest byte of opcode and store in d
    ld d, a
    ld a, [hl]  ; Get lower byte of opcode and store in e
    ld e, a     ; *de* now has the opcode

    ; Increment program counter by 2 (because each opcode is 2 bytes)
    inc bc
    inc bc
    ld a, b ; Store higher byte in the first byte of the program counter
    ld [program_counter], a ; If anyone is wondering, (a) is the only 8bit register that can ld with memory
    ld a, c ; Store lower byte in second byte of the program counter
    ld [program_counter+1], a

    ; Get the correct offset: check only the first 4 bits and multiply them by 2
    ; *de* has opcode, offset is the (first 4 bits of d)*2
    ld a, d ; c will have offset with a as an aux
    swap a
    and $f ; swap a and $f is shift a >> 4 to get first 4 bits but with less cycles
    ld c, a
    sla c ; Multiply by 2
    ld b, $0 ; bc now has offset

    ; Get function pointer from table address + offset
    ld hl, operations_table
    add hl, bc  ; address + offset
    ld a, [hli] ; Load lower byte of function address into c (and later l) (GB is little endian)
    ld c, a
    ld a, [hl]  ; Load upper byte of function addres in h
    ld h, a
    ld l, c     ; (hl) now has function address

    ; Call the function address stored in (hl) with *de* as the argument for the opcode
    rst $30     ; Same as (call hl) bc of the small hack added in section rstvectors


    ; Keep doing "cpu" cycles or halt and wait for the end of the frame (VBLANK)
    ld a, [cycles_left_in_frame]
    dec a ; It will set zero flag if a == 0
    ld [cycles_left_in_frame], a
    jr nz, .cycle ; If we have more cycles left this frame, do more cycles

    ; End cycles this frame
    halt ; Wait for VBLANK (it's the only enabled interrupt)
         ; VBLANK will process input
    
    ; Put sprite data in VRAM

    jp .main_loop



section "font", ROM0

font_tiles:
incbin "font.chr" ; incbin tells RGBASM to copy the files into the produced ROM
font_tiles_end:


section "strings", ROM0

hello_world_str:
    db "Hello World!", 0 ; db copies data bytes, there's also dw for copy data words and dl for 32-bit longs

goodbye_world_str:
    db "Goodbye World!", 0 ; db copies data bytes, there's also dw for copy data words and dl for 32-bit longs
