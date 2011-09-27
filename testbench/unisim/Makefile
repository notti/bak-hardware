OBJ = unisim_VCOMP.o unisim_SMODEL.o unisim_virtex5_SMODEL.o unisim_VPKG.o unisim_VITAL.o


all: $(OBJ)


%.o:%.vhd
	$(GHDL) -a --ieee=synopsys -fexplicit --warn-no-vital-generic --work=unisim $<
clean:
	rm -rf unisim-obj93.cf *o *s

.PHONY: clean
.SUFFIXES:
.SUFFIXES: .vhd

unisim_VITAL.o: unisim_VPKG.o
unisim_SMODEL.o: unisim_VCOMP.o
unisim_virtex5_SMODEL.o: unisim_VCOMP.o
