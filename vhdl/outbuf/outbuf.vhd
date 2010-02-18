-----------------------------------------------------------
-- Project			: 
-- File				: outbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: Output buffer
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library outbuf;
        use outbuf.all;

entity outbuf is
generic(
        CLK_FREQ            : integer := 100000000
);
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;

-- signals for selectio oserdes transmitter
        tx                  : out std_logic_vector(7 downto 0);
        txclk               : out std_logic;

-- control signals
        bal                 : in std_logic;
        ds_opt              : in std_logic
);
end outbuf;

architecture Structural of outbuf is
begin

transmitter_i: entity outbuf.transmitter
port map(
        clk                 => clk,
        rst                 => rst,
        tx                  => tx,
        txclk               => txclk,
        bal                 => bal,
        ds_opt              => ds_opt
);

end Structural;

