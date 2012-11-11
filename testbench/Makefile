GHDLFLAGS = --ieee=synopsys -Punisim -Punimacro -fexplicit --work=work
GHDL = ghdl

tb_overlap_add: overlap_add.o
tb_mul: mul.o
tb_cmul: cmul.o mul.o
tb_average_mem: average_mem.o inbuf_mem.o
tb_toggle: toggle.o
tb_proc_memory: proc_memory.o

%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

export 

unisim:
	$(MAKE) -C unisim

unimacro: unisim
	$(MAKE) -C unimacro

prereq: unisim unimacro
	touch prereq

clean-unisim:
	$(MAKE) -C unisim clean
clean-unimacro:
	$(MAKE) -C unimacro clean

clean: clean-unisim clean-unimacro
	rm -rf prereq
	rm -rf work-obj93.cf
	rm -rf *o *s

vpath %.vhd ../vhdl:../wizard:.

.PHONY: clean clean-unisim clean-unimacro unisim unimacro
.SUFFIXES:
.SUFFIXES: .vhd .o

cmul.o: mul.o
overlap_add.o: fft.o fftncmul.o ifftnadd.o ram4x32S.o
fftncmul.o: cmul.o wave.o
average_mem.o: inbuf_mem.o
toggle.o: flag.o procedures.o
