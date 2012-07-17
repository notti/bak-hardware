library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
library std;
        use std.textio.all;
library work;
use work.all;

entity tb_proc_memory is
end tb_proc_memory;

architecture behav of tb_proc_memory is
    signal clk     : std_logic := '0';
    signal mem_dinia           : std_logic_vector(15 downto 0);
    signal mem_addria          : std_logic_vector(15 downto 0);
    signal mem_weaia           : std_logic;
    signal mem_doutia          : std_logic_vector(15 downto 0) := X"0000";
    signal mem_dinib           : std_logic_vector(15 downto 0);
    signal mem_addrib          : std_logic_vector(15 downto 0);
    signal mem_weaib           : std_logic;
    signal mem_doutib          : std_logic_vector(15 downto 0) := X"0000";
    signal mem_dinh            : std_logic_vector(31 downto 0);
    signal mem_addrh           : std_logic_vector(15 downto 0);
    signal mem_weh             : std_logic_vector(3 downto 0);
    signal mem_douth           : std_logic_vector(31 downto 0) := X"00000000";
    signal mem_dinoi           : std_logic_vector(31 downto 0);
    signal mem_addroi          : std_logic_vector(15 downto 0);
    signal mem_weoi            : std_logic_vector(3 downto 0);
    signal mem_doutoi          : std_logic_vector(31 downto 0) := X"00000000";
    signal mem_addroa          : std_logic_vector(15 downto 0);
    signal mem_doutoa          : std_logic_vector(31 downto 0) := X"00000000";
    signal fpga2bus_error      : std_logic;
    signal fpga2bus_wrack      : std_logic;
    signal fpga2bus_rdack      : std_logic;
    signal fpga2bus_data       : std_logic_vector(31 downto 0);
    signal bus2fpga_rnw        : std_logic := '0';
    signal bus2fpga_cs         : std_logic_vector(3 downto 0) := "0000";
    signal bus2fpga_be         : std_logic_vector(3 downto 0) := "0000";
    signal bus2fpga_data       : std_logic_vector(31 downto 0) := X"00000000";
    signal bus2fpga_addr       : std_logic_vector(15 downto 0) := X"0000";
    signal bus2fpga_reset      : std_logic := '1';

begin
    
    clk_p: process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process clk_p;
    
    process
    begin
        wait for 41 ns;
        bus2fpga_reset <= '0';
        wait for 10 ns;
        bus2fpga_rnw <= '0';
        bus2fpga_cs <= "1000";
        bus2fpga_be <= "0011";
        bus2fpga_addr <= X"000F";
        bus2fpga_data <= X"0A0A0A0A";
        wait until fpga2bus_wrack = '1';
        wait for 10 ns;
        bus2fpga_rnw <= '0';
        bus2fpga_cs <= "0000";
        wait for 10 ns;

        wait;
    end process;

    process
    begin
        wait until mem_addria = x"001E";
        wait for 20 ns;
        mem_doutia <= x"F0F0";
        wait for 10 ns;
        mem_doutia <= x"0000";
    end process;

    process
    begin
        wait until mem_addrib = x"001F";
        wait for 20 ns;
        mem_doutib <= x"F0F0";
        wait for 10 ns;
        mem_doutib <= x"0000";
    end process;

    mem_douth <= (others =>'0');
    mem_doutoa <= (others =>'0');
    mem_doutoi <= (others =>'0');

    
    proc_memory_i: entity work.proc_memory
      port map(
    mem_dinia           => mem_dinia,
    mem_addria          => mem_addria,
    mem_weaia           => mem_weaia,
    mem_doutia          => mem_doutia,
    mem_dinib           => mem_dinib,
    mem_addrib          => mem_addrib,
    mem_weaib           => mem_weaib,
    mem_doutib          => mem_doutib,
    mem_dinh            => mem_dinh,
    mem_addrh           => mem_addrh,
    mem_weh             => mem_weh,
    mem_douth           => mem_douth,
    mem_dinoi           => mem_dinoi,
    mem_addroi          => mem_addroi,
    mem_weoi            => mem_weoi,
    mem_doutoi          => mem_doutoi,
    mem_addroa          => mem_addroa,
    mem_doutoa          => mem_doutoa,
    fpga2bus_error      => fpga2bus_error,
    fpga2bus_wrack      => fpga2bus_wrack,
    fpga2bus_rdack      => fpga2bus_rdack,
    fpga2bus_data       => fpga2bus_data,
    bus2fpga_rnw        => bus2fpga_rnw,
    bus2fpga_cs         => bus2fpga_cs,
    bus2fpga_be         => bus2fpga_be,
    bus2fpga_data       => bus2fpga_data,
    bus2fpga_addr       => bus2fpga_addr,
    bus2fpga_reset      => bus2fpga_reset,
    bus2fpga_clk        => clk
    );
end behav;
