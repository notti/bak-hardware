-----------------------------------------------------------
-- Project			: 
-- File				: average_mem.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Average Buffer
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library inbuf;
        use inbuf.all;

entity average_mem is
port(
    clk     : in std_logic;
    clk2x   : in std_logic;

    pos     : in std_logic_vector(15 downto 0);
    width   : in std_logic_vector(1 downto 0);
    sample  : in std_logic;
    datai   : in std_logic_vector(15 downto 0);
    dataq   : in std_logic_vector(15 downto 0);

    clk_data: in std_logic;
    addr    : in std_logic_vector(15 downto 0);
    douti   : out std_logic_vector(15 downto 0);
    doutq   : out std_logic_vector(15 downto 0)
);
end average_mem;

architecture Structural of average_mem is

component inbuf_mem IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(37 downto 0);
	addra: IN std_logic_VECTOR(15 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(37 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(37 downto 0);
	addrb: IN std_logic_VECTOR(15 downto 0);
	web: IN std_logic_VECTOR(0 downto 0);
	doutb: OUT std_logic_VECTOR(37 downto 0));
END component;

    signal wea_i      : std_logic_vector(0 downto 0);
    signal datai_avg  : std_logic_vector(18 downto 0);
    signal dataq_avg  : std_logic_vector(18 downto 0);
    signal dina_i     : std_logic_vector(37 downto 0);
    signal douta_i    : std_logic_vector(37 downto 0);
    signal doutb_i    : std_logic_vector(37 downto 0);

begin

    -- read on negative edge and write on positive edge
    wea_i(0)   <=  (not clk) and sample;

    -- 01234567890123456789012345678901234567
    -- <     datai    ><A><     datai    ><A>

    datai_avg <= std_logic_vector(unsigned(douta_i(18 downto 0)) + unsigned("000" & datai(15 downto 0)));
    dataq_avg <= std_logic_vector(unsigned(douta_i(37 downto 19)) + unsigned("000" & dataq(15 downto 0)));

    dina_i <= (datai_avg & dataq_avg);

    multiplexer: process(doutb_i, width)
    begin
        case width is
            when "01"   => douti <= doutb_i(16 downto 1); doutq <= doutb_i(35 downto 20);
            when "10"   => douti <= doutb_i(17 downto 2); doutq <= doutb_i(36 downto 21);
            when "11"   => douti <= doutb_i(18 downto 3); doutq <= doutb_i(37 downto 22);
            when others => douti <= doutb_i(15 downto 0); doutq <= doutb_i(34 downto 19);
        end case;
    end process multiplexer;

inbuf_mem_i: inbuf_mem
port map(
	clka  => clk2x,
	dina  => dina_i,
	addra => pos,
	wea   => (wea_i),
	douta => douta_i,
	clkb  => clk_data,
	dinb  => (others => '0'),
	addrb => addr,
	web   => "0",
	doutb => doutb_i
);

end Structural;
