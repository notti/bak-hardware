-----------------------------------------------------------
--Top level entity
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity top is
port(
-- signals for gtx transciever
    gtx_refclk_n                                : in  std_logic;
    gtx_refclk_p                                : in  std_logic;
    gtx_rxn                                     : in  std_logic_vector(5 downto 0);
    gtx_rxp                                     : in  std_logic_vector(5 downto 0);
    gtx_txn                                     : out std_logic_vector(5 downto 0);
    gtx_txp                                     : out std_logic_vector(5 downto 0);
    inbuf_trigger                               : in  std_logic;
    frame_clk                                   : out std_logic;
-- signals for oserdes transmitter
    oserdes_txn                                 : out std_logic_vector(7 downto 0);
    oserdes_txp                                 : out std_logic_vector(7 downto 0);
    oserdes_txclkn                              : out std_logic;
    oserdes_txclkp                              : out std_logic;
-- signals for processor
    fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    fpga_0_LEDs_Positions_GPIO_IO_pin : inout std_logic_vector(0 to 4);
    fpga_0_DDR2_SDRAM_DDR2_DQ_pin : inout std_logic_vector(63 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_pin : inout std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin : inout std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_A_pin : out std_logic_vector(12 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_BA_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_WE_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_ODT_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CKE_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_DM_pin : out std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_N_pin : out std_logic_vector(1 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPA_pin : out std_logic_vector(6 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_CLK_pin : in std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : in std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_CEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_OEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_WEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPD_pin : inout std_logic_vector(15 downto 0);
    fpga_0_RS232_Uart_1_sin_pin : in std_logic;
    fpga_0_RS232_Uart_1_sout_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin : out std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin : in std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_MDC_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_MDIO_0_pin : inout std_logic;
    fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin : in std_logic;
    fpga_0_clk_1_sys_clk_pin : in std_logic;
    fpga_0_rst_1_sys_rst_pin : in std_logic
);
end top;

architecture Structural of top is
COMPONENT processor 
PORT(
    fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    fpga_0_LEDs_Positions_GPIO_IO_pin : inout std_logic_vector(0 to 4);
    fpga_0_DDR2_SDRAM_DDR2_DQ_pin : inout std_logic_vector(63 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_pin : inout std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin : inout std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_A_pin : out std_logic_vector(12 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_BA_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_WE_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CS_N_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_ODT_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CKE_pin : out std_logic;
    fpga_0_DDR2_SDRAM_DDR2_DM_pin : out std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_pin : out std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_N_pin : out std_logic_vector(1 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPA_pin : out std_logic_vector(6 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_CLK_pin : in std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : in std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_CEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_OEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_WEN_pin : out std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPD_pin : inout std_logic_vector(15 downto 0);
    fpga_0_RS232_Uart_1_sin_pin : in std_logic;
    fpga_0_RS232_Uart_1_sout_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin : out std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin : in std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin : in std_logic;
    fpga_0_Hard_Ethernet_MAC_MDC_0_pin : out std_logic;
    fpga_0_Hard_Ethernet_MAC_MDIO_0_pin : inout std_logic;
    fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin : in std_logic;
    fpga_0_clk_1_sys_clk_pin : in std_logic;
    fpga_0_rst_1_sys_rst_pin : in std_logic;
    proc2fpga_0_bus2fpga_be_pin : out std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_clk_pin : out std_logic;
    proc2fpga_0_bus2fpga_burst_pin : out std_logic;
    proc2fpga_0_bus2fpga_cs_pin : out std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_addr_pin : out std_logic_vector(15 downto 0);
    proc2fpga_0_bus2fpga_rdreq_pin : out std_logic;
    proc2fpga_0_bus2fpga_wrce_pin : out std_logic_vector(5 downto 0);
    proc2fpga_0_fpga2bus_wrack_pin : in std_logic;
    proc2fpga_0_bus2fpga_data_pin : out std_logic_vector(31 downto 0);
    proc2fpga_0_bus2fpga_rnw_pin : out std_logic;
    proc2fpga_0_bus2fpga_wrreq_pin : out std_logic;
    proc2fpga_0_fpga2bus_addrack_pin : in std_logic;
    proc2fpga_0_fpga2bus_rdack_pin : in std_logic;
    proc2fpga_0_bus2fpga_rdce_pin : out std_logic_vector(5 downto 0);
    proc2fpga_0_fpga2bus_error_pin : in std_logic;
    proc2fpga_0_fpga2bus_intr_pin : in std_logic_vector(15 downto 0);
    proc2fpga_0_fpga2bus_data_pin : in std_logic_vector(31 downto 0);
    proc2fpga_0_bus2fpga_reset_pin : out std_logic

);
END COMPONENT;

    signal depth               : std_logic_vector(15 downto 0);
    signal rec_rst             : std_logic;
    signal rec_polarity        : std_logic_vector(1 downto 0);
    signal rec_descramble      : std_logic_vector(1 downto 0);
    signal rec_rxeqmix         : t_cfg_array(1 downto 0);
    signal rec_data_valid      : std_logic_vector(1 downto 0);
    signal rec_enable          : std_logic_vector(1 downto 0);
    signal rec_input_select    : std_logic_vector(0 downto 0);
    signal rec_input_select_changed : std_logic;
    signal rec_stream_valid    : std_logic;
    signal trig_rst            : std_logic;
    signal trig_arm            : std_logic;
    signal trig_int            : std_logic;
    signal trig_type           : std_logic;
    signal trig_armed          : std_logic;
    signal trig_trigd          : std_logic;
    signal avg_rst             : std_logic;
    signal avg_width           : std_logic_vector(1 downto 0);
    signal avg_done            : std_logic;
    signal avg_active          : std_logic;
    signal avg_err             : std_logic;
    signal core_rst            : std_logic;
    signal core_start          : std_logic;
    signal core_n              : std_logic_vector(4 downto 0);
    signal core_scale_sch      : std_logic_vector(11 downto 0);
    signal core_scale_schi     : std_logic_vector(11 downto 0);
    signal core_scale_cmul     : std_logic_vector(1 downto 0);
    signal core_L              : std_logic_vector(11 downto 0);
    signal core_iq             : std_logic;
    signal core_circular       : std_logic;
    signal core_ov_fft         : std_logic;
    signal core_ov_ifft        : std_logic;
    signal core_ov_cmul        : std_logic;
    signal core_busy           : std_logic;
    signal core_done           : std_logic;
    signal tx_rst              : std_logic;
    signal tx_deskew           : std_logic;
    signal tx_dc_balance       : std_logic;
    signal tx_muli             : std_logic_vector(15 downto 0);
    signal tx_muli_wr          : std_logic;
    signal tx_mulq             : std_logic_vector(15 downto 0);
    signal tx_mulq_wr          : std_logic;
    signal tx_toggle_buf       : std_logic;
    signal tx_toggled          : std_logic;
    signal tx_frame_offset     : std_logic_vector(15 downto 0);
    signal tx_resync           : std_logic;
    signal tx_busy             : std_logic;
    signal tx_ovfl             : std_logic;
    signal tx_ovfl_ack         : std_logic;
    signal tx_shift            : std_logic_vector(1 downto 0);
    signal tx_shift_wr         : std_logic;
    signal tx_sat              : std_logic;

    signal mem_dinia           : std_logic_vector(15 downto 0);
    signal mem_addria          : std_logic_vector(15 downto 0);
    signal mem_weaia           : std_logic_vector(1 downto 0);
    signal mem_doutia          : std_logic_vector(15 downto 0);
    signal mem_enia            : std_logic;
    signal mem_dinib           : std_logic_vector(15 downto 0);
    signal mem_addrib          : std_logic_vector(15 downto 0);
    signal mem_weaib           : std_logic_vector(1 downto 0);
    signal mem_doutib          : std_logic_vector(15 downto 0);
    signal mem_enib            : std_logic;
    signal mem_dinh            : std_logic_vector(31 downto 0);
    signal mem_addrh           : std_logic_vector(15 downto 0);
    signal mem_weh             : std_logic_vector(3 downto 0);
    signal mem_douth           : std_logic_vector(31 downto 0);
    signal mem_enh             : std_logic;
    signal mem_dinoi           : std_logic_vector(31 downto 0);
    signal mem_addroi          : std_logic_vector(15 downto 0);
    signal mem_weoi            : std_logic_vector(3 downto 0);
    signal mem_doutoi          : std_logic_vector(31 downto 0);
    signal mem_enoi            : std_logic;
    signal mem_addroa          : std_logic_vector(15 downto 0);
    signal mem_doutoa          : std_logic_vector(31 downto 0);
    signal mem_enoa            : std_logic;

    signal fpga2bus_intr       : std_logic_vector(15 downto 0);
    signal reg_wrack           : std_logic;
    signal reg_rdack           : std_logic;
    signal reg_data            : std_logic_vector(31 downto 0);
    signal reg_error           : std_logic;

    signal mem_wrack           : std_logic;
    signal mem_rdack           : std_logic;
    signal mem_data            : std_logic_vector(31 downto 0);
    signal mem_error           : std_logic;

    signal fpga2bus_error      : std_logic;
    signal fpga2bus_wrack      : std_logic;
    signal fpga2bus_rdack      : std_logic;
    signal fpga2bus_data       : std_logic_vector(31 downto 0);
    signal fpga2bus_addrack    : std_logic;
    signal bus2fpga_wrreq      : std_logic;
    signal bus2fpga_rdreq      : std_logic;
    signal bus2fpga_burst      : std_logic;
    signal bus2fpga_wrce       : std_logic_vector(5 downto 0);
    signal bus2fpga_rdce       : std_logic_vector(5 downto 0);
    signal bus2fpga_be         : std_logic_vector(3 downto 0);
    signal bus2fpga_data       : std_logic_vector(31 downto 0);
    signal bus2fpga_rnw        : std_logic;
    signal bus2fpga_cs         : std_logic_vector(3 downto 0);
    signal bus2fpga_addr       : std_logic_vector(15 downto 0);
    signal bus2fpga_reset      : std_logic;
    signal bus2fpga_clk        : std_logic;
begin

    main_inst: entity work.main
    port map(
        rx_refclk_n         => gtx_refclk_n,
        rx_refclk_p         => gtx_refclk_p,
        rx_rxn              => gtx_rxn,
        rx_rxp              => gtx_rxp,
        rx_txn              => gtx_txn,
        rx_txp              => gtx_txp,
        depth               => depth,
        rec_rst             => rec_rst,
        rec_polarity        => rec_polarity,
        rec_descramble      => rec_descramble,
        rec_rxeqmix         => rec_rxeqmix,
        rec_data_valid      => rec_data_valid,
        rec_enable          => rec_enable,
        rec_input_select    => rec_input_select,
        rec_input_select_changed => rec_input_select_changed,
        rec_stream_valid    => rec_stream_valid,
        trig_rst            => trig_rst,
        trig_arm            => trig_arm,
        trig_ext            => inbuf_trigger,
        trig_int            => trig_int,
        trig_type           => trig_type,
        trig_armed          => trig_armed,
        trig_trigd          => trig_trigd,
        frame_clk           => frame_clk,
        avg_rst             => avg_rst,
        avg_width           => avg_width,
        avg_done            => avg_done,
        avg_active          => avg_active,
        avg_err             => avg_err,
        core_rst            => core_rst,
        core_start          => core_start,
        core_n              => core_n,
        core_scale_sch      => core_scale_sch,
        core_scale_schi     => core_scale_schi,
        core_scale_cmul     => core_scale_cmul,
        core_L              => core_L,
        core_iq             => core_iq,
        core_circular       => core_circular,
        core_ov_fft         => core_ov_fft,
        core_ov_ifft        => core_ov_ifft,
        core_ov_cmul        => core_ov_cmul,
        core_busy           => core_busy,
        core_done           => core_done,
        tx_txn              => oserdes_txn,
        tx_txp              => oserdes_txp,
        tx_txclkn           => oserdes_txclkn,
        tx_txclkp           => oserdes_txclkp,
        tx_rst              => tx_rst,
        tx_deskew           => tx_deskew,
        tx_dc_balance       => tx_dc_balance,
        tx_muli             => tx_muli,
        tx_muli_wr          => tx_muli_wr,
        tx_mulq             => tx_mulq,
        tx_mulq_wr          => tx_mulq_wr,
        tx_toggle_buf       => tx_toggle_buf,
        tx_toggled          => tx_toggled,
        tx_frame_offset     => tx_frame_offset,
        tx_resync           => tx_resync,
        tx_busy             => tx_busy,
        tx_ovfl             => tx_ovfl,
        tx_ovfl_ack         => tx_ovfl_ack,
        tx_sat              => tx_sat,
        tx_shift            => tx_shift,
        tx_shift_wr         => tx_shift_wr,

        sys_clk             => bus2fpga_clk,
        mem_dinia           => mem_dinia,
        mem_addria          => mem_addria,
        mem_weaia           => mem_weaia,
        mem_doutia          => mem_doutia,
        mem_enia            => mem_enia,
        mem_dinib           => mem_dinib,
        mem_addrib          => mem_addrib,
        mem_weaib           => mem_weaib,
        mem_doutib          => mem_doutib,
        mem_enib            => mem_enib,
        mem_dinh            => mem_dinh,
        mem_addrh           => mem_addrh,
        mem_weh             => mem_weh,
        mem_douth           => mem_douth,
        mem_enh             => mem_enh,
        mem_dinoi           => mem_dinoi,
        mem_addroi          => mem_addroi,
        mem_weoi            => mem_weoi,
        mem_doutoi          => mem_doutoi,
        mem_enoi            => mem_enoi,
        mem_addroa          => mem_addroa,
        mem_doutoa          => mem_doutoa,
        mem_enoa            => mem_enoa
    );


    inst_proc_register: entity work.proc_register
    port map(
        avg_active          => avg_active,
        avg_done            => avg_done,
        avg_err             => avg_err,
        avg_rst             => avg_rst,
        avg_width           => avg_width,
        core_L              => core_L,
        core_busy           => core_busy,
        core_circular       => core_circular,
        core_done           => core_done,
        core_iq             => core_iq,
        core_n              => core_n,
        core_ov_cmul        => core_ov_cmul,
        core_ov_fft         => core_ov_fft,
        core_ov_ifft        => core_ov_ifft,
        core_rst            => core_rst,
        core_scale_cmul     => core_scale_cmul,
        core_scale_sch      => core_scale_sch,
        core_scale_schi     => core_scale_schi,
        core_start          => core_start,
        depth               => depth,
        rec_data_valid      => rec_data_valid,
        rec_descramble      => rec_descramble,
        rec_enable          => rec_enable,
        rec_input_select    => rec_input_select,
        rec_input_select_changed => rec_input_select_changed,
        rec_polarity        => rec_polarity,
        rec_rst             => rec_rst,
        rec_rxeqmix         => rec_rxeqmix,
        rec_stream_valid    => rec_stream_valid,
        trig_arm            => trig_arm,
        trig_armed          => trig_armed,
        trig_int            => trig_int,
        trig_rst            => trig_rst,
        trig_trigd          => trig_trigd,
        trig_type           => trig_type,
        tx_busy             => tx_busy,
        tx_dc_balance       => tx_dc_balance,
        tx_deskew           => tx_deskew,
        tx_frame_offset     => tx_frame_offset,
        tx_muli             => tx_muli,
        tx_muli_wr          => tx_muli_wr,
        tx_mulq             => tx_mulq,
        tx_mulq_wr          => tx_mulq_wr,
        tx_ovfl             => tx_ovfl,
        tx_ovfl_ack         => tx_ovfl_ack,
        tx_resync           => tx_resync,
        tx_rst              => tx_rst,
        tx_sat              => tx_sat,
        tx_shift            => tx_shift,
        tx_shift_wr         => tx_shift_wr,
        tx_toggle_buf       => tx_toggle_buf,
        tx_toggled          => tx_toggled,

    ----- proc interface
        fpga2bus_intr       => fpga2bus_intr,
        fpga2bus_error      => reg_error,
        fpga2bus_wrack      => reg_wrack,
        fpga2bus_rdack      => reg_rdack,
        fpga2bus_data       => reg_data,
        bus2fpga_wrce       => bus2fpga_wrce,
        bus2fpga_rdce       => bus2fpga_rdce,
        bus2fpga_be         => bus2fpga_be,
        bus2fpga_data       => bus2fpga_data,
        bus2fpga_reset      => bus2fpga_reset,
        bus2fpga_clk        => bus2fpga_clk
    );

    inst_proc_memory: entity work.proc_memory
    port map(
        mem_dinia           => mem_dinia,
        mem_addria          => mem_addria,
        mem_weaia           => mem_weaia,
        mem_doutia          => mem_doutia,
        mem_enia            => mem_enia,
        mem_dinib           => mem_dinib,
        mem_addrib          => mem_addrib,
        mem_weaib           => mem_weaib,
        mem_doutib          => mem_doutib,
        mem_enib            => mem_enib,
        mem_dinh            => mem_dinh,
        mem_addrh           => mem_addrh,
        mem_weh             => mem_weh,
        mem_douth           => mem_douth,
        mem_enh             => mem_enh,
        mem_dinoi           => mem_dinoi,
        mem_addroi          => mem_addroi,
        mem_weoi            => mem_weoi,
        mem_doutoi          => mem_doutoi,
        mem_enoi            => mem_enoi,
        mem_addroa          => mem_addroa,
        mem_doutoa          => mem_doutoa,
        mem_enoa            => mem_enoa,

        fpga2bus_error      => mem_error,
        fpga2bus_wrack      => mem_wrack,
        fpga2bus_rdack      => mem_rdack,
        fpga2bus_data       => mem_data,
        fpga2bus_addrack    => fpga2bus_addrack,
        bus2fpga_wrreq      => bus2fpga_wrreq,
        bus2fpga_rdreq      => bus2fpga_rdreq,
        bus2fpga_burst      => bus2fpga_burst,
        bus2fpga_rnw        => bus2fpga_rnw,
        bus2fpga_cs         => bus2fpga_cs,
        bus2fpga_be         => bus2fpga_be,
        bus2fpga_data       => bus2fpga_data,
        bus2fpga_addr       => bus2fpga_addr,
        bus2fpga_reset      => bus2fpga_reset,
        bus2fpga_clk        => bus2fpga_clk
    );

    fpga2bus_wrack <= mem_wrack or reg_wrack;
    fpga2bus_rdack <= mem_rdack or reg_rdack;
    fpga2bus_data  <= reg_data when or_many(bus2fpga_rdce) = '1' else
                      mem_data when or_many(bus2fpga_cs) = '1' and bus2fpga_rnw = '1' else
                      (others => '0');
    fpga2bus_error <= mem_error or reg_error; 

    Inst_processor: processor PORT MAP(
		fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin    => fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin,
		fpga_0_RS232_Uart_1_sin_pin                 => fpga_0_RS232_Uart_1_sin_pin,
		fpga_0_RS232_Uart_1_sout_pin                => fpga_0_RS232_Uart_1_sout_pin,
		fpga_0_LEDs_8Bit_GPIO_IO_pin                => fpga_0_LEDs_8Bit_GPIO_IO_pin,
		fpga_0_LEDs_Positions_GPIO_IO_pin           => fpga_0_LEDs_Positions_GPIO_IO_pin,
		fpga_0_DDR2_SDRAM_DDR2_ODT_pin              => fpga_0_DDR2_SDRAM_DDR2_ODT_pin,
		fpga_0_DDR2_SDRAM_DDR2_A_pin                => fpga_0_DDR2_SDRAM_DDR2_A_pin,
		fpga_0_DDR2_SDRAM_DDR2_BA_pin               => fpga_0_DDR2_SDRAM_DDR2_BA_pin,
		fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin            => fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_CKE_pin              => fpga_0_DDR2_SDRAM_DDR2_CKE_pin,
		fpga_0_DDR2_SDRAM_DDR2_CS_N_pin             => fpga_0_DDR2_SDRAM_DDR2_CS_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin            => fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_WE_N_pin             => fpga_0_DDR2_SDRAM_DDR2_WE_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_CK_pin               => fpga_0_DDR2_SDRAM_DDR2_CK_pin,
		fpga_0_DDR2_SDRAM_DDR2_CK_N_pin             => fpga_0_DDR2_SDRAM_DDR2_CK_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_DM_pin               => fpga_0_DDR2_SDRAM_DDR2_DM_pin,
		fpga_0_DDR2_SDRAM_DDR2_DQS_pin              => fpga_0_DDR2_SDRAM_DDR2_DQS_pin,
		fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin            => fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin,
		fpga_0_DDR2_SDRAM_DDR2_DQ_pin               => fpga_0_DDR2_SDRAM_DDR2_DQ_pin,
		fpga_0_SysACE_CompactFlash_SysACE_CLK_pin   => fpga_0_SysACE_CompactFlash_SysACE_CLK_pin,
		fpga_0_SysACE_CompactFlash_SysACE_MPA_pin   => fpga_0_SysACE_CompactFlash_SysACE_MPA_pin,
		fpga_0_SysACE_CompactFlash_SysACE_MPD_pin   => fpga_0_SysACE_CompactFlash_SysACE_MPD_pin,
		fpga_0_SysACE_CompactFlash_SysACE_CEN_pin   => fpga_0_SysACE_CompactFlash_SysACE_CEN_pin,
		fpga_0_SysACE_CompactFlash_SysACE_OEN_pin   => fpga_0_SysACE_CompactFlash_SysACE_OEN_pin,
		fpga_0_SysACE_CompactFlash_SysACE_WEN_pin   => fpga_0_SysACE_CompactFlash_SysACE_WEN_pin,
		fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin => fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin,
		fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin => fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin     => fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin   => fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin  => fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin   => fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin   => fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin  => fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin   => fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin,
		fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin     => fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin,
		fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin   => fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin,
		fpga_0_Hard_Ethernet_MAC_MDC_0_pin          => fpga_0_Hard_Ethernet_MAC_MDC_0_pin,
		fpga_0_Hard_Ethernet_MAC_MDIO_0_pin         => fpga_0_Hard_Ethernet_MAC_MDIO_0_pin,
		fpga_0_clk_1_sys_clk_pin                    => fpga_0_clk_1_sys_clk_pin,
		fpga_0_rst_1_sys_rst_pin                    => fpga_0_rst_1_sys_rst_pin,
		proc2fpga_0_fpga2bus_intr_pin               => fpga2bus_intr,
		proc2fpga_0_fpga2bus_error_pin              => fpga2bus_error,
		proc2fpga_0_fpga2bus_wrack_pin              => fpga2bus_wrack,
		proc2fpga_0_fpga2bus_rdack_pin              => fpga2bus_rdack,
		proc2fpga_0_fpga2bus_data_pin               => fpga2bus_data,
		proc2fpga_0_fpga2bus_addrack_pin            => fpga2bus_addrack,
		proc2fpga_0_bus2fpga_wrreq_pin              => bus2fpga_wrreq,
		proc2fpga_0_bus2fpga_rdreq_pin              => bus2fpga_rdreq,
		proc2fpga_0_bus2fpga_burst_pin              => bus2fpga_burst,
		proc2fpga_0_bus2fpga_wrce_pin               => bus2fpga_wrce,
		proc2fpga_0_bus2fpga_rdce_pin               => bus2fpga_rdce,
		proc2fpga_0_bus2fpga_be_pin                 => bus2fpga_be,
		proc2fpga_0_bus2fpga_data_pin               => bus2fpga_data,
		proc2fpga_0_bus2fpga_rnw_pin                => bus2fpga_rnw,
		proc2fpga_0_bus2fpga_cs_pin                 => bus2fpga_cs,
		proc2fpga_0_bus2fpga_addr_pin               => bus2fpga_addr,
		proc2fpga_0_bus2fpga_reset_pin              => bus2fpga_reset,
		proc2fpga_0_bus2fpga_clk_pin                => bus2fpga_clk
    );

end Structural;

