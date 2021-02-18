# # $@ is left side of rule, $< is the first dependency
# %.o: %.asm
# 	rgbasm $< -o $@

# # $@ is the left side of the rule, $^ is the right side
# chip8: main.o rom.o ram.o
# 	rgblink -t -w $^ -o $@.gb
# 	rgbfix -v -p 0 $@.gb

# $@ is the left side of the rule
chip8: main.asm rom.asm ram.asm
	rgbasm $< -o main.o
	rgblink -t -w main.o -o $@.gb
	rgbfix -v -p 0 $@.gb

run: chip8
	./emulator -r $<.gb

.PHONY: clean
clean:
	rm *.o
	rm chip8.gb


# Example RGBASM helloworld
helloworld: helloworld.asm
	# compile asm into object file
	rgbasm -o helloworld.o helloworld.asm
	# link objects to create executable (man rgblink)
	rgblink -o helloworld.gb helloworld.o
	# fix rom with nintendo logo, and the header and global checksum; and pad to have a specific size (man rgbfix)
	rgbfix -v -p 0 helloworld.gb 
