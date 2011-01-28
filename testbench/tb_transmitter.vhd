library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.all;

entity tb_transmitter is
end tb_transmitter;

architecture behav of tb_transmitter is
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal e1      : std_logic_vector(23 downto 0) := (others => '0');
    signal e2      : std_logic_vector(23 downto 0) := (others => '0');
    signal deskew  : std_logic := '0';
    signal txn: std_ulogic_vector(7 downto 0);
    signal txp: std_ulogic_vector(7 downto 0);
    signal txclk : std_ulogic;
begin
    
    clk_p: process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process clk_p;
    e1_p: process
    begin
        wait for 10 ns;
        e1 <= e1 + 1;
    end process;

    process
    begin
        wait for 100 ns;
        rst <= '0';

        wait;
    end process;
    
    transmitter_i: entity work.transmitter
    port map(
    clk => clk,
    rst => rst,
    e1 => e1,
    e2 => e2,
    deskew => deskew,
    txn => txn,
    txp => txp,
    txclk => txclk
    );

end behav;
