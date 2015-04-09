-------------------------------------------------------------------------------
-- processor_top.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity processor_top is
  port (
    fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    fpga_0_LEDs_Positions_GPIO_IO_pin : inout std_logic_vector(0 to 4);
    fpga_0_Push_Buttons_5Bit_GPIO_IO_pin : inout std_logic_vector(0 to 4);
    fpga_0_DIP_Switches_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
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
    fpga_0_IIC_EEPROM_Sda_pin : inout std_logic;
    fpga_0_IIC_EEPROM_Scl_pin : inout std_logic;
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
    proc2fpga_0_bus2fpga_clk_pin : out std_logic;
    proc2fpga_0_bus2fpga_reset_pin : out std_logic;
    proc2fpga_0_bus2fpga_addr_pin : out std_logic_vector(15 downto 0);
    proc2fpga_0_bus2fpga_cs_pin : out std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_rnw_pin : out std_logic;
    proc2fpga_0_bus2fpga_data_pin : out std_logic_vector(31 downto 0);
    proc2fpga_0_bus2fpga_be_pin : out std_logic_vector(3 downto 0);
    proc2fpga_0_bus2fpga_rdce_pin : out std_logic_vector(5 downto 0);
    proc2fpga_0_bus2fpga_wrce_pin : out std_logic_vector(5 downto 0);
    proc2fpga_0_bus2fpga_burst_pin : out std_logic;
    proc2fpga_0_bus2fpga_rdreq_pin : out std_logic;
    proc2fpga_0_bus2fpga_wrreq_pin : out std_logic;
    proc2fpga_0_fpga2bus_addrack_pin : in std_logic;
    proc2fpga_0_fpga2bus_data_pin : in std_logic_vector(31 downto 0);
    proc2fpga_0_fpga2bus_rdack_pin : in std_logic;
    proc2fpga_0_fpga2bus_wrack_pin : in std_logic;
    proc2fpga_0_fpga2bus_error_pin : in std_logic;
    proc2fpga_0_fpga2bus_intr_pin : in std_logic_vector(15 downto 0)
  );
end processor_top;

architecture STRUCTURE of processor_top is

  component processor is
    port (
      fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
      fpga_0_LEDs_Positions_GPIO_IO_pin : inout std_logic_vector(0 to 4);
      fpga_0_Push_Buttons_5Bit_GPIO_IO_pin : inout std_logic_vector(0 to 4);
      fpga_0_DIP_Switches_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
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
      fpga_0_IIC_EEPROM_Sda_pin : inout std_logic;
      fpga_0_IIC_EEPROM_Scl_pin : inout std_logic;
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
      proc2fpga_0_bus2fpga_clk_pin : out std_logic;
      proc2fpga_0_bus2fpga_reset_pin : out std_logic;
      proc2fpga_0_bus2fpga_addr_pin : out std_logic_vector(15 downto 0);
      proc2fpga_0_bus2fpga_cs_pin : out std_logic_vector(3 downto 0);
      proc2fpga_0_bus2fpga_rnw_pin : out std_logic;
      proc2fpga_0_bus2fpga_data_pin : out std_logic_vector(31 downto 0);
      proc2fpga_0_bus2fpga_be_pin : out std_logic_vector(3 downto 0);
      proc2fpga_0_bus2fpga_rdce_pin : out std_logic_vector(5 downto 0);
      proc2fpga_0_bus2fpga_wrce_pin : out std_logic_vector(5 downto 0);
      proc2fpga_0_bus2fpga_burst_pin : out std_logic;
      proc2fpga_0_bus2fpga_rdreq_pin : out std_logic;
      proc2fpga_0_bus2fpga_wrreq_pin : out std_logic;
      proc2fpga_0_fpga2bus_addrack_pin : in std_logic;
      proc2fpga_0_fpga2bus_data_pin : in std_logic_vector(31 downto 0);
      proc2fpga_0_fpga2bus_rdack_pin : in std_logic;
      proc2fpga_0_fpga2bus_wrack_pin : in std_logic;
      proc2fpga_0_fpga2bus_error_pin : in std_logic;
      proc2fpga_0_fpga2bus_intr_pin : in std_logic_vector(15 downto 0)
    );
  end component;

  attribute BUFFER_TYPE : STRING;
 attribute BOX_TYPE : STRING;
  attribute BUFFER_TYPE of fpga_0_SysACE_CompactFlash_SysACE_CLK_pin : signal is "BUFGP";
 attribute BOX_TYPE of processor : component is "user_black_box";

