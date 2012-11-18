OBJ = unimacro_VCOMP.o


all: $(OBJ)


%.o:%.vhd
	$(GHDL) -a --ieee=synopsys -fexplicit --warn-no-vital-generic --work=unimacro -P../unisim $<
clean:
	rm -rf unimacro-obj93.cf *o *s

.PHONY: clean
.SUFFIXES:
.SUFFIXES: .vhd

unimacro_VCOMP.o: BRAM_SDP_MACRO.o  BRAM_SINGLE_MACRO.o  BRAM_TDP_MACRO.o  FIFO_DUALCLOCK_MACRO.o  FIFO_SYNC_MACRO.o
