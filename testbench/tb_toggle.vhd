library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library UNISIM;
use UNISIM.vcomponents.all;

library proc;
use proc.all;

entity tb_toggle is
end tb_toggle;

architecture behav of tb_toggle is
    signal toggle_in    : std_logic;
    signal toggle_out   : std_logic;
    signal clk_from     : std_logic;
    signal clk_to       : std_logic;
    signal rst          : std_logic;
begin
    
    clock_from: process
    begin
        wait for 1 ns;
        loop
            clk_from <= '0', '1' after 5 ns;
            wait for 10 ns;
        end loop;
    end process clock_from;
    clock_to: process
    begin
        wait for 3 ns;
        loop
            clk_to <= '0', '1' after 5 ns;
            wait for 10 ns;
        end loop;
    end process clock_to;

    process
    begin
        toggle_in <= '0';
        rst <= '1', '0' after 15 ns;
        
        wait for 6 ns;

        wait for 30 ns;

        toggle_in <= '1', '0' after 20 ns;

        wait for 50 ns;

        toggle_in <= '1', '0' after 20 ns;
        wait for 300 ns;
        toggle_in <= '1', '0' after 20 ns;
        wait for 300 ns;
        toggle_in <= '1';

        wait;
    end process;
    
    toggle_i: entity proc.toggle
    port map(
    rst => rst,
    toggle_in => toggle_in,
    toggle_out => toggle_out,
    clk_from => clk_from,
    clk_to => clk_to
    );

end behav;
