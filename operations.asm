
section "operations", ROM0

; Macros : They are expanded each time, not called

; Advance PC: Takes 96 cycles and occupies 18 bytes
advance_program_counter: macro
    ld a, [program_counter]
    ld h, a
    ld a, [program_counter+1]
    ld l, a
    inc hl
    inc hl
    ld a, h
    ld [program_counter], a 
    ld a, l
    ld [program_counter+1], a
    endm

; Gets address of register Vx
; @param d -> holds index of register in the low 4 bits
; @return hl -> memory position (address) of register Vx
get_register_addr_x: macro
    ; Get register offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
    endm

; Functions

; TODO: Maybe make this a macro to reduce call overhead
; Gets value of Vx and Vy and address of Vx:
; @param de -> holds opcode $-xy-
; @return e -> value of Vy
; @return a -> value of Vx
; @return hl -> memory position of register Vx
get_registers_xy:
    ; Get value of second register
    ld hl, registers
    ; Get offset of second register in e by >>4
    ld a, e     
    swap a
    and $f
    ld c, a
    ld b, $0
    add hl, bc ; Register address + Vy offset
    ld a, [hl] ; Save register value to e
    ld e, a
    ; Get register Vx offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
    ; Load value of register to d
    ld a, [hl] ; Get register value
    ret

; Operations and Tables

operations_table:
    ; Define words because addressing is done with 16 bit in the gb
    dw _0_table
    dw _1_jp_addr
    dw _2_call_addr
    dw _3_se_vx_byte
    dw _4_sne_vx_byte
    dw _5_se_vx_vy
    dw _6_ld_vx_byte
    dw _7_add_vx_byte
    dw _8_table
    dw _9_sne_vx_vy
    dw _a_ld_i_addr
    dw _b_jp_v0_addr
    dw _c_rnd_vx_byte
    dw _d_drw_vx_vy_nibble
    dw _e_table
    dw _f_table

operations_8_table:
    dw _8xy0
    dw _8xy1
    dw _8xy2
    dw _8xy3
    dw _8xy4
    dw _8xy5
    dw _8xy6
    dw _8xy7
    dw _8xye


; For all operations,
; @param de - opcode

_0_table:

    ; 0 op can be $00E0 or $00EE
    ; Check low byte low nibble
    ld a, e
    and a; If e is 0, stop
    jr nz, .not_zero
    stop
.not_zero:
    cp $e0 ; Zero flag will be set if $00E0, and will not if $00EE
    jr z, ._00E0_CLS

    ; $00EE
    ; Sets the program counter to the top of the stack, then subtracts one from stack pointer
    ; Get stack address + offset
    ld hl, stack          ; Get address of stack
    ld a, [stack_pointer] ; Get stack pointer
    dec a                 ; Access top of stack -> stack[stack_pointer-1]
    sla a                 ; Each entry is 2 bytes so multiply offset by 2 (and will never exceed 8 bits)
    ld c, a
    ld b, $0
    add hl, bc  ; Address of stack + offset is now in hl
    ; Get program counter from stack and set it as actual program counter
    ld a, [hli] ; Get high byte of pc on top of stack
    ld [program_counter], a ; Set high byte of pc
    ld a, [hl]  ; Get low byte of pc on top of stack
    ld [program_counter+1], a     ; Set low byte of pc
    ; Finally, decrement the stack pointer
    ld hl, stack_pointer
    dec [hl]

    ld d, $0e
    ld d, d ; Debug message

    ret ; Return to execution

    ; $00E0
._00E0_CLS: ; Clear Screen

    ; TODO: Clear screen
    ; Disable LCD to access vram
    xor a; Set a to 0
    ld [rLCDC], a ; Set LCDC to 0, this will disable bit 7, consequently it will disable the display

    ; The font tiles are now set, now we write the tilemap
    ld hl, $9800 ; this will print the string at the top left corner of the screen
    ld de, goodbye_world_str
.copy_string:
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we copied is zero (and a, a will set zero flag if a is zero)
    jr nz, .copy_string ; Continue if it's not
    ld d, $00
    ld d, d ; Debug message

    ; Turn screen on, and turn background display on (bit 7 and bit 0)
    ld a, $81 ; $ identifies hexadecimal, so: 0x81 // 1000 0001
    ld [rLCDC], a

    ret ; Return to execution


