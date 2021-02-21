section "interrupt_handlers", ROM0

vblank_handler:
    ; Handle input every frame - store in observed value in input_register of chip8
    ld a, P1F_GET_BTN ; Set bit 4 of JOYP to 1 and 5 to 0 to get buttons
    ldh [rP1], a ; Set values in Joypad register
    ldh a, [rP1] ; To read joypad input first write to it and then read: After setting JOYP bit 4 or 5,
                 ; inputs will be processed first again and only then this instruction is executed
                 ; So reading from it right after writing to it will still have the pressed keys correctly
    and $f  ; Use only lower four bits
    cpl ; Invert bits of A because in JOYP 0 = pressed
    ld c, a ; Save BTNs in c
    ld a, P1F_GET_DPAD ; Set bit 5 of JOYP to 0 and 4 to 1 to get PAD
    ldh [rP1], a ; Set it in Joypad register
    ldh a, [rP1] ; Get value after inputs being processed with the new select
    and $f  ; Get lower nibble for values
    swap a  ; Set it in the high nibble
    or c    ; High nibble has DPAD, lower nibble has BUTTONS
    ld [input_register], a ; Store buttons pressed in the input register of the CHIP8
    reti ; Return and enable interrupts