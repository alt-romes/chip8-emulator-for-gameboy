START_ADDRESS EQU $200
FONTSET_START_ADDRESS EQU $50

.init:

    ; Init program counter
    ld hl, START_ADDRESS
    ld a, h
    ld [program_counter], a   ; h comes first bc chip 8 is big endian
    ld a, l
    ld [program_counter+1], a ; l is in the second byte of the program counter


    ; Copy chip8 ROM file to chip8 memory
    ld hl, memory+START_ADDRESS ; hl has address of the chip8 memory + offset
    ld de, chip8_rom            ; de has address of the chip8 rom in the gb's rom
    ld bc, chip8_rom_end - chip8_rom
.copy_chip8rom:
    ld a, [de]  ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination and increment hl
    inc de  ; Move to next byte
    dec bc  ; Decrement bytes left
    ld a, b ; Check if count is 0, since dec bc doesn't update flags
    or c    ; If both a and c are 0, or a c will set zero
    jr nz, .copy_chip8rom


    ; Copy chip8 font set into chip8 memory
    ld hl, memory+FONTSET_START_ADDRESS
    ld de, chip8_font
    ld bc, chip8_font_end - chip8_font
.copy_chip8font
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or b, c
    jr nz, .copy_chip8font
