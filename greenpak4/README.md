Silego GreenPAK 4
=================

Build OpenFPGA:
```sh
sudo apt-get install libjson-c-dev
git clone --recursive https://github.com/azonenberg/openfpga.git
cd openfpga && mkdir build && cd build
cmake .. && make && sudo make install
```

Silego Resources:
* [GreenPAK 4 Programmable Mixed-signal Matrix](http://www.silego.com/products/greenpak4.html)
* [GreenPAK Designer](http://www.silego.com/softdoc/software.html)
* [GreenPAK Designer User Guide](http://www.silego.com/uploads/resources/GreenPAK_Designer_User_Guide.pdf)
* [GreenPAK Universal Development Board User Guide](http://www.silego.com/uploads/resources/GreenPAK%20Universal%20Development%20Board%20User%20Guide.pdf)
* [Application Notes](http://www.silego.com/softdoc/app_notes.html?filtercol=GreenPAK4)

Parts included with GreenPAK 4 Development Board:
* [SLG46140V (STQFN-14)](http://www.silego.com/uploads/Products/product_285/SLG46140r100_10202016.pdf)
* [SLG46620V (STQFN-20)](http://www.silego.com/uploads/Products/product_336/SLG46620r100_10202016.pdf)

Open FPGA Resources:
* [Open Verilog flow for Silego GreenPak4 programmable logic devices](http://siliconexposed.blogspot.de/2016/05/open-verilog-flow-for-silego-greenpak4.html)
* <https://github.com/azonenberg/openfpga/>
* [GreenPak4 HDL Place-And-Route User Guide](http://thanatos.virtual.antikernel.net/unlisted/gp4-hdl.pdf)
* [Yosys Manual](http://www.clifford.at/yosys/files/yosys_manual.pdf)
