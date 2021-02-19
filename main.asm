include "hardware.inc"



include "operations.asm"
include "rom.asm"
include "ram.asm"

section "header", ROM0[$100] ; Memory type ROM0 and the address where the section must be placed ($100)

entry_point: ; execution begins here
    di ; disable interrupts : we don't need interrupts 
    jp start ; leave this tiny space : execution starts at $100, but the header starts at $104

rept $150 - $104 ; Header spans $104 - $14F, but *rgbfix* sets the header for us
    db 0         ; So we set everything as 0
endr


    ; Kill rst vector $30 and replace it with jp hl. Now (rst $30) will do basically (call hl)
section "rstvectors", ROM0[$30]
  jp hl


section "main", ROM0[$150]

start:
    
include "init.asm"

.main_loop

    ; --------------------
    ; Fetch opcode
    ; --------------------
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
    ld a, b ; Store higher byte first
    ld [program_counter], a ; If anyone is wondering, (a) is the only 8bit register that can ld with memory
    ld a, c ; Store lower byte next
    ld [program_counter+1], a

    ; For testing, use opcode directly to try and run one of the string printing functions in operations.asm

    ; Multiply de by 2 to get the correct offset in the opcode table
    ld de, 1 ; Override opcode with manual value
    sla e    ; Because the opcode table is made of function addresses, each entry is 2 bytes -> multiply *de* by 2 to get the correct offset
    rl d     ; Rotate left through carry will use carry from the last operation
    ; Get function pointer from table address + offset
    ld hl, operations_table
    add hl, de
    ld a, [hli] ; Load lower byte of function address into (eventually) l
    ld e, a
    ld a, [hl]  ; Load upper byte of function addres in h
    ld h, a
    ld l, e     ; (hl) now has function address

    rst $30     ; Same as (call hl) bc of the small hack


    ; Set background palette
    ld a, %11100100 ; Palette: 11 10 01 00
    ld [rBGP], a

    ; Set scrolling
    xor a ; same as ld a, 0
    ld [rSCY], a ; Scroll Y = 0
    ld [rSCX], a ; Scroll X = 0

    ; Disable sound
    ld [rNR52], a

    ; Turn screen on, and turn background display on (bit 7 and bit 0)
    ld a, $81 ; $ identifies hexadecimal, so: 0x81 // 1000 0001
    ld [rLCDC], a

    ; trap in infinite loop to avoid issues
.lockup
    jr .lockup



section "font", ROM0

font_tiles:
incbin "font.chr" ; incbin tells RGBASM to copy the files into the produced ROM
font_tiles_end:


section "strings", ROM0

hello_world_str:
    db "Hello World!", 0 ; db copies data bytes, there's also dw for copy data words and dl for 32-bit longs

goodbye_world_str:
    db "Goodbye World!", 0 ; db copies data bytes, there's also dw for copy data words and dl for 32-bit longs
