library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity flag is
port(
    flag_in  : in std_logic;
    flag_out : out std_logic;
    clk      : in std_logic
);
end flag;

architecture Structural of flag is
    signal s                        : std_logic_vector(1 downto 0);

    attribute ASYNC_REG             : string;
    attribute ASYNC_REG of s        : signal is "TRUE";
begin

process(clk)
begin
    if rising_edge(clk) then
        flag_out <= s(1);
        s <= s(0) & flag_in;
    end if;
end process;


end Structural;