_1_jp_addr:
    ; Set program counter to addr nnn
    ld a, d ; get high byte low nibble
    and $f
    ld [program_counter], a ; High byte is set first
    ld a, e ; get low byte
    ld [program_counter+1], a ; Set low byte next
    ld d, $01
    ld d, d ; Debug message
    ret ; Return and continue execution


_2_call_addr:
    ; Increment stack pointer, put program counter in stack, set program counter to addr nnn
    ; Get stack address + offset
    ld hl, stack          ; Get address of stack
    ld a, [stack_pointer] ; Get stack pointer
    sla a                 ; Each entry is 2 bytes so multiply offset by 2 (and will never exceed 8 bits)
    ld c, a
    ld b, $0
    add hl, bc  ; Address of stack + offset is now in hl
    ; Get current program counter and set it in stack
    ld a, [program_counter] ; Get high byte of PC
    ld [hli], a ; First set the high byte
    ld a, [program_counter+1] ; Get low byte of PC
    ld [hl], a  ; Then the low byte
    ; Increment stack pointer
    ld hl, stack_pointer
    inc [hl]
    ; Finally, set program_counter to addr nnn
    ld a, d ; get high byte low nibble
    and $f
    ld [program_counter], a ; High byte is set first
    ld a, e ; get low byte
    ld [program_counter+1], a ; Set low byte next
    ; ld d, $02
    ; ld d, d ; Debug message
    ret ; Return and continue execution


_3_se_vx_byte:  ; Skip if equal (Vx == byte)
    ; Get address of Vx
    get_register_addr_x ; Macro @return address of Vx in hl
    ld a, [hl] ; Load register value to a
    cp e       ; Compare register value to byte
    jr nz, .dont_skip_op
    ; Skip op (program counter += 2)
    advance_program_counter
.dont_skip_op:
    ld d, $03
    ld d, d ; Debug message
    ret


_4_sne_vx_byte: ; Skip if not equal (Vx != byte)
    ; Get address of Vx
    get_register_addr_x ; Macro @return address of Vx in hl
    ld a, [hl] ; Load register value to a
    cp e       ; Compare register value to byte
    jr z, .dont_skip_op
    ; Skip op (program counter += 2)
    advance_program_counter
.dont_skip_op:
    ld d, $04
    ld d, d ; Debug message
    ret


_5_se_vx_vy:    ; Skip if Vx == Vy (and last 4 bits are ignored)
    ; Get value of Vx and Vy
    call get_registers_xy ; @return e = Vy , @return a = Vx
    cp e       ; Compare register value to other register value
    jr nz, .dont_skip_op
    ; Skip op (program counter += 2)
    advance_program_counter
.dont_skip_op:
    ld d, $05
    ld d, d ; Debug message
    ret


_6_ld_vx_byte:  ; Vx = byte
    ; Get address of Vx
    get_register_addr_x ; Macro @return address of Vx in hl
    ; Load byte to register
    ld a, e ; Byte is in e
    ld [hl], a ; Save new value in Vx
    ; ld d, $06
    ; ld d, d ; Debug message
    ret


_7_add_vx_byte: ; Vx += byte
    ; Get address of Vx
    get_register_addr_x ; Macro @return address of Vx in hl
    ; Load value of register to a
    ld a, [hl]
    add e ; Add byte
    ld [hl], a
    ld d, $07
    ld d, d ; Debug message
    ret


_8_table:       ; Last 4 bits define operation
    ; Get address of function pointer in table
    ld a, e
    and $f  ; Get 4 bits that define the offset
    cp $9   ; There are only 8 entries, any index higher must be reduced
    jr nc, .use_last_op ; If a < 9, carry will be set, if a >= 9 carry won't be set, so use last op
    sla a   ; Multiply by 2 to get actual offset
    ld c, a
    ld b, $0 ; bc = offset
    ld hl, operations_8_table
    add hl, bc  ; hl = operations8 + offset
    ; Get address of function from table
    ld a, [hli] ; load low byte of address (since GB is little endian low byte comes first)
    ld c, a
    ld a, [hl]  ; Load upper byte of function addres in h
    ld h, a
    ld l, c     ; (hl) now has function address
    ; Jump to function
    jp hl
.use_last_op:
    jp _8xye



_9_sne_vx_vy:   ; Skip if Vx != Vy
    ; Get value of Vx and Vy and address of Vx
    call get_registers_xy ; @return e = Vy , @return a = Vx
    cp e ; Compare registers values
    jr z, .dont_skip_op
    ; Skip op (program counter += 2)
    advance_program_counter
.dont_skip_op:
    ld d, $09
    ld d, d ; Debug message
    ret


