RDM6300 125 kHz RFID reader module
==================================

## Hardware
Top view:
```
                           --------------- +5V (in)
       ----------- GND     |  ------------ GND
       |  -------- Pin 3   |  |
       |  |  ----- Pin 4   |  |     ------ RX
       |  |  |  -- Pin 5   |  |     |  --- TX (9600,N,8,1)
       |  |  |  |          |  |     |  |   3.3V
       v  v  v  v          v  v     v  v
   _______________________________________
  |    o  o  o  o      P1  o  o  o  o  o  |
  |    1  2  3  4          5  4  3  2  1  |
  |    (unpopulated)                      |
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

Silicon Labs F330:
------------------
  Pin 3: VDD (+3.3V)
  Pin 4: /RST, C2CK
  Pin 5: P2.0, C2D
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

Parts:
* TI LM358: [LMx58-N Low-Power, Dual-Operational Amplifiers](http://www.ti.com/lit/ds/symlink/lm158-n.pdf)
* Silicon Labs F330: [Silicon Labs C8051F330/1/2/3/4/5](https://www.silabs.com/Support%20Documents/TechnicalDocs/C8051F33x.pdf)

## Links
[EM4100 RFID Cloner Kit](https://github.com/kbembedded/EM4100_Cloner)
