OBJ = $(CORELIB)

all: $(OBJ)

%.o:%.vhd
	$(GHDL) -a --ieee=synopsys -fexplicit --work=xilinxcorelib -P../unisim $<
clean:
	rm -rf xilinxcorelib-obj93.cf *o *s

.PHONY: clean
.SUFFIXES:
.SUFFIXES: .vhd

