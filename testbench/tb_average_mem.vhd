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

entity tb_average_mem is
end tb_average_mem;

architecture behav of tb_average_mem is
    signal clk          : std_logic;
    signal width        : std_logic_vector(1 downto 0);
    signal depth        : std_logic_vector(15 downto 0);
    signal trig         : std_logic;
    signal done         : std_logic;
    signal rst          : std_logic;
    signal active       : std_logic;
    signal err          : std_logic;
    signal data_valid   : std_logic := '1';
    signal data         : std_logic_vector(15 downto 0);
begin
    
    depth <= X"0005";

    clock: process
    begin
        clk <= '0', '1' after 5 ns;
        wait for 10 ns;
    end process clock;

    d: process(rst, clk, data)
    begin
        if rst = '1' then
            data <= X"0000";
        elsif clk'event and clk = '1' then
            data <= data + 1;
        end if;
    end process d;

    process
        variable l : line;
    begin
        width <= "10";
        trig <= '0';
        rst <= '1';
        
        wait for 5 ns;

        wait for 30 ns;
        
        rst <= '0';

        wait for 29 ns;

        trig <= '1', '0' after 10 ns;
        
        wait for 100 ns;

        trig <= '1', '0' after 10 ns;

        wait for 100 ns;
        
        trig <= '1', '0' after 10 ns;

        wait for 100 ns;
        width <= "00";
        trig <= '1' , '0' after 10 ns;

        wait for 100 ns;
        
        trig <= '1', '0' after 10 ns;
        
        wait for 100 ns;
        assert false report "stop" severity failure;
    end process;
    
    average_mem_i: entity work.average_mem
    port map(
    clk          => clk,
    rst          => rst,
    width        => width,
    depth        => depth,
    trig         => trig,
    done         => done,
    active       => active,
    err          => err,
    data         => data,
    data_valid   => data_valid,
    memclk       => clk,
    ext          => '0',
    dina         => (others => '0'),
    addra        => (others => '0'),
    wea          => "00",
    douta        => open,
    dinb         => (others => '0'),
    addrb        => (others => '0'),
    web          => "00",
    doutb        => open
    );

end behav;