_a_ld_i_addr:   ; I = nnn
    ld a, d
    and $f  ; clear upper 4 bits of high byte
    ld [i_register], a
    ld a, e
    ld [i_register+1], a ; Set low byte of opcode in low byte of I register
    ; ld d, $0a
    ; ld d, d ; Debug message
    ret


_b_jp_v0_addr:  ; JP to nnn + V0
    ; Get value of V0, add to low byte of opcode and set low byte of pc
    ld a, [registers] ; V0 is in first position of registers
    add e ; Add value of low byte
    ld [program_counter+1], a ; Set low byte of pc
    ; Add to high 4 bits with carry to get high byte and set it in opcode
    ld a, $0 ; Can't do xor because it would reset the flags
    adc d    ; Add upper byte
    and $f   ; clear upper 4 bits (even if there were more, because the address space ends in xFFF)
    ld [program_counter], a ; Set low byte next
    ld d, $0b
    ld d, d ; Debug message
    ret ; Return and continue execution


_c_rnd_vx_byte: ; Vx = random byte AND (&) byte(kk)
    ; TODO: Randomize WRAM in Emulator

    ld d, $c ; Debug
    ld d, d
    ret

_d_drw_vx_vy_nibble: ; Draw

    ; Dxyn - DRW Vx, Vy, nibble
    ; Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.

    ; TODO:
    ; Save size of sprite in d
    ld a, e
    and $f
    ld d, a

    call get_registers_xy ; @return e value of Vy, @return a value of Vx, @return hl address of Vx

    ; Get address where to draw
    ld hl, _VRAM8800
    ; Divide Vx by 8 to get tile value (snap to grid) and multiply by 16 to get tile byte offset
    srl a
    srl a
    srl a
    sla a
    ; HL = _VRAM8800 + Vx Offset
    add l
    ld l, a
    ld a, 0 ; a = 0 without changing carry
    adc h ; a = h + carry
    ld h, a

    ; Calculate Vy offset
    ld a, e
    ; Get Y row offset by dividing by 8, get tile offset from start by multiplying row offset by number of tiles per row (x8) and then multiply by 16 to get byte offset: basically multiply by 16 = <<4
    ; / 8
    srl a
    srl a
    srl a
    ; * 8
    sla a
    sla a
    sla a
    ; * 16
    sla a
    sla a
    sla a
    sla a
    ; HL = _VRAM8800 + Vx offset + Y rows offset
    add l
    ld l, a
    ld a, 0 ; a = 0 without changing carry
    adc h
    ld h, a

    ; Get correct offset inside tile
    ld a, e ; a = Vy
    and $7  ; a = a % 8
    sla a   ; a *= 2 to get bytes offset
    ; HL = VRAM final address
    add l
    ld l, a
    ld a, 0 ; a = 0 without changing carry
    adc h
    ld h, a


    ; DE has d = size, e = y
    ld a, d
    ld [a_counter], a ; Save sprite size in counter
    xor a
    ld d, a ; D is now the number of lines drawn
    ; E has original Vy value

    ld bc, i_register

    ; Draw Addr = Base + Vx >> 3 * 16 + Vy >> 3 * 8 * 16 + Vy % 8 * 2

    halt ; It will halt until VBLANK bc it's the only enabled interrupt

    ; Disable LCDC to access VRAM
    xor a
    ld [rLCDC], a

.load_data:
    ; DE has D = Lines drawn, E = Vy
    push de ; Store these values
    ld a, [bc] ; Get byte from source (bc = i_register + offset)
    inc bc
    ld e, a  ; Byte from source in e
    ld a, [hli] ; Current screen value
    xor e    ; Xor with byte from source
    ld [hl], a ; Store it after XOR ( this is how the chip8 works screen = source ^ source)
    ; Assume the second byte had the same value as well because they should
    ld [hli], a ; Set two bytes equal to the value of the chip8 sprite byte, since gameboy uses 2 bit colors instead of 1
    pop de ; Use values again
    inc d ; Lines_drawn++
    ld a, [a_counter]
    dec a ; Drawed a line, keep drawing until all were drawn
    ld [a_counter], a
    jr z, .continue ; Stop when size has been used
    ; Has the offset changed ? If so we must add 8 * 16 more bytes to the VRAM offset :: If not, continue loading data

    ; Condition to change offset (y + linesdrawn != 0) && (y+linesdrawn % 8) == 0
    ld a, e ; a = Vy value
    add d   ; y + lines drawn != 0?
    jr z, .load_data ; if it's 0 continue loading, else if
    and $7 ; y+linesdrawn % 8
    jr nz, .load_data ; if it's 0 keep going to add the offset

    ; If the offset changed, load new offset number in e, and add a row of bytes to the offset and set the pointer to the top of the tile again by subtracting 16 (so just multiply by 14)
    ld a, 8*14
    ; Add offset to HL
    add l
    ld l, a
    ld a, $0
    adc h
    ld h, a
    jr .load_data

