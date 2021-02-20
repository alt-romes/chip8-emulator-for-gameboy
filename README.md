## CHIP8 Emulator for Gameboy

A chip8 emulator made directly for the gameboy in RGBASM (assembly)

### Building

Make will generate `chip8.gb`
```
make
```

### Running

To run, a gameboy or gameboy emulator is needed - i pair it with [my emulator](https://github.com/alt-romes/gameboyemulator)
```
./emulator -r chip8.gb
```

## References

Compiler, Linker and Fixer: [RGBDS](https://rgbds.gbdev.io)
Hello World: [ISSOtm's tutorial](https://eldred.fr/gb-asm-tutorial/hello-world.html)
