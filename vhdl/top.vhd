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
-- signals for oserdes transmitter
    oserdes_txn                                 : out std_logic_vector(7 downto 0);
    oserdes_txp                                 : out std_logic_vector(7 downto 0);
    oserdes_txclkn                              : out std_logic;
    oserdes_txclkp                              : out std_logic
);
end top;

architecture Structural of top is
COMPONENT output_test is
  port (
    CLK : in STD_LOGIC := 'X'; 
    CONTROL : inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
    SYNC_OUT : out STD_LOGIC_VECTOR ( 23 downto 0 ) 
    );
END COMPONENT;
COMPONENT output_control is
  port (
    CLK : in STD_LOGIC := 'X'; 
    CONTROL : inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
    SYNC_OUT : out STD_LOGIC_VECTOR ( 3 downto 0 ) 
    );
END COMPONENT;
COMPONENT output_icon is
  port (
    CONTROL0 : inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
    CONTROL1 : inout STD_LOGIC_VECTOR ( 35 downto 0 ); 
    CONTROL2 : inout STD_LOGIC_VECTOR ( 35 downto 0 ) 
    );
END COMPONENT;

    signal refclk_unbuffered   : std_logic;
    signal clk                 : std_logic;
    signal e1                  : std_logic_vector(23 downto 0);
    signal e2                  : std_logic_vector(23 downto 0);
    signal control0            : std_logic_vector(35 downto 0);
    signal control1            : std_logic_vector(35 downto 0);
    signal control2            : std_logic_vector(35 downto 0);
    signal sync_out            : std_logic_vector(3 downto 0);
begin
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
        I                   => refclk_unbuffered,
        O                   => clk
    );

    output_test_1: output_test
    port map(
        CLK => clk,
        CONTROL => control0,
        SYNC_OUT => e1
    );

    output_test_2: output_test
    port map(
        CLK => clk,
        CONTROL => control1,
        SYNC_OUT => e2
    );

    output_control_0: output_control
    port map(
        CLK => clk,
        CONTROL => control2,
        SYNC_OUT => sync_out
    );

    output_icon_0: output_icon
    port map(
        CONTROL0 => control0,
        CONTROL1 => control1,
        CONTROL2 => control2
    );
    
    transmitter_i: entity work.transmitter
    port map(
        clk                 => clk,
        rst                 => sync_out(0),
        e1                  => e1,
        e2                  => e2,
        clk_en              => sync_out(1),
        txn                 => oserdes_txn,
        txp                 => oserdes_txp,
        txclkn              => oserdes_txclkn,
        txclkp              => oserdes_txclkp,
        deskew              => sync_out(2),
        dc_balance          => sync_out(3)
    );

end Structural;