.continue
    ld d, $d ; Debug
    ld d, d

    ; Re-enable LCDC
    ld a, $81 ; $ identifies hexadecimal, so: 0x81 // 1000 0001
    ld [rLCDC], a
    ret

_e_table:

    ; TODO : CHECK IF WORKING INPUT?

    ; Code common to both tables
    ; Get value of inputs in c
    ld a, [input_register] ; Get input values
    ld c, a ; Store bit values to check later
    ; Get key to check
    get_register_addr_x ; @return hl with address of Vx
    ld a, [hl] ; Get Value of Vx
    cp $8 ; All Vx values above 7 need to be normalized ; TODO: This behaviour is a bit undefined bc i don't know if the keys can be mirrored like this
    jr c, .shift_until_value ; If a < 8 dont normalize and go directly to shifting
    ; Normalize 8-15 to 0-7
    sub $8
    ; Get correct location to check bit to see if is pressed
.shift_until_value:
    and $f ; Check if Vx value is 0
    jr z, .check_input_value
    srl c ; c has value of input_register, shift until the desired bit is in position 0
    dec a ; a has value of Vx decreasing until 0 to place the input bit we want to check in the rightmost position
    jr .shift_until_value
.check_input_value:
    ; C has the input bit we want to check in the rightmost position. Decide which function to run and then check that bit to skip the instruction

    ; Decide what function to run
    ld a, e ; Compare low byte to decide what function to run
    cp $9E
    jr nz, ._nextcase

    ; Ex9E
    ; Skip next instruction if key with value of Vx is pressed
    ld a, c ; C has the input bit we want to check
    and $1 ; Check rightmost bit
    jr nz, .skip_instruction ; Bit is 1 so it is pressed
    ret

._nextcase: ; Decide if to run function or run the default case
    cp $A1
    jr nz, ._defaultcase
    
    ; ExA1
    ; Skip next instruction if key with value of Vx is NOT pressed
    ld a, c ; C has the input bit we want to check
    and $1 ; Check rightmost bit
    jr z, .skip_instruction ; If the bit is 0 then it's NOT pressed so skip the next instruction
    ; If it's not just fallthrough to return with the default case below

._defaultcase: ; Default case - just return
    ret

; Code to skip instruction if it should happen
.skip_instruction:
    ; Skip instruction
    advance_program_counter ; macro
    ret


_f_table:

    ; Common code
    get_register_addr_x ; @param d with V index in lower nibble, @return hl with address of Vx

    ; Check which function to run
    ld a, e ; Compare low byte to decide what function to run
    cp $07
    jr nz, ._nextcase

    ; Fx07
    ; Set Vx to the delay timer value
    ld a, [delay_register]
    ld [hl], a ; hl has Vx address
    ret

._nextcase:
    cp $0A
    jr nz, ._nextcase_

    ; Fx0A
    ; Wait for a key press, store the value of the key in Vx
    xor a   ; a = 0
    ld b, a ; b = 0
    ldh [rIF], a ; Clear pending interrupt requests (ldh is used to access FF++)
    ; Assume that rIE always has VBLANK IRQ enabled
    ; inc a  ; a = 1
    ; ldh [rIE], a ; Enable VBLANK IRQ (bit 0 of IE) (VBLANK handler polls for input)
    ; dec a ; a = 0
    ld [input_register], a   ; Clear input register and expect any new input TODO: maybe i should just be looking for *new* inputs, not clear them all

.wait:
    halt ; Wait for VBLANK interrupt
    ; VBLANK Handler sets input_register with the keys pressed
    ld a, [input_register]  ; Load value of input register
    and a       ; Is a == 0?
    jr z, .wait ; If a is 0 wait more until its > 0 (meaning an input was pressed)
    ; Input was pressed - multiple can probably be pressed, so just detect the smallest and set it in Vx
