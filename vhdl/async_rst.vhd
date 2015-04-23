-----------------------------------------------------------
-- Generate rst from async
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity async_rst is
    generic(
        LENGTH              : integer := 4
    );
    port(
        clk                 : in  std_logic;
        rst_in              : in  std_logic;
        rst_out             : out std_logic
    );
end async_rst;

architecture Structural of async_rst is
    signal rst_line : std_logic_vector(LENGTH-1 downto 0);
begin

    rst_gen: process(clk, rst_in)
    begin
        if rst_in = '1' then
            rst_line <= (others => '1');
        elsif rising_edge(clk) then
            rst_line <= rst_line(LENGTH-2 downto 0) & '0';
        end if;
    end process rst_gen;

    rst_out <= rst_line(LENGTH-1);

end Structural;

