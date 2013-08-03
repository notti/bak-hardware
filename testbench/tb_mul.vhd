library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library work;
use work.all;

entity tb_mul is
end tb_mul;

architecture behav of tb_mul is
    signal clk     : std_logic := '0';
    signal a       : signed(15 downto 0) := "0000000000000000";
    signal b       : signed(15 downto 0) := "0000000000000000";
    signal c       : signed(31 downto 0) := "00000000000000000000000000000000";

begin
    
    process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process;

    process
    begin
        wait for 10 ns;
        a <= X"7FFF";
        wait for 10 ns;
        b <= X"7FFF";
        wait for 10 ns;
        a <= X"8000";
        wait for 10 ns;
        b <= X"8000";
        wait for 50 ns;
        assert false report "done" severity failure;
        wait;
    end process;

    mul_i: entity work.mul
    port map(
        clk  => clk,
        a => a,
        b => b,
        c => c
    );

    
end behav;
