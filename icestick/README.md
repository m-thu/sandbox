Lattice iCEstick
================

Install Lattice Diamond Programmer 3.0 on Ubuntu 14.04:
```sh
sudo apt-get install alien
sudo alien --scripts -i programmer_3_8_x64-115-3-x86_64-linux.rpm
sudo cp 80-icestick.rules /etc/udev/rules.d/
```

Start Lattice Diamond Programmer 3.0:
```sh
/usr/local/programmer/3.8_x64/bin/lin64/programmer
```

Diamond settings:
```
Cable: HW-USBN-2B (FTDI)
Port : FTUSB-0

Family Name: iCE40
Device Name: iCE40HX1K
```

Lattice resources:
* [iCEstick Evaluation Kit](http://www.latticesemi.com/icestick)
* [iCEstick User Manual](http://www.latticesemi.com/icestick)
* [Lattice iCEcube2(tm)](http://www.latticesemi.com/Products/DesignSoftwareAndIP/FPGAandLDS/iCEcube2.aspx)
* [Lattice Diamond Programmer version 3.0](http://www.latticesemi.com/Products/DesignSoftwareAndIP/ProgrammingAndConfigurationSw/Programmer.aspx)
* [Lattice iCE40 LP/HX Family Datasheet](http://www.latticesemi.com/~/media/LatticeSemi/Documents/DataSheets/iCE/iCE40LPHXFamilyDataSheet.pdf)
* [Lattice iCE Technology Library](http://www.latticesemi.com/~/media/LatticeSemi/Documents/TechnicalBriefs/SBTICETechnologyLibrary201504.pdf)

Other resources:
* [Yosys Open SYnthesis Suite](http://www.clifford.at/yosys/)
* [Project IceStorm](http://www.clifford.at/icestorm/)
* [Arachne-pnr](https://github.com/cseed/arachne-pnr)
