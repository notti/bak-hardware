library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_SIGNED.ALL;
        use IEEE.STD_LOGIC_ARITH.ALL;
library std;
        use std.textio.all;
library work;
use work.all;

entity tb_toggle is
end tb_toggle;

architecture behav of tb_toggle is
    signal clka     : std_logic := '0';
    signal clkb     : std_logic := '0';
    signal toggle_in: std_logic := '0';
    signal toggle_out: std_logic;
    signal busy: std_logic;

begin
    
    clk_a: process
    begin
        clka <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process clk_a;

    clk_b: process
    begin
        clkb <= '1', '0' after 6 ns;
        wait for 12 ns;
    end process clk_b;
    
    process
    begin
        wait for 40 ns;
        toggle_in <= '1';
        wait for 10 ns;
        toggle_in <= '0';
        wait for 80 ns;
        toggle_in <= '1';
        wait for 100 ns;
        toggle_in <= '0';
        wait;
    end process;

    
    toggle_i: entity work.toggle
      port map(
        toggle_in => toggle_in,
        toggle_out => toggle_out,
        busy => busy,
        clk_from => clka,
        clk_to => clkb
            );
end behav;
