-----------------------------------------------------------
-- Project			: 
-- File				: outbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by				: 
-- last mod. on				: 
-- contents			: Output buffer
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
	width               : in  std_logic_vector(1 downto 0);
	mem_req             : in  std_logic;
	mem_ack             : out std_logic;
    tx_deskew_req       : in  std_logic;
    tx_deskew_ack       : out std_logic;
    rst_req             : in  std_logic;
    rst_ack             : out std_logic;
    frame_clk           : in  std_logic;
    clk                 : in  std_logic;

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
		enb: IN std_logic;
		web: IN std_logic_VECTOR(3 downto 0);
		doutb: OUT std_logic_VECTOR(31 downto 0));
	END COMPONENT;

    signal rst            : std_logic;
    signal mem            : std_logic;
    signal deskew_running : std_logic;
    signal deskew         : std_logic;
	signal web			  : std_logic_vector(3 downto 0);
	signal enb            : std_logic;
	signal addra		  : std_logic_vector(15 downto 0);
	signal depth_r		  : std_logic_vector(15 downto 0);
	signal douta		  : std_logic_vector(31 downto 0);
    signal rddly          : std_logic;
    signal wrdly          : std_logic;
    signal rd             : std_logic;
    signal wr             : std_logic;
begin
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst_req,
        flag_out     => rst,
        clk          => clk
    );
    rst_p: process(clk)
    begin
        if rising_edge(clk) then
            rst_ack <= rst_req;
        end if;
    end process;
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
        flag_in      => tx_deskew_req,
        flag_out     => deskew,
        clk          => clk
    );
    tx_deskew_ack <= deskew_running;

	reg_process: process(clk, depth, rst, bus2fpga_reset)
	begin
		if bus2fpga_reset = '1' then
			depth_r <= (others => '0');
		elsif rising_edge(clk) and rst = '1' then
			depth_r <= depth - 1;
		end if;
	end process reg_process;

	addra_process: process(clk, depth_r, rst)
	begin
		if rst = '1' then
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
		rst                 => rst,
		e1                  => douta(23 downto 0),
		e2					=> douta(23 downto 0),
		txn                 => txn,
		txp                 => txp,
		txclkn              => txclkn,
		txclkp              => txclkp,
		deskew              => deskew,
		deskew_running		=> deskew_running
	);

	genweb: for i in 0 to 3 generate
		web(i) <= '1' when bus2fpga_be(i) = '1' and bus2fpga_rnw = '0' and bus2fpga_cs = "1000" else '0';
	end generate;
	enb <= '1' when bus2fpga_cs = "1000" else '0';

	outbuf_mem_1: outbuf_mem
	port map (
		clka                => clk,
		dina                => (others => '0'),
		addra               => addra,
		wea                 => (others => '0'),
		douta               => douta,
		clkb                => bus2fpga_clk,
		dinb                => bus2fpga_data,
		addrb               => bus2fpga_addr,
		enb                 => enb,
		web                 => web,
		doutb               => fpga2bus_data
	);
    fpga2bus_error <= '0';
    rd <= '1' when bus2fpga_cs = "1000" and bus2fpga_rnw = '1' else '0';
    wr <= '1' when bus2fpga_cs = "1000" and bus2fpga_rnw = '0' else '0';
    rdack: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_cs, bus2fpga_rnw)
    begin
        if bus2fpga_reset = '1' then
            rddly <= '0';
        elsif rising_edge(bus2fpga_clk) then
            rddly <= rd;
        end if;
    end process;
    fpga2bus_rdack <= rddly;
    fpga2bus_wrack <= wr;

end Structural;

