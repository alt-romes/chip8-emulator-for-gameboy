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


### SE3

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