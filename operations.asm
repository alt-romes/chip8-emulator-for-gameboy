; Operations
section "operations", ROM0

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
    and $ff ; If e is 0, stop
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
    ld d, $02
    ld d, d ; Debug message
    ret ; Return and continue execution


_3_se_vx_byte:  ; Skip if equal (Vx == byte)
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number
    ld hl, registers
    ld c, a
    ld b, $0
    add hl, bc ; Registers address + offset
    ld a, [hl] ; Load register value to a
    cp e       ; Compare register value to byte
    jr nz, .dont_skip_op
    ; Skip op (program counter += 2)
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
.dont_skip_op:
    ld d, $03
    ld d, d ; Debug message
    ret


_4_sne_vx_byte: ; Skip if not equal (Vx != byte)
    ; This function is almost identical to the one above
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number
    ld hl, registers
    ld c, a
    ld b, $0
    add hl, bc ; Registers address + offset
    ld a, [hl] ; Load register value to a
    cp e       ; Compare register value to byte
    jr z, .dont_skip_op
    ; Skip op (program counter += 2)
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
.dont_skip_op:
    ld d, $04
    ld d, d ; Debug message
    ret


_5_se_vx_vy:    ; Skip if Vx == Vy (and last 4 bits are ignored) 
    ; Get offset for first register
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits
    ld c, a ; Save register number in c
    ; Get offset for second register
    ld a, e ; Low byte of opcode into a
    swap a  ; (These two lines are the same as >> 4)
    and $f  ; Get register number from high 4 bits
    ld e, a ; Save register number in e
    ; Get value of first register
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers address + Vx offset
    ld a, [hl] ; Save register value to c
    ld c, a
    ; Get value of second register
    ld hl, registers
    ; Get offset of second register in e by >>4
    ld a, e     
    swap a
    and $f
    ld e, a
    ld d, $0
    add hl, de ; Register address + Vy offset
    ld a, [hl] ; Save register value to a and compare with c
    cp c       ; Compare register value to other register value
    jr nz, .dont_skip_op
    ; Skip op (program counter += 2)
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
.dont_skip_op:
    ld d, $05
    ld d, d ; Debug message
    ret


_6_ld_vx_byte:  ; Vx = byte
    ; Get register offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
    ; Load byte to register
    ld a, e ; Byte is in e
    ld [hl], a
    ld d, $06
    ld d, d ; Debug message
    ret


_7_add_vx_byte: ; Vx += byte
    ; Get register offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
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
    ; Get offset for first register
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits
    ld c, a ; Save register number in c
    ; Get offset for second register
    ld a, e ; Low byte of opcode into a
    swap a  ; (These two lines are the same as >> 4)
    and $f  ; Get register number from high 4 bits
    ld e, a ; Save register number in e
    ; Get value of first register
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers address + Vx offset
    ld a, [hl] ; Save register value to c
    ld c, a
    ; Get value of second register
    ld hl, registers
    ; Get offset of second register in e by >>4
    ld a, e     
    swap a
    and $f
    ld e, a
    ld d, $0
    add hl, de ; Register address + Vy offset
    ld a, [hl] ; Save register value to a and compare with c
    cp c       ; Compare register value to other register value
    jr z, .dont_skip_op
    ; Skip op (program counter += 2)
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
    ld d, $0a
    ld d, d ; Debug message
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
    ld [program_counter+1], a ; Set low byte next
    ld d, $0b
    ld d, d ; Debug message
    ret ; Return and continue execution


_c_rnd_vx_byte: ; Vx = random byte AND (&) byte(kk)

_d_drw_vx_vy_nibble: ; ??

_e_table:

_f_table:


_8xy0:  ; Ld Vx, Vy (Vx = Vy)
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
    ; Get register offset
    ld a, d ; High byte of opcode into a
    and $f  ; Get register number from low 4 bits 
    ld c, a
    ; Get register address in memory
    ld hl, registers
    ld b, $0
    add hl, bc ; Registers + Vx Offset
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
    jr .set_no_carry
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
    jr .set_no_carry
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


; @param de -> holds opcode $8xy-
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
