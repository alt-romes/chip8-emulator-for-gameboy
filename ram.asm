; Hardcoded chip8 game ROM binary
section "ram", WRAM0

memory:
    ds $FFF ; Allocate 0xFFF bytes for the memory

registers:
    ds 16   ; Allocate 16 bytes, one for each of the 16 V registers

sound_register:
    ds 1    ; Allocate 1 byte for the sound register

delay_register:
    ds 1    ; Allocate 1 byte for the delay register

i_register:
    ds 2    ; Allocate 2 bytes for the I register

program_counter:
    ds 2    ; Allocate 2 bytes for the Program Counter (16bit)

stack_pointer:
    ds 1    ; Allocate 1 byte for the Stack Pointer (16 possible values)

stack:
    ds 32   ; Allocate 32 bytes ( 2 * 16 ) for the stack -> 16 positions of 2 bytes (16bits) each

input_register:
    ;ds 2   ; Allocate 2 bytes (16 bits) to store if any of the 16 keys is pressed
    ds 1    ; Allocate just 1 byte instead and use only 8 inputs max : Higher nibble is PAD and lower nibble is BUTTONS

cycles_left_in_frame:
    ds 1    ; Allocate 1 byte to store the amount of cycles run this frame

a_counter:
    ds 1    ; Allocate 1 byte to use as a counter in the program