## Tests

- Set operation 00E0 to print out a success message
- Set operation 0000 to stop execution i.e. exit()
- Run ROM

### JP1 Test

0200: x12 06 *jump to 206*
0202: x00 00
0204: x00 00
0206: x00 E0 *print out success*
0208: x00 00 *stop*


### CALL2 and RET00EE Test

0200: x12 04 *jump to 204*
0202: x00 00
0204: x22 14 *call 214*
0206: x00 E0 *print out success*
0208: x00 00 *stop*
020A: x12 12 *jump to 212*
020C: x00 00
020E: x00 00
0210: x00 00
0212: x00 EE *return*
0214: x12 0A *jump to 20A*


### SE3

0200: x20 FF *jump if equal*
0202: x00 00 *print out success*
0204: x12 00 *jump to 200*
