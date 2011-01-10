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
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library inbuf;
        use inbuf.all;
library outbuf;
        use outbuf.all;
library proc;
        use proc.all;

library misc;
	use misc.procedures.all;

entity top is
port(
-- signals for gtx transciever
        gtx_refclk_n            : in  std_logic;
        gtx_refclk_p            : in  std_logic;
        gtx_rxn                 : in  std_logic_vector(3 downto 0);
        gtx_rxp                 : in  std_logic_vector(3 downto 0);
        gtx_txn                 : out std_logic_vector(3 downto 0);
        gtx_txp                 : out std_logic_vector(3 downto 0);
-- signals for oserdes transmitter
        oserdes_txn             : out std_logic_vector(7 downto 0);
        oserdes_txp             : out std_logic_vector(7 downto 0);
        oserdes_txclkn          : out std_logic;
        oserdes_txclkp          : out std_logic;
-- signals for processor
        fpga_0_Hard_Ethernet_MAC_PHY_MII_INT        : IN std_logic;
        fpga_0_RS232_Uart_1_sin_pin                 : IN std_logic;
        fpga_0_SysACE_CompactFlash_SysACE_CLK_pin   : IN std_logic;
        fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : IN std_logic;
        fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin   : IN std_logic;
        fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin  : IN std_logic;
        fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin   : IN std_logic;
        fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin     : IN std_logic_vector(7 downto 0);
        fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin   : IN std_logic;
        sys_clk_pin                                 : IN std_logic;
        sys_rst_pin                                 : IN std_logic;
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
		fpga_0_Hard_Ethernet_MAC_PHY_MII_INT : IN std_logic;
		fpga_0_RS232_Uart_1_sin_pin : IN std_logic;
		fpga_0_SysACE_CompactFlash_SysACE_CLK_pin : IN std_logic;
		fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin : IN std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin : IN std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin : IN std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin : IN std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin : IN std_logic_vector(7 downto 0);
		fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin : IN std_logic;
		sys_clk_pin : IN std_logic;
		sys_rst_pin : IN std_logic;
		proc2fpga_0_mem_ip2bus_data_pin : IN std_logic_vector(31 downto 0);
		proc2fpga_0_mem_write_ack_pin : IN std_logic;
		proc2fpga_0_mem_read_ack_pin : IN std_logic;
		proc2fpga_0_reg_ip2bus_data_pin : IN std_logic_vector(31 downto 0);
		proc2fpga_0_bus_error_pin : IN std_logic;
		proc2fpga_0_intr_pin : IN std_logic_vector(31 downto 0);    
		fpga_0_DDR2_SDRAM_DDR2_DQS : INOUT std_logic_vector(7 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_DQS_N : INOUT std_logic_vector(7 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_DQ : INOUT std_logic_vector(63 downto 0);
		fpga_0_SysACE_CompactFlash_SysACE_MPD_pin : INOUT std_logic_vector(15 downto 0);
		fpga_0_Hard_Ethernet_MAC_MDIO_0_pin : INOUT std_logic;      
		fpga_0_RS232_Uart_1_sout_pin : OUT std_logic;
		fpga_0_DDR2_SDRAM_DDR2_ODT_pin : OUT std_logic_vector(1 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_A_pin : OUT std_logic_vector(12 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_BA_pin : OUT std_logic_vector(1 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin : OUT std_logic;
		fpga_0_DDR2_SDRAM_DDR2_CKE_pin : OUT std_logic_vector(0 to 0);
		fpga_0_DDR2_SDRAM_DDR2_CS_N_pin : OUT std_logic_vector(0 to 0);
		fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin : OUT std_logic;
		fpga_0_DDR2_SDRAM_DDR2_WE_N_pin : OUT std_logic;
		fpga_0_DDR2_SDRAM_DDR2_CK_pin : OUT std_logic_vector(1 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_CK_N_pin : OUT std_logic_vector(1 downto 0);
		fpga_0_DDR2_SDRAM_DDR2_DM_pin : OUT std_logic_vector(7 downto 0);
		fpga_0_SysACE_CompactFlash_SysACE_MPA_pin : OUT std_logic_vector(6 downto 0);
		fpga_0_SysACE_CompactFlash_SysACE_CEN_pin : OUT std_logic;
		fpga_0_SysACE_CompactFlash_SysACE_OEN_pin : OUT std_logic;
		fpga_0_SysACE_CompactFlash_SysACE_WEN_pin : OUT std_logic;
		fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin : OUT std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin : OUT std_logic_vector(7 downto 0);
		fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin : OUT std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin : OUT std_logic;
		fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin : OUT std_logic;
		fpga_0_Hard_Ethernet_MAC_MDC_0_pin : OUT std_logic;
		proc2fpga_0_mem_bus2ip_data_pin : OUT std_logic_vector(31 downto 0);
		proc2fpga_0_mem_address_pin : OUT std_logic_vector(15 downto 0);
		proc2fpga_0_mem_read_enable_pin : OUT std_logic;
		proc2fpga_0_mem_select_pin : OUT std_logic_vector(2 downto 0);
		proc2fpga_0_reg_bus2ip_data_pin : OUT std_logic_vector(31 downto 0);
		proc2fpga_0_reg_rd_pin : OUT std_logic_vector(7 downto 0);
		proc2fpga_0_reg_wr_pin : OUT std_logic_vector(7 downto 0);
		proc2fpga_0_bus_be_pin : OUT std_logic_vector(3 downto 0);
		proc2fpga_0_bus_reset_pin : OUT std_logic;
		proc2fpga_0_bus_clk_pin : OUT std_logic
		);
	END COMPONENT;

--inbuf
        signal inbuf_input_select_i : std_logic_vector(1 downto 0);
        signal inbuf_polarity_i     : std_logic_vector(2 downto 0);
        signal inbuf_descramble_i   : std_logic_vector(2 downto 0);
        signal inbuf_rxeqmix_i      : t_cfg_array(2 downto 0);
        signal inbuf_enable_i       : std_logic_vector(2 downto 0);
        signal inbuf_data_valid_i   : std_logic_vector(2 downto 0);
        signal inbuf_refclk_i       : std_logic;
        signal inbuf_reciever_clk_i : std_logic;
        signal inbuf_depth_i        : std_logic_vector(15 downto 0);
        signal inbuf_width_i        : std_logic_vector(1 downto 0);
        signal inbuf_start_i        : std_logic;
        signal inbuf_done_i         : std_logic;
        signal inbuf_clk_data_i     : std_logic;
        signal inbuf_addr_data_i    : std_logic_vector(15 downto 0);
        signal inbuf_datai_i        : std_logic_vector(15 downto 0);
        signal inbuf_dataq_i        : std_logic_vector(15 downto 0);
--outbuf
        signal outbuf_tx            : std_logic_vector(7 downto 0);
        signal outbuf_txclk         : std_logic;
        signal outbuf_clk_i         : std_logic;
--processor 
		signal proc2fpga_0_mem_ip2bus_data_pin : std_logic_vector(31 downto 0);
		signal proc2fpga_0_mem_write_ack_pin   : std_logic;
		signal proc2fpga_0_mem_read_ack_pin    : std_logic;
		signal proc2fpga_0_reg_ip2bus_data_pin : std_logic_vector(31 downto 0);
		signal proc2fpga_0_bus_error_pin       : std_logic;
		signal proc2fpga_0_intr_pin            : std_logic_vector(31 downto 0);    
		signal proc2fpga_0_mem_bus2ip_data_pin : std_logic_vector(31 downto 0);
		signal proc2fpga_0_mem_address_pin     : std_logic_vector(15 downto 0);
		signal proc2fpga_0_mem_read_enable_pin : std_logic;
		signal proc2fpga_0_mem_select_pin      : std_logic_vector(2 downto 0);
		signal proc2fpga_0_reg_bus2ip_data_pin : std_logic_vector(31 downto 0);
		signal proc2fpga_0_reg_rd_pin          : std_logic_vector(7 downto 0);
		signal proc2fpga_0_reg_wr_pin          : std_logic_vector(7 downto 0);
		signal proc2fpga_0_bus_be_pin          : std_logic_vector(3 downto 0);
		signal proc2fpga_0_bus_reset_pin       : std_logic;
		signal proc2fpga_0_bus_clk_pin         : std_logic;
begin

inbuf_refclk_ibufds_i : IBUFDS
port map
(
        O                   => inbuf_refclk_i,
        I                   => gtx_refclk_p,
        IB                  => gtx_refclk_n
);

inbuf_refclk_bufg_i: BUFG
port map
(
        I                   => inbuf_refclk_i,
        O                   => outbuf_clk_i
);


inbuf_i: entity inbuf.inbuf
port map(
        refclk              => inbuf_refclk_i,
        rst                 => proc2fpga_0_Bus_Reset_pin,
        rxn                 => gtx_rxn,
        rxp                 => gtx_rxp,
        txn                 => gtx_txn,
        txp                 => gtx_txp,
        rec_polarity        => inbuf_polarity_i,
        rec_descramble      => inbuf_descramble_i,
        rec_rxeqmix         => inbuf_rxeqmix_i,
        rec_data_valid      => inbuf_data_valid_i,
        rec_enable          => inbuf_enable_i,
        rec_input_select    => inbuf_input_select_i,
        rec_clk_out         => inbuf_reciever_clk_i,
        inbuf_depth         => inbuf_depth_i,
        inbuf_width         => inbuf_width_i,
        inbuf_start         => inbuf_start_i,
        inbuf_done          => inbuf_done_i,
        inbuf_clk_data      => inbuf_clk_data_i,
        inbuf_addr_data     => inbuf_addr_data_i,
        inbuf_datai         => inbuf_datai_i,
        inbuf_dataq         => inbuf_dataq_i
);

outbuf_i: entity outbuf.outbuf
port map(
        clk                 => outbuf_clk_i,
        rst                 => proc2fpga_0_Bus_Reset_pin,
        tx                  => outbuf_tx,
        txclk               => outbuf_txclk,
        bal                 => '0',
        ds_opt              => '0'
);

oserdes_tx_gen: for i in 0 to 7 generate
    oserdes_tx_obufds_i: OBUFDS
    generic map (
            IOSTANDARD  => "DEFAULT")
    port map(
            O           => oserdes_txp(i),
            OB          => oserdes_txn(i),
            I           => outbuf_tx(i)
    );
end generate;

oserdes_txclk_obufds_i: OBUFDS
generic map (
        IOSTANDARD  => "DEFAULT")
port map (
        O           => oserdes_txclkp,
        OB          => oserdes_txclkn,
        I           => outbuf_txclk
);

Inst_system: system PORT MAP(
    fpga_0_Hard_Ethernet_MAC_PHY_MII_INT => fpga_0_Hard_Ethernet_MAC_PHY_MII_INT,
    fpga_0_RS232_Uart_1_sin_pin => fpga_0_RS232_Uart_1_sin_pin,
    fpga_0_RS232_Uart_1_sout_pin => fpga_0_RS232_Uart_1_sout_pin,
    fpga_0_DDR2_SDRAM_DDR2_ODT_pin => fpga_0_DDR2_SDRAM_DDR2_ODT_pin,
    fpga_0_DDR2_SDRAM_DDR2_A_pin => fpga_0_DDR2_SDRAM_DDR2_A_pin,
    fpga_0_DDR2_SDRAM_DDR2_BA_pin => fpga_0_DDR2_SDRAM_DDR2_BA_pin,
    fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin => fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin,
    fpga_0_DDR2_SDRAM_DDR2_CKE_pin => fpga_0_DDR2_SDRAM_DDR2_CKE_pin,
    fpga_0_DDR2_SDRAM_DDR2_CS_N_pin => fpga_0_DDR2_SDRAM_DDR2_CS_N_pin,
    fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin => fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin,
    fpga_0_DDR2_SDRAM_DDR2_WE_N_pin => fpga_0_DDR2_SDRAM_DDR2_WE_N_pin,
    fpga_0_DDR2_SDRAM_DDR2_CK_pin => fpga_0_DDR2_SDRAM_DDR2_CK_pin,
    fpga_0_DDR2_SDRAM_DDR2_CK_N_pin => fpga_0_DDR2_SDRAM_DDR2_CK_N_pin,
    fpga_0_DDR2_SDRAM_DDR2_DM_pin => fpga_0_DDR2_SDRAM_DDR2_DM_pin,
    fpga_0_DDR2_SDRAM_DDR2_DQS => fpga_0_DDR2_SDRAM_DDR2_DQS,
    fpga_0_DDR2_SDRAM_DDR2_DQS_N => fpga_0_DDR2_SDRAM_DDR2_DQS_N,
    fpga_0_DDR2_SDRAM_DDR2_DQ => fpga_0_DDR2_SDRAM_DDR2_DQ,
    fpga_0_SysACE_CompactFlash_SysACE_CLK_pin => fpga_0_SysACE_CompactFlash_SysACE_CLK_pin,
    fpga_0_SysACE_CompactFlash_SysACE_MPA_pin => fpga_0_SysACE_CompactFlash_SysACE_MPA_pin,
    fpga_0_SysACE_CompactFlash_SysACE_MPD_pin => fpga_0_SysACE_CompactFlash_SysACE_MPD_pin,
    fpga_0_SysACE_CompactFlash_SysACE_CEN_pin => fpga_0_SysACE_CompactFlash_SysACE_CEN_pin,
    fpga_0_SysACE_CompactFlash_SysACE_OEN_pin => fpga_0_SysACE_CompactFlash_SysACE_OEN_pin,
    fpga_0_SysACE_CompactFlash_SysACE_WEN_pin => fpga_0_SysACE_CompactFlash_SysACE_WEN_pin,
    fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin => fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin,
    fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin => fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin,
    fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin,
    fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin,
    fpga_0_Hard_Ethernet_MAC_MDC_0_pin => fpga_0_Hard_Ethernet_MAC_MDC_0_pin,
    fpga_0_Hard_Ethernet_MAC_MDIO_0_pin => fpga_0_Hard_Ethernet_MAC_MDIO_0_pin,
    sys_clk_pin => sys_clk_pin,
    sys_rst_pin => sys_rst_pin,
    proc2fpga_0_mem_bus2ip_data_pin => proc2fpga_0_mem_bus2ip_data_pin,
    proc2fpga_0_mem_ip2bus_data_pin => proc2fpga_0_mem_ip2bus_data_pin,
    proc2fpga_0_mem_address_pin => proc2fpga_0_mem_address_pin,
    proc2fpga_0_mem_write_ack_pin => proc2fpga_0_mem_write_ack_pin,
    proc2fpga_0_mem_read_ack_pin => proc2fpga_0_mem_read_ack_pin,
    proc2fpga_0_mem_read_enable_pin => proc2fpga_0_mem_read_enable_pin,
    proc2fpga_0_mem_select_pin => proc2fpga_0_mem_select_pin,
    proc2fpga_0_reg_bus2ip_data_pin => proc2fpga_0_reg_bus2ip_data_pin,
    proc2fpga_0_reg_ip2bus_data_pin => proc2fpga_0_reg_ip2bus_data_pin,
    proc2fpga_0_reg_rd_pin => proc2fpga_0_reg_rd_pin,
    proc2fpga_0_reg_wr_pin => proc2fpga_0_reg_wr_pin,
    proc2fpga_0_bus_error_pin => proc2fpga_0_bus_error_pin,
    proc2fpga_0_bus_be_pin => proc2fpga_0_bus_be_pin,
    proc2fpga_0_bus_reset_pin => proc2fpga_0_bus_reset_pin,
    proc2fpga_0_bus_clk_pin => proc2fpga_0_bus_clk_pin,
    proc2fpga_0_intr_pin => proc2fpga_0_intr_pin
);

inst_status_reg: entity proc.status_reg
port map(
----- clk domain inbuf_reciever_clk_i
    inbuf_input_select           => inbuf_input_select_i,
    inbuf_polarity               => inbuf_polarity_i,
    inbuf_descramble             => inbuf_descramble_i,
    inbuf_rxeqmix                => inbuf_rxeqmix_i,
    inbuf_enable                 => inbuf_enable_i,
    inbuf_data_valid             => inbuf_data_valid_i,
    inbuf_depth                  => inbuf_depth_i,
    inbuf_width                  => inbuf_width_i,
    inbuf_start                  => inbuf_start_i,
    inbuf_done                   => inbuf_done_i,
    fpga_clk                     => inbuf_reciever_clk_i,

----- clk domain cpu
    inbuf_clk_data               => inbuf_clk_data_i,
    inbuf_addr_data              => inbuf_addr_data_i,
    inbuf_datai                  => inbuf_datai_i,
    inbuf_dataq                  => inbuf_dataq_i,

----- proc interface
    proc2fpga_0_intr_pin         => proc2fpga_0_intr_pin,
    proc2fpga_0_reg_ip2bus_data_pin => proc2fpga_0_reg_ip2bus_data_pin,
    proc2fpga_0_reg_bus2ip_data_pin => proc2fpga_0_reg_bus2ip_data_pin,
    proc2fpga_0_reg_rd_pin       => proc2fpga_0_reg_rd_pin,
    proc2fpga_0_reg_wr_pin       => proc2fpga_0_reg_wr_pin,
    proc2fpga_0_bus_be_pin       => proc2fpga_0_bus_be_pin,
    proc2fpga_0_bus_reset_pin    => proc2fpga_0_bus_reset_pin,
    proc2fpga_0_bus_clk_pin      => proc2fpga_0_bus_clk_pin
);

end Structural;

