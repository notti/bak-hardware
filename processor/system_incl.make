#################################################################
# Makefile generated by Xilinx Platform Studio 
# Project:/home/notti/fpga/bakk/processor/system.xmp
#
# WARNING : This file will be re-generated every time a command
# to run a make target is invoked. So, any changes made to this  
# file manually, will be lost when make is invoked next. 
#################################################################

XILINX_EDK_DIR = /opt/Xilinx/10.1/EDK
NON_CYG_XILINX_EDK_DIR = /opt/Xilinx/10.1/EDK

SYSTEM = system

MHSFILE = system.mhs

MSSFILE = system.mss

FPGA_ARCH = virtex5

DEVICE = xc5vfx70tff1136-1

LANGUAGE = vhdl

SEARCHPATHOPT =  -lp /home/notti/fpga/bakk/

SUBMODULE_OPT = 

PLATGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(SUBMODULE_OPT)

LIBGEN_OPTIONS = -mhs $(MHSFILE) -p $(DEVICE) $(SEARCHPATHOPT)

VPGEN_OPTIONS = -p $(DEVICE) $(SEARCHPATHOPT)

MANAGE_FASTRT_OPTIONS = -reduce_fanout no

OBSERVE_PAR_OPTIONS = -error yes

MICROBLAZE_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop.elf
PPC405_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc405/ppc_bootloop.elf
PPC440_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc440/ppc440_bootloop.elf
BOOTLOOP_DIR = bootloops

PPC440_0_BOOTLOOP = $(BOOTLOOP_DIR)/ppc440_0.elf

BRAMINIT_ELF_FILES =   $(PPC440_0_BOOTLOOP) 
BRAMINIT_ELF_FILE_ARGS =   -pe ppc440_0  $(PPC440_0_BOOTLOOP) 

ALL_USER_ELF_FILES = 

SIM_CMD = vsim

BEHAVIORAL_SIM_SCRIPT = simulation/behavioral/$(SYSTEM)_setup.do

STRUCTURAL_SIM_SCRIPT = simulation/structural/$(SYSTEM)_setup.do

TIMING_SIM_SCRIPT = simulation/timing/$(SYSTEM)_setup.do

DEFAULT_SIM_SCRIPT = $(BEHAVIORAL_SIM_SCRIPT)

MIX_LANG_SIM_OPT = -mixed yes

SIMGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(BRAMINIT_ELF_FILE_ARGS) $(MIX_LANG_SIM_OPT)  -s mti


LIBRARIES =  \
       ppc440_0/lib/libxil.a 
VPEXEC = virtualplatform/vpexec

LIBSCLEAN_TARGETS = ppc440_0_libsclean 

PROGRAMCLEAN_TARGETS = 

CORE_STATE_DEVELOPMENT_FILES = /opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/proc_common_pkg.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/ipif_pkg.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/or_muxcy.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/or_gate128.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/family_support.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/pselect_f.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/counter_f.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v2_00_a/hdl/vhdl/soft_reset.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/plbv46_slave_single_v1_00_a/hdl/vhdl/plb_address_decoder.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/plbv46_slave_single_v1_00_a/hdl/vhdl/plb_slave_attachment.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/plbv46_slave_single_v1_00_a/hdl/vhdl/plbv46_slave_single.vhd \
/opt/Xilinx/10.1/EDK/hw/XilinxProcessorIPLib/pcores/interrupt_control_v2_00_a/hdl/vhdl/interrupt_control.vhd \
/home/notti/fpga/bakk/processor/pcores/proc2fpga_v2_00_a/hdl/vhdl/user_logic.vhd \
/home/notti/fpga/bakk/processor/pcores/proc2fpga_v2_00_a/hdl/vhdl/proc2fpga.vhd

WRAPPER_NGC_FILES = implementation/ppc440_0_wrapper.ngc \
implementation/plb_v46_0_wrapper.ngc \
implementation/ddr2_sdram_wrapper.ngc \
implementation/rs232_uart_1_wrapper.ngc \
implementation/hard_ethernet_mac_wrapper.ngc \
implementation/sysace_compactflash_wrapper.ngc \
implementation/hard_ethernet_mac_fifo_wrapper.ngc \
implementation/clock_generator_0_wrapper.ngc \
implementation/jtagppc_cntlr_0_wrapper.ngc \
implementation/proc_sys_reset_0_wrapper.ngc \
implementation/xps_intc_0_wrapper.ngc \
implementation/xps_bram_if_cntlr_0_wrapper.ngc \
implementation/bram_block_0_wrapper.ngc \
implementation/proc2fpga_0_wrapper.ngc

POSTSYN_NETLIST = implementation/$(SYSTEM).ngc

SYSTEM_BIT = implementation/$(SYSTEM).bit

DOWNLOAD_BIT = implementation/download.bit

SYSTEM_ACE = implementation/$(SYSTEM).ace

UCF_FILE = data/system.ucf

BMM_FILE = implementation/$(SYSTEM).bmm

BITGEN_UT_FILE = etc/bitgen.ut

XFLOW_OPT_FILE = etc/fast_runtime.opt
XFLOW_DEPENDENCY = __xps/xpsxflow.opt $(XFLOW_OPT_FILE)

XPLORER_DEPENDENCY = __xps/xplorer.opt
XPLORER_OPTIONS = -p $(DEVICE) -uc $(SYSTEM).ucf -bm $(SYSTEM).bmm -max_runs 7

FPGA_IMP_DEPENDENCY = $(BMM_FILE) $(POSTSYN_NETLIST) $(UCF_FILE) $(XFLOW_DEPENDENCY)