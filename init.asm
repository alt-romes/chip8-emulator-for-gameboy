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
.copy_chip8font:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy_chip8font





    ; The following part is here just for testing for now - It disables LCDC and prepares the font
    


    ; Turn off the LCD (There's a solution to do access VRAM while it's on, but we're setting it off to access it the easy way) (we can only do it during VBLANK)
    ; This local block will wait for v blank before proceding
.wait_v_blank ; the dot before the label defines a local label
    ldh a, [rLY] ; ldh access $FF00-$FFFF with an offset, it's faster than ld
    cp 144       ; LCD is past VBLANK when LY is in 144-153
    jr c, .wait_v_blank ; it'll jump back while a < 144
        ; cp will subtract a - 144, if a < 144, C will be set because for example 10 - 144 = 122 (a subtraction to 10 made it a bigger number (had carry)) 
        ; cp $x will set carry if a < $x , carry will be reset if a >= $x, zero will be set if a == $x, and reset if a != $x

    ; Finally disable the display

    xor a ; Set a to 0
    ld [rLCDC], a ; Set LCDC to 0, this will disable bit 7, consequently it will disable the display

    ; Access VRAM now that it's disabled

    ld hl, $9000 ; $9000 is block 2 of VRAM
    ld de, font_tiles ; Load to de address where FontTiles are ( they will be defined later )
    ld bc, font_tiles_end - font_tiles ; Load size of tiles to bc
.copy_font:
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination and increment hl
    inc de ; Move to next byte
    dec bc ; Decrement bytes left
    ld a, b ; Check if count is 0, since dec bc doesn't update flags
    or c    ; If both a and c are 0, or a c will set zero
    jr nz, .copy_font
