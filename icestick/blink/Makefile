PROJECT = blink
SOURCE = blink.v

YOSYS = yosys
ARACHNE_PNR = arachne-pnr
ICEPACK = icepack
ICEPROG = iceprog
IVERILOG = iverilog
LINT = verilator --lint-only

all : $(PROJECT).bin

$(PROJECT).blif : $(SOURCE)
	$(YOSYS) -p "synth_ice40 -blif $(PROJECT).blif" $(SOURCE)

%.asc : %.blif $(PROJECT).pcf
	$(ARACHNE_PNR) -d 1k -p $(PROJECT).pcf $< -o $@

%.bin : %.asc
	$(ICEPACK) $< $@

lint : $(SOURCE)
	$(LINT) $(SOURCE)

flash : $(PROJECT).bin
	$(ICEPROG) $<

clean :
	rm -f *.blif *.asc *.bin *.vcd

.PHONY : clean all lint flash
