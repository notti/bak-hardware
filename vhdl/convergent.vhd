library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity convergent is
port(
    clk     : in  std_logic;
    a       : in  signed(31 downto 0);
    c       : out signed(15 downto 0)
);
end convergent;

architecture Structural of convergent is
    signal a_round : signed(16 downto 0);
    signal updown  : signed(16 downto 0);
begin
    updown(16 downto 1) <= (others => '0');
    updown(0) <= a(16) when a(14 downto 0) = "00000000000000" else
                 '1';
    a_round <= a(31 downto 15) + updown;

    reg: process(clk)
    begin
        if rising_edge(clk) then
            c <= a_round(16 downto 1);
        end if;
    end process;

end Structural;

