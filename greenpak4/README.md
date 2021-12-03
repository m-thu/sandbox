Silego GreenPAK 4
=================

Build OpenFPGA:
```sh
sudo apt-get install libjson-c-dev
git clone --recursive https://github.com/azonenberg/openfpga.git
cd openfpga && mkdir build && cd build
cmake .. && make && sudo make install
```

~~Silego Resources~~ (obsolete):
* [GreenPAK 4 Programmable Mixed-signal Matrix](http://www.silego.com/products/greenpak4.html)
* [GreenPAK Designer](http://www.silego.com/softdoc/software.html)
* [GreenPAK Designer User Guide](http://www.silego.com/uploads/resources/GreenPAK_Designer_User_Guide.pdf)
* [GreenPAK Universal Development Board User Guide](http://www.silego.com/uploads/resources/GreenPAK%20Universal%20Development%20Board%20User%20Guide.pdf)
* [Application Notes](http://www.silego.com/softdoc/app_notes.html?filtercol=GreenPAK4)

~~Parts included with GreenPAK 4 Development Board~~ (obsolete):
* [SLG46140V (STQFN-14)](http://www.silego.com/uploads/Products/product_285/SLG46140r100_10202016.pdf)
* [SLG46620V (STQFN-20)](http://www.silego.com/uploads/Products/product_336/SLG46620r100_10202016.pdf)

Open FPGA Resources:
* [Open Verilog flow for Silego GreenPak4 programmable logic devices](http://siliconexposed.blogspot.de/2016/05/open-verilog-flow-for-silego-greenpak4.html)
* <https://github.com/azonenberg/openfpga/>
* [Yosys Manual](http://www.clifford.at/yosys/files/yosys_manual.pdf)

Dialog Semiconductors Resources:
* [GreenPAK](https://www.dialog-semiconductor.com/products/greenpak)

Development Board (old name: GreenPAK 4 Dev Board):
* [GreenPAK Advanced Development
Board](https://www.dialog-semiconductor.com/products/greenpak/slg4dvkadv)

Dialog Datasheets:
* [SLG46140V](https://www.dialog-semiconductor.com/products/greenpak/slg46140):
<https://www.dialog-semiconductor.com/sites/default/files/2021-08/SLG46140r117_08182021.pdf>
* [SLG46620](https://www.dialog-semiconductor.com/products/greenpak/slg46620):
<https://www.dialog-semiconductor.com/sites/default/files/slg46620r115_10282019.pdf>

Go Configure Software Hub (includes GreenPAK Designer) 6.27.001:
* Windows 32 bit:
<https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_WIN_Setup.zip>
* Windows 64 bit:
<https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_WIN64_Setup.zip>
* Ubuntu 18.04/20.04 64 bit:
<https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_Ubuntu-18.04_amd64_Setup.deb>
* Debian-testing 32 bit:
<https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_Debian-testing_i386_Setup.deb>
* Debian-testing 64 bit:
<https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_Debian-testing_amd64_Setup.deb>
* macOS: <https://support.dialog-semiconductor.com/downloads/Go_Configure_Software_Hub_v6.27.001_MAC_Setup.zip>

Ubuntu 20.04:

Openfpga project:<https://github.com/azonenberg/openfpga>

```
openfpga/src/gpcosim/gpcosim.cpp:20:10: fatal error: vpi_user.h: No
such file or directory
   20 | #include <vpi_user.h>
      |          ^~~~~~~~~~~~
compilation terminated.
make[2]: *** [src/gpcosim/CMakeFiles/gpcosim.dir/build.make:63:
src/gpcosim/CMakeFiles/gpcosim.dir/gpcosim.cpp.o] Error 1
make[1]: *** [CMakeFiles/Makefile2:582:
src/gpcosim/CMakeFiles/gpcosim.dir/all] Error 2
make: *** [Makefile:141: all] Error 2
```

Install Icarus Verilog:
```sh
git clone git://github.com/steveicarus/iverilog.git
sudo apt-get install build-essential autoconf gperf flex bison
cd iverilog && sh autoconf.sh
./configure && make && sudo make install
```

```
yosys -p 'read_verilog counter.v' \
-p 'synth_greenpak4 -part SLG46620V -json counter.json'
make: yosys: Command not found
make: *** [../../Makefile.common:9: counter.json] Error 127
```

Install Yosys:
```sh
git clone https://github.com/YosysHQ/yosys.git
sudo apt-get install build-essential clang bison flex \
libreadline-dev gawk tcl-dev libffi-dev git \
graphviz xdot pkg-config python3 libboost-system-dev \
libboost-python-dev libboost-filesystem-dev zlib1g-dev
cd yosys && make && sudo make install
```

Compile counter example:
```sh
cd primitives/counter_inference
make

...

2.29. Executing JSON backend.

End of script. Logfile hash: 7ad2fcd95c, CPU: user 0.13s system 0.03s,
MEM: 16.83 MB peak
Yosys 0.11+52 (git sha1 UNKNOWN, clang 10.0.0-4ubuntu1 -fPIC -Os)
Time spent: 60% 4x abc (0 sec), 12% 7x read_verilog (0 sec), ...
gp4par counter.json -o counter.txt -p SLG46620V
GreenPAK 4 place-and-route by Andrew D. Zonenberg.

License: LGPL v2.1+
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Loading Yosys JSON file "counter.json".
Netlist creator: Yosys 0.11+52 (git sha1 UNKNOWN, clang 10.0.0-4ubuntu1 -fPIC -O
s)

Loading modules...
    ERROR: module child should be of type object but isn't
make: *** [../../Makefile.common:13: counter.txt] Segmentation fault
(core dumped)
```

Versions:
* Icarus Verilog: commit 71c36d1289873e9e9fb2699c1de1f22dee2021e6
* Yosys: commit 2be110cb0ba645f95f62ee01b6a6fa46a85d5b26
* openfpga: commit f9ae535d0372c246075d1bb05a409adaed0135e7