begin

  processor_i : processor
    port map (
      fpga_0_LEDs_8Bit_GPIO_IO_pin => fpga_0_LEDs_8Bit_GPIO_IO_pin,
      fpga_0_LEDs_Positions_GPIO_IO_pin => fpga_0_LEDs_Positions_GPIO_IO_pin,
      fpga_0_Push_Buttons_5Bit_GPIO_IO_pin => fpga_0_Push_Buttons_5Bit_GPIO_IO_pin,
      fpga_0_DIP_Switches_8Bit_GPIO_IO_pin => fpga_0_DIP_Switches_8Bit_GPIO_IO_pin,
      fpga_0_DDR2_SDRAM_DDR2_DQ_pin => fpga_0_DDR2_SDRAM_DDR2_DQ_pin,
      fpga_0_DDR2_SDRAM_DDR2_DQS_pin => fpga_0_DDR2_SDRAM_DDR2_DQS_pin,
      fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin => fpga_0_DDR2_SDRAM_DDR2_DQS_N_pin,
      fpga_0_DDR2_SDRAM_DDR2_A_pin => fpga_0_DDR2_SDRAM_DDR2_A_pin,
      fpga_0_DDR2_SDRAM_DDR2_BA_pin => fpga_0_DDR2_SDRAM_DDR2_BA_pin,
      fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin => fpga_0_DDR2_SDRAM_DDR2_RAS_N_pin,
      fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin => fpga_0_DDR2_SDRAM_DDR2_CAS_N_pin,
      fpga_0_DDR2_SDRAM_DDR2_WE_N_pin => fpga_0_DDR2_SDRAM_DDR2_WE_N_pin,
      fpga_0_DDR2_SDRAM_DDR2_CS_N_pin => fpga_0_DDR2_SDRAM_DDR2_CS_N_pin,
      fpga_0_DDR2_SDRAM_DDR2_ODT_pin => fpga_0_DDR2_SDRAM_DDR2_ODT_pin,
      fpga_0_DDR2_SDRAM_DDR2_CKE_pin => fpga_0_DDR2_SDRAM_DDR2_CKE_pin,
      fpga_0_DDR2_SDRAM_DDR2_DM_pin => fpga_0_DDR2_SDRAM_DDR2_DM_pin,
      fpga_0_DDR2_SDRAM_DDR2_CK_pin => fpga_0_DDR2_SDRAM_DDR2_CK_pin,
      fpga_0_DDR2_SDRAM_DDR2_CK_N_pin => fpga_0_DDR2_SDRAM_DDR2_CK_N_pin,
      fpga_0_SysACE_CompactFlash_SysACE_MPA_pin => fpga_0_SysACE_CompactFlash_SysACE_MPA_pin,
      fpga_0_SysACE_CompactFlash_SysACE_CLK_pin => fpga_0_SysACE_CompactFlash_SysACE_CLK_pin,
      fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin => fpga_0_SysACE_CompactFlash_SysACE_MPIRQ_pin,
      fpga_0_SysACE_CompactFlash_SysACE_CEN_pin => fpga_0_SysACE_CompactFlash_SysACE_CEN_pin,
      fpga_0_SysACE_CompactFlash_SysACE_OEN_pin => fpga_0_SysACE_CompactFlash_SysACE_OEN_pin,
      fpga_0_SysACE_CompactFlash_SysACE_WEN_pin => fpga_0_SysACE_CompactFlash_SysACE_WEN_pin,
      fpga_0_SysACE_CompactFlash_SysACE_MPD_pin => fpga_0_SysACE_CompactFlash_SysACE_MPD_pin,
      fpga_0_IIC_EEPROM_Sda_pin => fpga_0_IIC_EEPROM_Sda_pin,
      fpga_0_IIC_EEPROM_Scl_pin => fpga_0_IIC_EEPROM_Scl_pin,
      fpga_0_RS232_Uart_1_sin_pin => fpga_0_RS232_Uart_1_sin_pin,
      fpga_0_RS232_Uart_1_sout_pin => fpga_0_RS232_Uart_1_sout_pin,
      fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin => fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin,
      fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin,
      fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin => fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin,
      fpga_0_Hard_Ethernet_MAC_MDC_0_pin => fpga_0_Hard_Ethernet_MAC_MDC_0_pin,
      fpga_0_Hard_Ethernet_MAC_MDIO_0_pin => fpga_0_Hard_Ethernet_MAC_MDIO_0_pin,
      fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin => fpga_0_Hard_Ethernet_MAC_PHY_MII_INT_pin,
      fpga_0_clk_1_sys_clk_pin => fpga_0_clk_1_sys_clk_pin,
      fpga_0_rst_1_sys_rst_pin => fpga_0_rst_1_sys_rst_pin,
      proc2fpga_0_bus2fpga_clk_pin => proc2fpga_0_bus2fpga_clk_pin,
      proc2fpga_0_bus2fpga_reset_pin => proc2fpga_0_bus2fpga_reset_pin,
      proc2fpga_0_bus2fpga_addr_pin => proc2fpga_0_bus2fpga_addr_pin,
      proc2fpga_0_bus2fpga_cs_pin => proc2fpga_0_bus2fpga_cs_pin,
      proc2fpga_0_bus2fpga_rnw_pin => proc2fpga_0_bus2fpga_rnw_pin,
      proc2fpga_0_bus2fpga_data_pin => proc2fpga_0_bus2fpga_data_pin,
      proc2fpga_0_bus2fpga_be_pin => proc2fpga_0_bus2fpga_be_pin,
      proc2fpga_0_bus2fpga_rdce_pin => proc2fpga_0_bus2fpga_rdce_pin,
      proc2fpga_0_bus2fpga_wrce_pin => proc2fpga_0_bus2fpga_wrce_pin,
      proc2fpga_0_bus2fpga_burst_pin => proc2fpga_0_bus2fpga_burst_pin,
      proc2fpga_0_bus2fpga_rdreq_pin => proc2fpga_0_bus2fpga_rdreq_pin,
      proc2fpga_0_bus2fpga_wrreq_pin => proc2fpga_0_bus2fpga_wrreq_pin,
      proc2fpga_0_fpga2bus_addrack_pin => proc2fpga_0_fpga2bus_addrack_pin,
      proc2fpga_0_fpga2bus_data_pin => proc2fpga_0_fpga2bus_data_pin,
      proc2fpga_0_fpga2bus_rdack_pin => proc2fpga_0_fpga2bus_rdack_pin,
      proc2fpga_0_fpga2bus_wrack_pin => proc2fpga_0_fpga2bus_wrack_pin,
      proc2fpga_0_fpga2bus_error_pin => proc2fpga_0_fpga2bus_error_pin,
      proc2fpga_0_fpga2bus_intr_pin => proc2fpga_0_fpga2bus_intr_pin
    );

end architecture STRUCTURE;

