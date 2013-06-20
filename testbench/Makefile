XILINXBASE = /opt/Xilinx/10.1/ISE/vhdl/src

GHDL = ghdl

GHDLFLAGS = --ieee=synopsys -fexplicit -Wc,-m32 -Wa,--32 -Wl,-m32
LIBS = -Punisim -Punimacro
WORK = --work=work

tb_overlap_add: overlap_add.o
tb_mul: mul.o
tb_cmul: cmul.o mul.o
tb_average_mem: average_mem.o
tb_toggle: toggle.o
tb_proc_memory: proc_memory.o
tb_outbuf: outbuf.o

%: %.o
	$(GHDL) -e $(GHDLFLAGS) $(LIBS) $(WORK) $@

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $(LIBS) $(WORK) $<

%.ghw: %
	./$< --wave=$@

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
	rm -rf *.o *.s

vpath %.vhd ../vhdl:../wizard:.

.PHONY: clean clean-unisim clean-unimacro unisim unimacro
.SUFFIXES:
.SUFFIXES: .vhd .o .ghw

overlap_add.o: fft.o fftncmul.o ifftnadd.o ram4x32S.o
fftncmul.o: cmul.o wave.o
wave.o: mul.o convergent.o
cmul.o: mul.o convergent.o
average_mem.o: ram48xi.o
toggle.o: flag.o procedures.o
outbuf.o: cmul.o ram48xi.o transmitter.o
transmitter.o: balance.o
ram48xi.o: ram48x1.o
