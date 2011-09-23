GHDLFLAGS = --ieee=synopsys -Punisim -Pxcl -fexplicit --work=work
GHDL = ghdl

CORELIB = BLK_MEM_GEN_V2_8.o

tb_overlap_add: wave.o cmul.o cadd.o fft_fsm.o overlap_add.o scratch.o fft.o

%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

export 

unisim:
	$(MAKE) -C unisim

xcl:	
	$(MAKE) -C xcl

prereq: unisim xcl
	touch prereq

clean-unisim:
	$(MAKE) -C unisim clean
clean-xcl:
	$(MAKE) -C xcl clean

clean: clean-unisim clean-xcl
	rm -rf prereq
	rm -rf work-obj93.cf
	rm -rf *o *s

vpath %.vhd ../vhdl:../wizard:.

.PHONY: clean clean-unisim clean-xcl unisim xcl
.SUFFIXES:
.SUFFIXES: .vhd .o
