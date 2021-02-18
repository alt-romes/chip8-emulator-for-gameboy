; Hardcoded chip8 game ROM binary
section "chip8rom", ROM0

chip8_rom:
incbin "chip8-roms/Cave.ch8"
chip8_rom_end:
