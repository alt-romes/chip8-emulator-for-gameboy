; Hardcoded chip8 game ROM binary
section "chip8rom", ROM0

chip8_rom:
;incbin "tests/jp1_test.ch8"
;incbin "tests/call2_and_ret00ee_test.ch8"
;incbin "tests/ld_se_sne_34569_test.ch8"
;incbin "tests/add7_ld80_or81_and82_xor83_test.ch8"
;incbin "tests/add84_sub85_shr86_shl8e_subn87_test.ch8"
;incbin "roms/Cave.ch8"
incbin "roms/pong.rom"
chip8_rom_end:

chip8_font:
db $F0, $90, $90, $90, $F0
db $20, $60, $20, $20, $70
db $F0, $10, $F0, $80, $F0
db $F0, $10, $F0, $10, $F0
db $90, $90, $F0, $10, $10
db $F0, $80, $F0, $10, $F0
db $F0, $80, $F0, $90, $F0
db $F0, $10, $20, $40, $40
db $F0, $90, $F0, $90, $F0
db $F0, $90, $F0, $10, $F0
db $F0, $90, $F0, $90, $90
db $E0, $90, $E0, $90, $E0
db $F0, $80, $80, $80, $F0
db $E0, $90, $90, $90, $E0
db $F0, $80, $F0, $80, $F0
db $F0, $80, $F0, $80, $80
chip8_font_end:
