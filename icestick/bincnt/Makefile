PROJECT = bincnt
SOURCE = bincnt.vhd

GHDL = ghdl
GHDL_SYNTH = ~/ghdlsynth-beta
YOSYS = yosys
ARACHNE_PNR = arachne-pnr
ICEPACK = icepack
ICEPROG = iceprog

all : $(PROJECT).bin

work-obj93.cf : $(SOURCE)
	$(GHDL) -a $(SOURCE)

$(PROJECT).blif : work-obj93.cf
	$(YOSYS) -m $(GHDL_SYNTH)/ghdl.so -p "ghdl $(PROJECT); \
		synth_ice40 -blif $(PROJECT).blif"

%.asc : %.blif $(PROJECT).pcf
	$(ARACHNE_PNR) -d 1k -p $(PROJECT).pcf $< -o $@

%.bin : %.asc
	$(ICEPACK) $< $@

flash : $(PROJECT).bin
	$(ICEPROG) $<

clean :
	rm -f *.blif *.asc *.bin *.vcd *.vvp work-obj93.cf

.PHONY : clean all lint flash
