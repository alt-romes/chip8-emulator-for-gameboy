include "hardware.inc"

include "rom.asm"
include "ram.asm"

section "header", ROM0[$100] ; Memory type ROM0 and the address where the section must be placed ($100)

entry_point: ; execution begins here
    di ; disable interrupts : we don't need interrupts 
    jp start ; leave this tiny space : execution starts at $100, but the header starts at $104

rept $150 - $104 ; Header spans $104 - $14F, but *rgbfix* sets the header for us
    db 0         ; So we set everything as 0
endr

section "main", ROM0[$150]

start:
include "init.asm"

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
.copy_font
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination and increment hl
    inc de ; Move to next byte
    dec bc ; Decrement bytes left
    ld a, b ; Check if count is 0, since dec bc doesn't update flags
    or c    ; If both a and c are 0, or a c will set zero
    jr nz, .copy_font

    ; The font tiles are now set, now we write the tilemap 

    ld hl, $9800 ; this will print the string at the top left corner of the screen
    ld de, hello_world_str
.copy_string
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we copied is zero (and a, a will set zero flag if a is zero)
    jr nz, .copy_string ; Continue if it's not

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


section "Hello World string", ROM0

hello_world_str:
    db "Hello World!", 0 ; db copies data bytes, there's also dw for copy data words and dl for 32-bit longs