.find_bit:
    sla a ; Keep shifting right until there's a carry out (meaning we found our bit) - if it's the first one the number is 0
    inc b ; Everytime we shift we increment b
    jr nc, .find_bit ; Until we find a bit
    dec b ; Because b is 1-16 and we want values 0-15
    ld a, b ; Store value in a and then into Vx
    ld [hl], a ; HL holds Vx because of the common code for the Fx table - store value of digit there
    ret

._nextcase_:
    cp $15
    jr nz, ._nextcase__

    ; Fx15
    ; Set delay timer to Vx
    ld a, [hl] ; hl has Vx
    ld [delay_register], a
    ret 

._nextcase__:
    cp $18
    jr nz, ._nextcase___

    ; Fx18
    ; Set sound timer = Vx
    ld a, [hl] ; hl has Vx address
    ld [sound_register], a
    ret

._nextcase___:
    cp $1E
    jr nz, ._nextcase____

    ; Fx1E
    ; I += Vx
    ld a, [hl] ; Load Vx value to c
    ld c, a
    ld a, [i_register+1] ; Load I low byte to a and add Vx to it
    add c
    ld [i_register+1], a
    ld a, [i_register]   ; Get high byte and add carry to it
    adc $0
    ld [i_register], a
    ret

._nextcase____:
    cp $29
    jr nz, ._nextcase_____

    ; Fx29
    ; Set I = Location of the hexdigit sprite index corresponding to the value of Vx
    ; Get Digit to display
    ; hl has address (get_register_x is common code to all)
    ld a, [hl] ; Hexdigit to draw in c
    ld c, a
    ld b, $0   ; bc has digit to draw
    ; Calculate offset of digit sprite (every sprite is 5 bytes long)
    ld hl, FONTSET_START_ADDRESS
    add hl, bc ; Add digit number offset * 5 times to get actual offset, because each sprite is 5 bytes long
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc
    ; Save address in I
    ld a, h
    ld [i_register], a
    ld a, l
    ld [i_register+1], a
    ret

._nextcase_____:
    cp $33
    jr nz, ._nextcase______

    ; Fx33
    ; Store BCD representation of Vx in memory locations specified by value of I, I+1, and I+2.
    ; TODO
    ret

._nextcase______:
    cp $55
    jr nz, ._nextcase_______

    ; Fx55
    ; LD [I], Vx - Store registers V0 through Vx in memory starting at location I
    ; Get memory referenced by I in bc
    ld hl, memory ; bc will have chip8 memory address 
    ld a, [i_register+1]
    ld c, a
    ld a, [i_register]
    ld b, a
    add hl, bc
    ld c, l
    ld b, h

    ld hl, registers
    ld a, d
    and $f ; Get Vx index
    inc a ; increment by one because Vx is including Vx
    ld d, a
.do_store:
    ld a, [hli] ; Load value of Vx to A and decrement pointer of Vx by 1 to access V(x-1) later (hl has address of Vx (see common code))
    ld [bc], a ; Store value of Vx in i_register
    inc bc  ; Access next position after I
    dec d ; d has Vx index going until 0
    jr nc, .do_store ; If bc overflows then we've loaded all Vx through V0
    ret

._nextcase_______:
    cp $65
    jr nz, ._defaultcase

    ; Fx65
    ; LD Vx, [I] - Read registers V0 through Vx from memory starting at location I

    ; Get memory referenced by I in bc
    ld hl, memory ; bc will have chip8 memory address 
    ld a, [i_register+1]
    ld c, a
    ld a, [i_register]
    ld b, a
    add hl, bc
    ld c, l
    ld b, h

    ld hl, registers
    ld a, d
    and $f ; Get Vx index
    inc a ; increment by one because Vx is including Vx
    ld d, a
.do_load:
    ld a, [bc] ; Load value of Vx to A and inc pointer of Vx by 1 to access V(x+1) late
    inc bc ; Access next position after I
    ld [hli], a ; Store value of Vx in i_register
    dec d ; d has Vx index going to 0
    jr nz, .do_load ; If bc overflows then we've loaded all Vx through V0
    ret

._defaultcase:
    ret 



