helloworld: helloworld.asm
	# compile asm into object file
	rgbasm -o helloworld.o helloworld.asm
	# link objects to create executable
	rgblink -o helloworld.gb helloworld.o
	# fix rom with nintendo logo, and the header and global checksum; and pad to have a specific size (man rgbfix)
	rgbfix -v -p 0 helloworld.gb 
