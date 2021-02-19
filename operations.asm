section "operations", ROM0

operations_table:
    ; Define words because addressing is done with 16 bit in the gb
    dw _0_table
    dw _1_jp_addr

_0_table:
    ; The font tiles are now set, now we write the tilemap 

    ld hl, $9800 ; this will print the string at the top left corner of the screen
    ld de, hello_world_str
.copy_string:
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we copied is zero (and a, a will set zero flag if a is zero)
    jr nz, .copy_string ; Continue if it's not
    ret ; Return to execution


_1_jp_addr:
    ; The font tiles are now set, now we write the tilemap 

    ld hl, $9800 ; this will print the string at the top left corner of the screen
    ld de, goodbye_world_str
.copy_string:
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we copied is zero (and a, a will set zero flag if a is zero)
    jr nz, .copy_string ; Continue if it's not
    ret ; Return to execution