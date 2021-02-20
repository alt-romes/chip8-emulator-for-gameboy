## Tests

- Set operation 00E0 to print out a success message
- Set print outs in every operation you're testing
- Set operation 0000 to stop execution i.e. exit()
- Run ROM

### JP1 Test

0200: x12 06 * jump to 206
0202: x00 00
0204: x00 00
0206: x00 E0 * print out success
0208: x00 00 * stop

12060000000000e00000

Expected operations to run: 1xxx 0xe0 stop


### CALL2 and RET00EE Test

0200: x12 04 *jump to 204
0202: x00 00
0204: x22 14 * call 214
0206: x00 E0 * print out success
0208: x00 00 * stop
020A: x12 12 * jump to 212
020C: x00 00
020E: x00 00
0210: x00 00
0212: x00 EE * return
0214: x12 0A * jump to 20A

Expected ops to run in this order: 1xxx 2xxx 1xxx 1xxx 0xee 0xe0 stop


### LD and SNE and SE

0200: x62 05 * Load: V2 = 5
0202: x32 05 * Skip next instruction if V2 == 5
0204: x00 00 * 0000 blocks execution (don't get blocked here)
0206: x42 04 * Skip next instruction if V0 != 3
0208: x00 00 * block execution (don't get blocked here either)
020A: x63 05 * Load: V3 = 5
020C: x52 30 * Skip next op if V2 == V3
020E: x00 00
0210: x65 03 * Load: V5 = 3
0214: x92 50 * Skip if Vx != Vy
0216: x00 00
0218: x00 E0 * Success
021A: x00 00 * Stop :)

Expected to run: 6xxx 3xxx 4xxx 6xxx 5xxx 6xxx 9xxx 0xE0 stop 


### ADD7 LD80 OR81 AND82 XOR83

0200: x62 05 * Load: V2 = 5
0202: x72 03 * Add: V2 += 3
0204: x32 08 * Skip if V2 == 8
0206: x00 00
0208: x00 E0 * 1st Success = ADD7
020A: x81 20 * LD: V1 = V2
020C: x51 20 * Skip if V1 = V2
020E: x00 00
0210: x00 E0 * 2nd Success = LD80
0212: x62 01 * V2 = 1
0214: x81 21 * V1 |= V2 (9)
0216: x31 09 * Skip if V1 == 9
0218: x00 00
021A: x00 E0 * 3rd Success = OR81
021C: x81 22 * V1 &= V2
021E: x31 01 * Skip if V1 == 1
0220: x00 00
0222: x00 E0 * 4th Success = AND82
0224: x62 02 * V2 = 2
0226: x81 23 * V1 ^= V2
----: x31 03 * Skip if V1 == 3
----: x00 00
----: x00 E0 * 5th Success = XOR83
----: x00 00 * Stop

: 6 7 3 00e0 80 5 00e0 6 81 3 00e0 82 3 00e0 6 83 3 00e0 stop


### ADD84 SUB85 SHR86 SHL8E SUBN87

0200: x61 FE * Load V1 = FE
0202: x62 01 * Load V2 = 1
----: x81 24 * V1 += V2 (V1 = FF now)
----: x3F 00 * There should be no carry, skip if VF = 0
----: x00 00
----: x81 24 * V1 += V2 (V1 should overflow)
----: x3F 01 * There should be carry, skip if VF = 1
----: x00 00
    : x31 00 * Skip if V1 == 0 (should be)
    : x00 00
----: x00 E0 * First succcess = ADD84

----: x81 25 * V1 -= V2 (0 minus 1 = -1), flag should be set to NOT borrow, so VF = 0
----: x3F 00 * Skip if VF = 0
----: x00 00
----: x81 25 * V1 -= V2 (255 minus 1) flag should be set because there was no borrow, VF = 1
----: x3F 01 * Skip if V1 = 1
----: x00 00
    : x31 FE * Skip if V1 == 254 (should be)
    : x00 00
----: x00 E0 * Second success = SUB85

----: x81 06 * Shift right V1 (254 = 1111 1110)
----: x3F 00 * There should be no carry, skip if VF = 0
----: x00 00
----: x81 06 * V1 >>= 1
----: x3F 01 * There should be carry, skip if VF = 1
----: x00 00
    : x31 3F * Skip if V1 == 0x3f (should be)
    : x00 00
    : x00 E0 * Third success = SHR86

----: x81 0E * Shift left V1 (0x3f = 0011 1111)
----: x3F 00 * There should be no carry, skip if VF = 0
----: x00 00
----: x81 0E * V1 <<= 1
----: x81 0E * V1 <<= 1
----: x3F 01 * There should be carry, skip if VF = 1
----: x00 00
    : x31 F8 * Skip if V1 == 0xF8 (should be)
    : x00 00
    : x00 E0 * 4th success = SHL8E

----: x81 27 * SubN V1 = V2 - V1 (1 - 0xF8) = 9
----: x3F 00 * VF should not be set (NOT borrow), skip if VF = 0
----: x00 00
----: x81 17 * SubN V1 -= V1 (9 - 9) == 0
----: x3F 01 * VF should be set (NOT borrow), skip if VF = 1
----: x00 00
    : x31 00 * Skip if V1 == 0 (should be)
    : x00 00
    : x00 E0 * 5th Success = SUBN87
    : x00 00 * Stop

:6 6 84 3 84 3 3 00e0 85 3 85 3 3 00e0 86 3 86 3 3 00e0 8E 3 8E 8E 3 3 00e0 87 3 87 3 3 00e0 stop


### 