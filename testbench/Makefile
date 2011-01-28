xilinx: unisim-obj93.cf
unisim-obj93.cf: unisims/*vhd
	ghdl -i --work=unisim /opt/Xilinx/10.1/ISE/vhdl/src/unisims/*vhd
clean:
	ghdl --clean
	rm -rf *cf
	rm -rf *lst
tb_inbuf_mem: xilinx
	ghdl -c --ieee=synopsys -fexplicit ../wizard/inbuf_mem.vhd tb_inbuf_mem.vhd -e tb_inbuf_mem
tb_inbuf_mem.vcd: tb_inbuf_mem
	./tb_inbuf_mem --vcd=tb_inbuf_mem.vcd
tb_average_mem: xilinx
	ghdl -c --ieee=synopsys -fexplicit --work=inbuf ../vhdl/inbuf/inbuf_arb.vhd ../vhdl/inbuf/inbuf_ctrl.vhd ../vhdl/inbuf/average_mem.vhd ../wizard/inbuf_mem.vhd tb_average_mem.vhd -e tb_average_mem
tb_average_mem.vcd: tb_average_mem
	./tb_average_mem --vcd=tb_average_mem.vcd --stop-time=10000ns
tb_toggle: xilinx
	ghdl -c --ieee=synopsys -fexplicit --work=proc ../vhdl/proc/flag.vhd ../vhdl/proc/toggle.vhd tb_toggle.vhd -e tb_toggle
tb_toggle.vcd: tb_toggle
	./tb_toggle --vcd=tb_toggle.vcd --stop-time=10000ns
tb_transmitter: xilinx
	ghdl -c --ieee=synopsys -fexplicit --work=outbuf ../vhdl/outbuf/transmitter/balance.vhd ../vhdl/outbuf/transmitter/transmitter.vhd tb_transmitter.vhd -e tb_transmitter
tb_transmitter.vcd: tb_transmitter
	./tb_transmitter --vcd=tb_transmitter.vcd --stop-time=10000ns


.PHONY: clean
