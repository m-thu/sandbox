MediaTek MT7681
===============

## Hardware
Module pinout (top view):
```
      __________________________
RST   |o                      o| GND
      |                        |
GPIO0 |o   --------           o| FL_CLK
      |    | MT   |            |
GPIO1 |o   |.7681 |           o| FL_CS
      |    --------            |
GPIO2 |o                      o| FL_MOSI
      |                        |
GPIO3 |o                      o| FL_MISO
      |    UFL  -----------    |
GPIO4 |o   |    | Winbond.|   o| 3.3V_2 \
      |    v    | 25x40   |    |         - not connected
TXD   |o  ---   -----------   o| 3.3V_1 /  together
      |   |O|                  |
RXD   |o  ---                 o| GND
      --------------------------

      3.3V_1: Flash
      3.3V_2: Microcontroller
```

## Software

## References
[MediaTek MT7681](http://labs.mediatek.com/site/global/developer_tools/mediatek_7681/whatis_7681/index.gsp)

[MediaTek MT7681 Datasheet](https://labs.mediatek.com/fileMedia/download/1231ba72-bdb8-4b7c-bd3c-e9990d4fe1e1)

[MediaTek LinkIt(TM) Connect 7681 Developer's Guide](http://labs.mediatek.com/fileMedia/download/60b77480-f08e-46de-b4ab-513916dcff75)

[MediaTek LinkIt(TM) Connect 7681 API Reference](http://labs.mediatek.com/fileMedia/download/5a44333c-f56a-47e6-ad03-9acfa33c9561)

[AndeStar ISA Manual, v1.9, 2015/06/12](http://www.andestech.com/en/products/documentation.htm)

[Andes Programming Guide for ISA V3, v1.2, 2015/07/30](http://www.andestech.com/en/products/documentation.htm)

[Winbond W25x40 Flash Datasheet](http://pdf1.alldatasheet.com/datasheet-pdf/view/197512/WINBOND/W25X40.html)
