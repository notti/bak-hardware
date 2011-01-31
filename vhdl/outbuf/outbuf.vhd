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
        use IEEE.STD_LOGIC_SIGNED.ALL;
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
        txn                 : out std_ulogic_vector(7 downto 0);
        txp                 : out std_ulogic_vector(7 downto 0);
        txclkn              : out std_ulogic;
        txclkp              : out std_ulogic;

        deskew              : in std_logic
);
end outbuf;

architecture Structural of outbuf is
    signal e1       : std_logic_vector(23 downto 0);
    signal e2       : std_logic_vector(23 downto 0);
begin
    test: process(clk, rst)
    begin
        if rst = '1' then
            e1 <= (others => '0');
            e2 <= (others => '0');
        elsif clk'event and clk = '1' then
            e1 <= e1 + 1;
            e2 <= e2 + 1;
        end if;
    end process;

transmitter_i: entity outbuf.transmitter
port map(
        clk                 => clk,
        rst                 => rst,
		e1                  => e1,
		e2					=> e2,
        txn                 => txn,
        txp                 => txp,
        txclkn              => txclkn,
        txclkp              => txclkp,
        deskew              => deskew
);

end Structural;

