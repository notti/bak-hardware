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

entity tb_outbuf is
end tb_outbuf;

architecture behav of tb_outbuf is
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal frame_clk    : std_logic := '0';
    signal txn          : std_logic_vector(7 downto 0);
    signal txp          : std_logic_vector(7 downto 0);
    signal txclkn       : std_logic;
    signal txclkp       : std_logic;
    signal depth        : std_logic_vector(15 downto 0) := X"000A";
    signal tx_deskew    : std_logic := '0';
    signal dc_balance   : std_logic := '0';
    signal muli         : std_logic_vector(15 downto 0) := X"7FFF";
    signal mulq         : std_logic_vector(15 downto 0) := X"0000";
    signal toggle_buf   : std_logic := '0';
    signal toggled      : std_logic;
    signal frame_offset : std_logic_vector(15 downto 0) := X"0000";
    signal resync       : std_logic := '0';
    signal busy			: std_logic;
    signal mem_dini     : std_logic_vector(31 downto 0) := X"00000000";
    signal mem_addri    : std_logic_vector(15 downto 0) := X"0000";
    signal mem_wei      : std_logic_vector(3 downto 0) := X"0";
    signal mem_douti    : std_logic_vector(31 downto 0);
    signal mem_addra    : std_logic_vector(15 downto 0) := X"0000";
    signal mem_douta    : std_logic_vector(31 downto 0);
begin
    
    clock: process
    begin
        clk <= '0', '1' after 5 ns;
        wait for 10 ns;
    end process clock;

    process
    begin
        mem_dini <= X"7FFF7FFF";
        mem_addri <= X"0000";
        mem_wei <= X"F";
        wait for 10 ns;
        mem_addri <= X"0001";
        wait for 10 ns;
        mem_addri <= X"0002";
        wait for 10 ns;
        mem_addri <= X"0003";
        wait for 10 ns;
        mem_addri <= X"0004";
        wait for 10 ns;
        mem_addri <= X"0005";
        wait for 10 ns;
        mem_addri <= X"0006";
        wait for 10 ns;
        mem_addri <= X"0007";
        wait for 10 ns;
        mem_addri <= X"0008";
        wait for 10 ns;
        mem_addri <= X"0009";
        wait for 10 ns;
        mem_wei <= X"0";
        rst <= '0';
        toggle_buf <= '1';
        wait for 10 ns;
        toggle_buf <= '0';

        wait for 1000 ns;
        assert false report "done" severity failure;
    end process;

    
    outbuf_i: entity work.outbuf
    port map(
        clk          => clk,
        rst          => rst,
        frame_clk    => frame_clk,
        txn          => txn,
        txp          => txp,
        txclkn       => txclkn,
        txclkp       => txclkp,
        depth        => depth,
        clk_en       => '1',
        data_enable  => '1',
        data_valid   => '1',
        data_zero    => '0',
        tx_deskew    => tx_deskew,
        dc_balance   => dc_balance,
        muli         => muli,
        mulq         => mulq,
        toggle_buf   => toggle_buf,
        toggled      => toggled,
        frame_offset => frame_offset,
        resync       => resync,
        busy         => busy,
        mem_clk      => clk,
        mem_dini     => mem_dini,
        mem_addri    => mem_addri,
        mem_wei      => mem_wei,
        mem_douti    => mem_douti,
        mem_addra    => mem_addra,
        mem_douta    => mem_douta
    );

end behav;
