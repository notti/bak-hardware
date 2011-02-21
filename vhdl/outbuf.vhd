-----------------------------------------------------------
-- Project          : 
-- File             : outbuf.vhd
-- Author           : Gernot Vormayr
-- created          : July, 3rd 2009
-- last mod. by             : 
-- last mod. on             : 
-- contents         : Output buffer
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity outbuf is
port(
-- signals for selectio oserdes transmitter
    txn                 : out std_logic_vector(7 downto 0);
    txp                 : out std_logic_vector(7 downto 0);
    txclkn              : out std_logic;
    txclkp              : out std_logic;

    depth               : in  std_logic_vector(15 downto 0);
    depth_req           : in  std_logic;
    mem_req             : in  std_logic;
    mem_ack             : out std_logic;
    tx_deskew           : in  std_logic;
    rst                 : in  std_logic;
    frame_clk           : in  std_logic;
    dc_balance          : in  std_logic;
    clk                 : in  std_logic;
    pll_locked          : in  std_logic;
    muli                : in  std_logic_vector(15 downto 0);
    muli_req            : in  std_logic;
    mulq                : in  std_logic_vector(15 downto 0);
    mulq_req            : in  std_logic;
    toggle_buf          : in  std_logic;
    buf_used            : out std_logic;


    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    bus2fpga_rnw        : in  std_logic;
    bus2fpga_cs         : in  std_logic_vector(3 downto 0);
    bus2fpga_be         : in  std_logic_vector(3 downto 0);
    bus2fpga_data       : in  std_logic_vector(31 downto 0);
    bus2fpga_addr       : in  std_logic_vector(15 downto 0);
    bus2fpga_reset      : in  std_logic;
    bus2fpga_clk        : in  std_logic
);
end outbuf;

architecture Structural of outbuf is
    COMPONENT outbuf_mem IS
        port (
        clka: IN std_logic;
        dina: IN std_logic_VECTOR(31 downto 0);
        addra: IN std_logic_VECTOR(15 downto 0);
        wea: IN std_logic_VECTOR(3 downto 0);
        douta: OUT std_logic_VECTOR(31 downto 0);
        clkb: IN std_logic;
        dinb: IN std_logic_VECTOR(31 downto 0);
        addrb: IN std_logic_VECTOR(15 downto 0);
        web: IN std_logic_VECTOR(3 downto 0);
        doutb: OUT std_logic_VECTOR(31 downto 0));
    END COMPONENT;

    signal rst_i             : std_logic;
    signal mem               : std_logic;
    signal deskew            : std_logic;
    signal web_0             : std_logic_vector(3 downto 0);
    signal web_1             : std_logic_vector(3 downto 0);
    signal addra             : std_logic_vector(15 downto 0);
    signal depth_r           : std_logic_vector(15 downto 0);
    signal douta             : std_logic_vector(31 downto 0);
    signal douta_0           : std_logic_vector(31 downto 0);
    signal douta_1           : std_logic_vector(31 downto 0);
    signal doutb_0           : std_logic_vector(31 downto 0);
    signal doutb_1           : std_logic_vector(31 downto 0);
    signal rddly             : std_logic;
    signal rd                : std_logic;
    signal wr                : std_logic;
    signal rd_rq             : std_logic;
    signal rdackdly          : std_logic;
    signal rdackdly1         : std_logic;
    signal dc_balance_sync   : std_logic;
    signal buf_used_i        : std_logic;
    signal depth_synced      : std_logic;
    signal depth_synced_dly  : std_logic;
    signal depth_toggle      : std_logic;
    signal deskew_synced     : std_logic;
    signal deskew_synced_dly : std_logic;
    signal rst_synced        : std_logic;
    signal rst_synced_dly    : std_logic;
    signal rst_toggle        : std_logic;
    signal e1                : std_logic_vector(23 downto 0);
    signal e2                : std_logic_vector(23 downto 0);
begin
    sync_mem_i: entity work.flag
    port map(
        flag_in      => mem_req,
        flag_out     => mem,
        clk          => clk
    );
    mem_p: process(clk)
    begin
        if rising_edge(clk) then
            mem_ack <= mem;
        end if;
    end process;
    sync_deskew_i: entity work.flag
    port map(
        flag_in      => tx_deskew,
        flag_out     => deskew_synced,
        clk          => clk
    );
    deskew_dly: process(clk)
    begin
        if rising_edge(clk) then
            deskew_synced_dly <= deskew_synced;
        end if;
    end process;
    deskew <= deskew_synced_dly xor deskew_synced;
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst,
        flag_out     => rst_synced,
        clk          => clk
    );
    rst_dly: process(clk)
    begin
        if rising_edge(clk) then
            rst_synced_dly <= rst_synced;
        end if;
    end process;
    rst_toggle <= rst_synced_dly xor rst_synced;
    rst_i <= or_many(rst_toggle & bus2fpga_reset & (not pll_locked));
    
    sync_dc_balance: entity work.flag
    port map(
        flag_in      => dc_balance,
        flag_out     => dc_balance_sync,
        clk          => clk
    );
    sync_depth_i: entity work.flag
    port map(
        flag_in      => depth_req,
        flag_out     => depth_synced,
        clk          => clk
    );
    depth_dly: process(clk)
    begin
        if rising_edge(clk) then
            depth_synced_dly <= depth_synced;
        end if;
    end process;
    depth_toggle <= depth_synced_dly xor depth_synced;
    depth_r_p: process(clk, rst_i, depth_toggle, depth)
    begin
        if rst_i = '1' then
            depth_r <= (others => '0');
		elsif rising_edge(clk) then
            if depth_toggle = '1' then
                depth_r <= depth - 1;
            end if;
        end if;
    end process;

    addra_process: process(clk, depth_r, rst_i)
    begin
        if rst_i = '1' then
            addra <= (others => '0');
        elsif rising_edge(clk) then
			if addra = depth_r then
				addra <= (others => '0');
			else
				addra <= addra + 1;
			end if;
        end if;
    end process;

    transmitter_i: entity work.transmitter
    port map(
        clk                 => clk,
        rst                 => rst_i,
        e1                  => e1,
        e2                  => e2,
        txn                 => txn,
        txp                 => txp,
        txclkn              => txclkn,
        txclkp              => txclkp,
        deskew              => deskew,
        dc_balance          => dc_balance_sync
    );

    e2(0) <= '1'; --VALID
    e2(1) <= '1'; --ENABLE
    e2(2) <= '0'; --Marker_1
    e2(3) <= '0'; --reserved
    e2(7 downto 4) <= "0000";
    e2(23 downto 8) <= douta(15 downto 0);
    e1(0) <= '0'; --TRIGGER1
    e1(1) <= '0'; --TRIGGER2
    e1(2) <= '0'; --Marker_2
    e1(3) <= '0'; --reserved
    e1(7 downto 4) <= "0000";
    e1(23 downto 8) <= douta(31 downto 16);

    buf_used_i <= '0';

    douta <= douta_0 when buf_used_i = '0' else
             douta_1;

    genweb: for i in 0 to 3 generate
        web_0(i) <= '1' when bus2fpga_be(i) = '1' and bus2fpga_rnw = '0' and bus2fpga_cs = "0100" else '0';
        web_1(i) <= '1' when bus2fpga_be(i) = '1' and bus2fpga_rnw = '0' and bus2fpga_cs = "1000" else '0';
    end generate;

    outbuf_mem_0: outbuf_mem
    port map (
        clka                => clk,
        dina                => (others => '0'),
        addra               => addra,
        wea                 => (others => '0'),
        douta               => douta_0,
        clkb                => bus2fpga_clk,
        dinb                => bus2fpga_data,
        addrb               => bus2fpga_addr,
        web                 => web_0,
        doutb               => doutb_0
    );
    outbuf_mem_1: outbuf_mem
    port map (
        clka                => clk,
        dina                => (others => '0'),
        addra               => addra,
        wea                 => (others => '0'),
        douta               => douta_1,
        clkb                => bus2fpga_clk,
        dinb                => bus2fpga_data,
        addrb               => bus2fpga_addr,
        web                 => web_1,
        doutb               => doutb_1
    );
    fpga2bus_data <= doutb_0 when bus2fpga_cs = "0100" else
                     doutb_1;
    fpga2bus_error <= '0';
    rd <= '1' when (bus2fpga_cs = "1000" or bus2fpga_cs = "0100") and bus2fpga_rnw = '1' else '0';
    wr <= '1' when (bus2fpga_cs = "1000" or bus2fpga_cs = "0100") and bus2fpga_rnw = '0' else '0';
    rdack: process(bus2fpga_clk, bus2fpga_reset, rd)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rddly <= '0';
            else
                rddly <= rd;
            end if;
        end if;
    end process;
    rd_rq <= rd and not(rddly);
    rdack_dly: process(bus2fpga_clk, bus2fpga_reset, rd_rq)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rdackdly <= '0';
				rdackdly1 <= '0';
            else
                rdackdly <= rd_rq;
				rdackdly1 <= rdackdly;
            end if;
        end if;
    end process;
    fpga2bus_rdack <= rdackdly1;
    fpga2bus_wrack <= wr;

    buf_used <= buf_used_i;

end Structural;