_8xy0:  ; Ld Vx, Vy (Vx = Vy)
    ; Get value of Vy and address of Vx
    ; Call even tho i don't use Vx value -> This function has 48 extra cycles (call+ret+unnecessary op), but saves 21 bytes
    call get_registers_xy    
    ; Set value of Vy (that's in e) into Vx
    ld a, e
    ld [hl], a
    ld d, $80
    ld d, d ; Debug message
    ret


_8xy1:  ; OR Vx, Vy (Vx |= Vy)
    call get_registers_xy ; @param de, @return e, @return a, @return hl (see function below)
    or e       ; OR the register values
    ; Store value of OR into Vx
    ld [hl], a ; Store OR value in Vx
    ld d, $81
    ld d, d ; Debug message
    ret


_8xy2:  ; AND Vx, Vy (Vx &= Vy)
    call get_registers_xy
    and e       ; AND the register values
    ; Store value of AND into Vx
    ld [hl], a ; Store AND value in Vx
    ld d, $82
    ld d, d ; Debug message
    ret


_8xy3:  ; XOR Vx, Vy (Vx ^= Vy)
    call get_registers_xy
    xor e       ; XOR the register values
    ; Store value of XOR into Vx
    ld [hl], a ; Store XOR value in Vx
    ld d, $83
    ld d, d ; Debug message
    ret


_8xy4:  ; ADD Vx, Vy
    call get_registers_xy
    add e       ; ADD the register values
    ; Should set carry?
    ld c, l
    ld b, h ; Save hl
    ld hl, registers + $f ; Register VF
    jr nc, .set_no_carry
    ; Set the carry flag on
    set 0, [hl]
.store_val:
    ld l, c
    ld h, b ; Restore hl
    ; Store value of ADD into Vx
    ld [hl], a
    ld d, $84
    ld d, d ; Debug message
    ret
.set_no_carry:
    ; Reset the carry flag
    res 0, [hl]
    jr .store_val


_8xy5:  ; SUB Vx, Vy
    call get_registers_xy
    sub e       ; SUB the register values (Vx - Vy), Vx is in a, Vy in e
    ; Should set carry?
    ld c, l
    ld b, h ; Save hl
    ld hl, registers + $f ; Register VF
    jr nc, .set_no_carry
    ; Set the carry flag off
    res 0, [hl] ; For some reason CHIP8 does sets subtraction carry flag = NOT borrow
.store_val:
    ld l, c
    ld h, b ; Restore hl
    ; Store value of SUB into Vx
    ld [hl], a
    ld d, $85
    ld d, d ; Debug message
    ret
.set_no_carry:
    ; Set the carry flag on for NOT borrow
    set 0, [hl]
    jr .store_val


_8xy6:  ; SHR Vx (Vx >>= 1)
    ; Get register Vx offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
    ld a, [hl] ; a = Vx
    srl a
    ; Set the carry flag
    ld c, l
    ld b, h ; Save hl
    ld hl, registers + $f ; Register VF
    jr nc, .set_no_carry
    ; Set carry flag 
    set 0, [hl]
.store_val:
    ld l, c
    ld h, b ; Restore hl
    ; Store value of OR into Vx
    ld [hl], a ; Store OR value in Vx
    ld d, $86
    ld d, d ; Debug message
    ret
.set_no_carry:
    ; Reset the carry flag
    res 0, [hl]
    jr .store_val
    

_8xy7:  ; SUBN Vx, Vy (Vx = Vy - Vx)
    call get_registers_xy
    ; Invert Vy and Vx value
    ld c, e ; a, e = e, a
    ld e, a
    ld a, c
    sub e       ; SUB the register values (Vy - Vx)
    ; Should set carry?
    ld c, l
    ld b, h ; Save hl
    ld hl, registers + $f ; Register VF
    jr nc, .set_no_carry
    ; Set the carry flag off
    res 0, [hl] ; For some reason CHIP8 does sets subtraction carry flag = NOT borrow
.store_val:
    ld l, c
    ld h, b ; Restore hl
    ; Store value of SUB into Vx
    ld [hl], a
    ld d, $87
    ld d, d ; Debug message
    ret
.set_no_carry:
    ; Set the carry flag on for NOT borrow
    set 0, [hl]
    jr .store_val 


_8xye:  ; Vx <<= 1
    ; Get register Vx offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
    ld a, [hl] ; a = Vx
    sla a
    ; Set the carry flag
    ld c, l
    ld b, h ; Save hl
    ld hl, registers + $f ; Register VF
    jr nc, .set_no_carry
    ; Set carry flag 
    set 0, [hl]
.store_val:
    ld l, c
    ld h, b ; Restore hl
    ; Store value of OR into Vx
    ld [hl], a ; Store OR value in Vx
    ld d, $8e
    ld d, d ; Debug message
    ret
.set_no_carry:
    ; Reset the carry flag
    res 0, [hl]
    jr .store_val

