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


    ; For all operations,
    ; @param de - opcode


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
    ; Set program counter to nnn
    ld a, d ; get high byte low nibble
    and $f 
    ld [program_counter], a ; High byte is set first
    ld a, e
    ld [program_counter+1], a ; Set lower byte next
    ret ; Return and continue execution

_2_call_addr:

_3_se_vx_byte:  ; Skip if equal (Vx == byte)

_4_sne_vx_byte: ; Skip if not equal (Vx != byte)

_5_se_vx_vy:    ; Skip if Vx == Vy (and last 4 bits are ignored) 

_6_ld_vx_byte:  ; Vx = byte

_7_add_vx_byte: ; Vx += byte

_8_table:       ; Last 4 bits define operation

_9_sne_vx_vy:   ; Skip if Vx != Vy

_a_ld_i_addr:   ; I = nnn

_b_jp_v0_addr:  ; JP to nnn + V0

_c_rnd_vx_byte: ; Vx = random byte AND (&) byte(kk)

_d_drw_vx_vy_nibble: ; ??

_e_table:

_f_table:


