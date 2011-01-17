library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library UNISIM;
use UNISIM.vcomponents.all;

library inbuf;
        use inbuf.all;

entity tb_average_mem is
end tb_average_mem;

architecture behav of tb_average_mem is
    signal clk          : std_logic;
    signal width        : std_logic_vector(1 downto 0);
    signal depth        : std_logic_vector(15 downto 0);
    signal arm          : std_logic;
    signal trigger      : std_logic;
    signal done         : std_logic;
    signal frame_clk    : std_logic;
    signal rst          : std_logic;
    signal data         : std_logic_vector(15 downto 0);
    signal stream_valid : std_logic;
    signal locked       : std_logic;
    signal clk_data     : std_logic;
	signal web          : std_logic;
    signal addr         : std_logic_vector(15 downto 0);
    signal dout         : std_logic_vector(15 downto 0);
    signal din          : std_logic_vector(15 downto 0);
begin
    
    width <= "10";
    depth <= X"0005";
    clk_data <= '0';
    web <= '0';
    addr <= (others => '0');
    addr <= (others => '0');
    din <= (others => '0');

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
        arm <= '0';
        trigger <= '0';
        rst <= '1';
        stream_valid <= '0';
        
        wait for 5 ns;

        wait for 30 ns;
        
        rst <= '0';

        wait for 30 ns;

        stream_valid <= '1';

        wait for 30 ns;

        trigger <= '1', '0' after 10 ns;
        
        wait for 100 ns;

        arm <= '1', '0' after 10 ns;

        wait for 100 ns;

        trigger <= '1', '0' after 10 ns;

        wait for 100 ns;
        
        trigger <= '1', '0' after 10 ns;
        
        wait for 100 ns;
        
        arm <= '1', '0' after 10 ns;
        
        wait for 100 ns;
        
        arm <= '1', '0' after 10 ns;

        wait;
    end process;
    
    average_mem_i: entity inbuf.average_mem
    port map(
    clk          => clk,
    width        => width,
    depth        => depth,
    arm          => arm,
    trigger      => trigger,
    done         => done,
    frame_clk    => frame_clk,
    rst          => rst,
    data         => data,
    stream_valid => stream_valid,
    locked       => locked,
    clk_data     => clk_data,
	web          =>	web,
    addr         => addr,
    dout         => dout,
    din          => din
    );

end behav;
