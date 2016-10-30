RDM6300 125 kHz RFID reader module
==================================

## Hardware
Top view:
```
                           --------------- +5V (in)
       ----------- GND     |  ------------ GND
       |  --------         |  |
       |  |  -----         |  |     ------ RX
       |  |  |  --         |  |     |  --- TX (9600,N,8,1)
       |  |  |  |          |  |     |  |
       v  v  v  v          v  v     v  v
   _______________________________________
  |    o  o  o  o      P1  o  o  o  o  o  |
  |    1  2  3  4          5  4  3  2  1  |
  |                                       |
  |                                       |
  |                                       |
  | 1  2                         3  2  1  |
  | o  o  P2                 P3  o  o  o  |
   ---------------------------------------
    ^  ^                         ^  ^  ^
    |  |                         |  |  |
    |  --- Antenna 2             |  |  --- LED
    ------ Antenna 1             |  ------ +5V (out)
                                 --------- GND
```

UART output format:
```
Tag number: 0x12 0x34 0x56 0x78 0x9a
              ||
       _______||      . . . .
ASCII  |  _____|
       |  |
       v  v
0x02 | A  B  C  D  E  F  G  H  I  J | A  B | 0x03
                                      ^  ^
                                      |  |
                             ASCII    ----|
                                         ||
                                         ||
Checksum: 0x12 XOR 0x34 ... XOR 0x9a = 0xXX
```

## Links
[EM4100 RFID Cloner Kit](https://github.com/kbembedded/EM4100_Cloner)
