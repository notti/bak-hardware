-----------------------------------------------------------
-- Project			: 
-- File				: top.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: Top level entity
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
    gtx_rxn                                     : in  std_logic_vector(3 downto 0);
    gtx_rxp                                     : in  std_logic_vector(3 downto 0);
    gtx_txn                                     : out std_logic_vector(3 downto 0);
    gtx_txp                                     : out std_logic_vector(3 downto 0);
    inbuf_trigger                               : in  std_logic;
    push_south                                  : in  std_logic;
    frame_clk                                   : out std_logic;
-- signals for oserdes transmitter
    oserdes_txn                                 : out std_logic_vector(7 downto 0);
    oserdes_txp                                 : out std_logic_vector(7 downto 0);
    oserdes_txclkn                              : out std_logic;
    oserdes_txclkp                              : out std_logic;
-- signals for processor
    fpga_0_Hard_Ethernet_MAC_PHY_MII_INT        : IN  std_logic;
    fpga_0_RS232_Uart_1_sin_pin                 : IN  std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_CLK_pin   : IN  std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin   : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin  : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin   : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin     : IN  std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin   : IN  std_logic;
    sys_clk_pin                                 : IN  std_logic;
    sys_rst_pin                                 : IN  std_logic;
    fpga_0_DDR2_SDRAM_DDR2_DQS                  : INOUT std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_N                : INOUT std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQ                   : INOUT std_logic_vector(63 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPD_pin   : INOUT std_logic_vector(15 downto 0);
    fpga_0_Hard_Ethernet_MAC_MDIO_0_pin         : INOUT std_logic;
    fpga_0_RS232_Uart_1_sout_pin                : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_ODT_pin              : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_A_pin                : OUT std_logic_vector(12 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_BA_pin               : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin            : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CKE_pin              : OUT std_logic_vector(0 to 0);
    fpga_0_DDR2_SDRAM_DDR2_CS_N_pin             : OUT std_logic_vector(0 to 0);
    fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin            : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_WE_N_pin             : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CK_pin               : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_N_pin             : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DM_pin               : OUT std_logic_vector(7 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPA_pin   : OUT std_logic_vector(6 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_CEN_pin   : OUT std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_OEN_pin   : OUT std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_WEN_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin     : OUT std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin  : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_MDC_0_pin          : OUT std_logic
);
end top;

architecture Structural of top is
COMPONENT system
PORT(
    fpga_0_Hard_Ethernet_MAC_PHY_MII_INT        : IN  std_logic;
    fpga_0_RS232_Uart_1_sin_pin                 : IN  std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_CLK_pin   : IN  std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin   : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin  : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin   : IN  std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin     : IN  std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin   : IN  std_logic;
    sys_clk_pin                                 : IN  std_logic;
    sys_rst_pin                                 : IN  std_logic;
    proc2fpga_0_fpga2bus_intr_pin               : IN  std_logic_vector(31 downto 0);
    proc2fpga_0_fpga2bus_error_pin              : IN  std_logic;
    proc2fpga_0_fpga2bus_wrack_pin              : IN  std_logic;
    proc2fpga_0_fpga2bus_rdack_pin              : IN  std_logic;
    proc2fpga_0_fpga2bus_data_pin               : IN  std_logic_vector(31 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS                  : INOUT std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQS_N                : INOUT std_logic_vector(7 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DQ                   : INOUT std_logic_vector(63 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPD_pin   : INOUT std_logic_vector(15 downto 0);
    fpga_0_Hard_Ethernet_MAC_MDIO_0_pin         : INOUT std_logic;
    fpga_0_RS232_Uart_1_sout_pin                : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_ODT_pin              : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_A_pin                : OUT std_logic_vector(12 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_BA_pin               : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin            : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CKE_pin              : OUT std_logic_vector(0 to 0);
    fpga_0_DDR2_SDRAM_DDR2_CS_N_pin             : OUT std_logic_vector(0 to 0);
    fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin            : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_WE_N_pin             : OUT std_logic;
    fpga_0_DDR2_SDRAM_DDR2_CK_pin               : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_CK_N_pin             : OUT std_logic_vector(1 downto 0);
    fpga_0_DDR2_SDRAM_DDR2_DM_pin               : OUT std_logic_vector(7 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_MPA_pin   : OUT std_logic_vector(6 downto 0);
    fpga_0_SysACE_CompactFlash_SysACE_CEN_pin   : OUT std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_OEN_pin   : OUT std_logic;
    fpga_0_SysACE_CompactFlash_SysACE_WEN_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin     : OUT std_logic_vector(7 downto 0);
    fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin  : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin   : OUT std_logic;
    fpga_0_Hard_Ethernet_MAC_MDC_0_pin          : OUT std_logic;
    proc2fpga_0_bus2fpga_wrce_pin               : OUT std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_rdce_pin               : OUT std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_be_pin                 : OUT std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_data_pin               : OUT std_logic_vector(31 downto 0);
    proc2fpga_0_bus2fpga_rnw_pin                : OUT std_logic;
    proc2fpga_0_bus2fpga_cs_pin                 : OUT std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_addr_pin               : OUT std_logic_vector(15 downto 0);
    proc2fpga_0_bus2fpga_reset_pin              : OUT std_logic;
    proc2fpga_0_bus2fpga_clk_pin                : OUT std_logic
    );
END COMPONENT;

--inbuf
    signal rx_polarity       : std_logic_vector(2 downto 0);
    signal rx_descramble     : std_logic_vector(2 downto 0);
    signal rx_rxeqmix        : t_cfg_array(2 downto 0);
    signal rx_data_valid     : std_logic_vector(2 downto 0);
    signal rx_enable         : std_logic_vector(2 downto 0);
    signal rx_input_select   : std_logic_vector(1 downto 0);
    signal rx_input_select_req : std_logic;
    signal rx_stream_valid   : std_logic;
    signal depth             : std_logic_vector(15 downto 0);
    signal depth_req         : std_logic;
    signal width             : std_logic_vector(1 downto 0);
    signal width_req         : std_logic;
    signal arm               : std_logic;
    signal rx_rst            : std_logic;
    signal avg_done          : std_logic;
    signal locked            : std_logic;
    signal mem_req           : std_logic;
    signal inbuf_mem_ack     : std_logic;
    signal inbuf_wrack       : std_logic;
    signal inbuf_rdack       : std_logic;
    signal inbuf_data        : std_logic_vector(31 downto 0);
    signal inbuf_error       : std_logic;
    signal frame_clk_i       : std_logic;
    signal sample_clk        : std_logic;
    signal refclk_unbuffered : std_logic;
    signal refclk            : std_logic;
    signal pll_locked        : std_logic;
--outbuf
    signal tx_deskew         : std_logic;
    signal tx_rst            : std_logic;
    signal dc_balance        : std_logic;
    signal muli              : std_logic_vector(15 downto 0);
    signal muli_req          : std_logic;
    signal mulq              : std_logic_vector(15 downto 0);
    signal mulq_req          : std_logic;
    signal buf_used          : std_logic;
    signal toggle_buf        : std_logic;
    signal outbuf_mem_ack    : std_logic;
    signal outbuf_wrack      : std_logic;
    signal outbuf_rdack      : std_logic;
    signal outbuf_data       : std_logic_vector(31 downto 0);
    signal outbuf_error      : std_logic;
--proc2fpga
    signal mem_ack           : std_logic;
    signal proc2fpga_wrack   : std_logic;
    signal proc2fpga_rdack   : std_logic;
    signal proc2fpga_data    : std_logic_vector(31 downto 0);
    signal proc2fpga_error   : std_logic;
--processor 
    signal fpga2bus_intr     : std_logic_vector(31 downto 0);
    signal fpga2bus_error    : std_logic;
    signal fpga2bus_wrack    : std_logic;
    signal fpga2bus_rdack    : std_logic;
    signal fpga2bus_data     : std_logic_vector(31 downto 0);
    signal bus2fpga_wrce     : std_logic_vector(3 downto 0);
    signal bus2fpga_rdce     : std_logic_vector(3 downto 0);
    signal bus2fpga_be       : std_logic_vector(3 downto 0);
    signal bus2fpga_data     : std_logic_vector(31 downto 0);
    signal bus2fpga_rnw      : std_logic;
    signal bus2fpga_cs       : std_logic_vector(3 downto 0);
    signal bus2fpga_addr     : std_logic_vector(15 downto 0);
    signal bus2fpga_reset    : std_logic;
    signal bus2fpga_clk      : std_logic;
    signal in_trigger        : std_logic;

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of Structural: architecture is "yes";
begin

    in_trigger <= inbuf_trigger or push_south;

    inbuf_refclkbufds_i : IBUFDS
    port map
    (
        O                   => refclk_unbuffered,
        I                   => gtx_refclk_p,
        IB                  => gtx_refclk_n
    );

    refclk_bufg_i : BUFG
    port map
    (
        I                   =>      refclk_unbuffered,
        O                   =>      refclk
    );


    inst_inbuf: entity work.inbuf
    port map(
        refclk              => refclk,
        rxn                 => gtx_rxn,
        rxp                 => gtx_rxp,
        txn                 => gtx_txn,
        txp                 => gtx_txp,
        trigger             => in_trigger,
        frame_clk           => frame_clk_i,

        rec_polarity        => rx_polarity,
        rec_descramble      => rx_descramble,
        rec_rxeqmix         => rx_rxeqmix,
        rec_data_valid      => rx_data_valid,
        rec_enable          => rx_enable,
        rec_input_select    => rx_input_select,
        rec_input_select_req => rx_input_select_req,
        rec_stream_valid    => rx_stream_valid,
        depth               => depth,
        depth_req           => depth_req,
        width               => width,
        width_req           => width_req,
        arm                 => arm,
        rst                 => rx_rst,
        avg_done            => avg_done,
        locked              => locked,
        mem_req             => mem_req,
        mem_ack             => inbuf_mem_ack,

        sample_clk          => sample_clk,
        pll_locked          => pll_locked,

        fpga2bus_error      => inbuf_error,
        fpga2bus_wrack      => inbuf_wrack,
        fpga2bus_rdack      => inbuf_rdack,
        fpga2bus_data       => inbuf_data,
        bus2fpga_rnw        => bus2fpga_rnw,
        bus2fpga_cs         => bus2fpga_cs,
        bus2fpga_be         => bus2fpga_be,
        bus2fpga_data       => bus2fpga_data,
        bus2fpga_addr       => bus2fpga_addr,
        bus2fpga_reset      => bus2fpga_reset,
        bus2fpga_clk        => bus2fpga_clk
    );

    inst_outbuf: entity work.outbuf
    port map(
        txn                 => oserdes_txn,
        txp                 => oserdes_txp,
        txclkn              => oserdes_txclkn,
        txclkp              => oserdes_txclkp,
        depth               => depth,
        depth_req           => depth_req,
        mem_req             => mem_req,
        mem_ack             => outbuf_mem_ack,
        tx_deskew           => tx_deskew,
        rst                 => tx_rst,
        frame_clk           => frame_clk_i,
        dc_balance          => dc_balance,
        clk                 => sample_clk,
        pll_locked          => pll_locked,
        muli                => muli,
        muli_req            => muli_req,
        mulq                => mulq,
        mulq_req            => mulq_req,
        toggle_buf          => toggle_buf,
        buf_used            => buf_used,

        fpga2bus_error      => outbuf_error,
        fpga2bus_wrack      => outbuf_wrack,
        fpga2bus_rdack      => outbuf_rdack,
        fpga2bus_data       => outbuf_data,
        bus2fpga_rnw        => bus2fpga_rnw,
        bus2fpga_cs         => bus2fpga_cs,
        bus2fpga_be         => bus2fpga_be,
        bus2fpga_data       => bus2fpga_data,
        bus2fpga_addr       => bus2fpga_addr,
        bus2fpga_reset      => bus2fpga_reset,
        bus2fpga_clk        => bus2fpga_clk
    );

    inst_proc2fpga: entity work.proc2fpga
    port map(
    ----- clk domain inbuf_reciever_clk_i
        rx_polarity          => rx_polarity,
        rx_descramble        => rx_descramble,
        rx_rxeqmix           => rx_rxeqmix,
        rx_data_valid        => rx_data_valid,
        rx_enable            => rx_enable,
        rx_input_select      => rx_input_select,
        rx_input_select_req  => rx_input_select_req,
        rx_stream_valid      => rx_stream_valid,
        depth                => depth,
        depth_req            => depth_req,
        width                => width,
        width_req            => width_req,
        arm                  => arm,
        rx_rst               => rx_rst,
        tx_rst               => tx_rst,
        avg_done             => avg_done,
        locked               => locked,
        tx_deskew            => tx_deskew,
        mem_req              => mem_req,
        mem_ack              => mem_ack,
        dc_balance           => dc_balance,
        muli                 => muli,
        muli_req             => muli_req,
        mulq                 => mulq,
        mulq_req             => mulq_req,
        buf_used             => buf_used,
        toggle_buf           => toggle_buf,

    ----- proc interface
        fpga2bus_intr        => fpga2bus_intr,
        fpga2bus_error       => proc2fpga_error,
        fpga2bus_wrack       => proc2fpga_wrack,
        fpga2bus_rdack       => proc2fpga_rdack,
        fpga2bus_data        => proc2fpga_data,
        bus2fpga_wrce        => bus2fpga_wrce,
        bus2fpga_rdce        => bus2fpga_rdce,
        bus2fpga_be          => bus2fpga_be,
        bus2fpga_data        => bus2fpga_data,
        bus2fpga_addr        => bus2fpga_addr,
        bus2fpga_reset       => bus2fpga_reset,
        bus2fpga_clk         => bus2fpga_clk
    );

    fpga2bus_wrack <= or_many(outbuf_wrack & inbuf_wrack & proc2fpga_wrack);
    fpga2bus_rdack <= or_many(outbuf_rdack & inbuf_rdack & proc2fpga_rdack);
    fpga2bus_data  <= proc2fpga_data when or_many(bus2fpga_rdce) = '1' else
                      inbuf_data when bus2fpga_cs = "0001" else
                      outbuf_data when bus2fpga_cs = "0100" or bus2fpga_cs = "1000" else
                      (others => '0');
    fpga2bus_error <= inbuf_error or outbuf_error or proc2fpga_error;
    mem_ack <= inbuf_mem_ack and outbuf_mem_ack;

    Inst_system: system PORT MAP(
        fpga_0_Hard_Ethernet_MAC_PHY_MII_INT        => fpga_0_Hard_Ethernet_MAC_PHY_MII_INT,
        fpga_0_RS232_Uart_1_sin_pin                 => fpga_0_RS232_Uart_1_sin_pin,
        fpga_0_RS232_Uart_1_sout_pin                => fpga_0_RS232_Uart_1_sout_pin,
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
        fpga_0_DDR2_SDRAM_DDR2_DQS                  => fpga_0_DDR2_SDRAM_DDR2_DQS,
        fpga_0_DDR2_SDRAM_DDR2_DQS_N                => fpga_0_DDR2_SDRAM_DDR2_DQS_N,
        fpga_0_DDR2_SDRAM_DDR2_DQ                   => fpga_0_DDR2_SDRAM_DDR2_DQ,
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
        sys_clk_pin                                 => sys_clk_pin,
        sys_rst_pin                                 => sys_rst_pin,
        proc2fpga_0_fpga2bus_intr_pin               => fpga2bus_intr,
        proc2fpga_0_fpga2bus_error_pin              => fpga2bus_error,
        proc2fpga_0_fpga2bus_wrack_pin              => fpga2bus_wrack,
        proc2fpga_0_fpga2bus_rdack_pin              => fpga2bus_rdack,
        proc2fpga_0_fpga2bus_data_pin               => fpga2bus_data,
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

    frame_clk <= frame_clk_i;

end Structural;

