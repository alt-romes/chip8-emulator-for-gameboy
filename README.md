## CHIP8 Emulator for Gameboy

A chip8 emulator made directly for the gameboy in RGBASM (assembly)

This is a work in progress, and not yet complete :)

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

### Testing

See [testing](https://github.com/alt-romes/chip8-emulator-for-gameboy/tree/master/tests)

## References

* Compiler, Linker and Fixer: [RGBDS](https://rgbds.gbdev.io)
* Hello World: [ISSOtm's tutorial](https://eldred.fr/gb-asm-tutorial/hello-world.html)
