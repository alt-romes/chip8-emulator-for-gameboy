; Hardcoded chip8 game ROM binary
section "chip8rom", ROM0

chip8_rom:
incbin "roms/op1.ch8"
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
