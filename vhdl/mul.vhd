library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity mul is
port(
    clk     : in  std_logic;
    a       : in  signed(15 downto 0);
    b       : in  signed(15 downto 0);
    c       : out signed(31 downto 0)
);
end mul;

architecture Structural of mul is
    signal a_1 : signed(15 downto 0);
    signal b_1 : signed(15 downto 0);
    signal mul : signed(31 downto 0);
    signal mul_1 : signed(31 downto 0);
    signal mul_2 : signed(31 downto 0);
begin

    mul <= a_1 * b_1;

    pipeline: process(clk)
    begin
        if rising_edge(clk) then
            a_1 <= a;
            b_1 <= b;
            mul_1 <= mul;
            mul_2 <= mul_1;
        end if;
    end process;

    c <= mul_2;

end Structural;

