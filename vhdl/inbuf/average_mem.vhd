-----------------------------------------------------------
-- Project			: 
-- File				: average_mem.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Average Buffer
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library inbuf;
        use inbuf.all;

entity average_mem is
port(
    clk          : in std_logic;

    width        : in std_logic_vector(1 downto 0);
    depth        : in std_logic_vector(15 downto 0);
    arm          : in std_logic;
    trigger      : in std_logic;
    done         : out std_logic;
    frame_clk    : out std_logic;
    rst          : in std_logic;
    data         : in std_logic_vector(15 downto 0);
    stream_valid : in std_logic;
    locked       : out std_logic;

    clk_data     : in std_logic;
	web          : in std_logic;
    addr         : in std_logic_vector(15 downto 0);
    dout         : out std_logic_vector(15 downto 0);
    din          : in  std_logic_vector(15 downto 0)
);
end average_mem;

architecture Structural of average_mem is

component inbuf_mem IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(18 downto 0);
	addra: IN std_logic_VECTOR(15 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(18 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(18 downto 0);
	addrb: IN std_logic_VECTOR(15 downto 0);
	web: IN std_logic_VECTOR(0 downto 0);
	doutb: OUT std_logic_VECTOR(18 downto 0));
END component;

    signal dina_i   : std_logic_vector(18 downto 0);
    signal dinb_i   : std_logic_vector(18 downto 0);
    signal douta_i  : std_logic_vector(18 downto 0);
    signal doutb_i  : std_logic_vector(18 downto 0);
    signal web_i    : std_logic_vector(0 downto 0);
    signal wea_i    : std_logic_vector(0 downto 0);
    signal add_i    : std_logic;
    signal start_i  : std_logic;
    signal addra_i  : std_logic_vector(15 downto 0);
    signal addrb_i  : std_logic_vector(15 downto 0);

begin
    inbuf_ctrl: entity inbuf.inbuf_ctrl
    port map(
        clk          => clk,
        rst          => rst,
        stream_valid => stream_valid,
        depth        => depth,
        width        => width,
        arm          => arm,
        trigger      => trigger,
        frame_clk    => frame_clk,
        locked       => locked,
        done         => done,
        addra        => addra_i,
        addrb        => addrb_i,
        we           => wea_i(0),
        add          => add_i
    );

    dina_i <= ("000" & data) + doutb_i when add_i = '1' else
              ("000" & data);

--    multiplexer_out: process(doutb_i, width)
--    begin
--        case width is
--            when "01"   => dout <= doutb_i(16 downto 1);
--            when "10"   => dout <= doutb_i(17 downto 2);
--            when "11"   => dout <= doutb_i(18 downto 3);
--            when others => dout <= doutb_i(15 downto 0);
--        end case;
--    end process multiplexer_out;
--
--    multiplexer_in: process(din, width)
--    begin
--        case width is
--            when "01"   => dinb_i <= ("00" & din & "0");
--            when "10"   => dinb_i <= ("0" & din & "00");
--            when "11"   => dinb_i <= (din & "000");
--            when others => dinb_i <= ("000" & din);
--        end case;
--    end process multiplexer_in;
--
--    web_i(0) <= web;

    web_i(0) <= '0';
    dinb_i <= (others => '0');

inbuf_mem_i: inbuf_mem
port map(
	clka  => clk,
	dina  => dina_i,
	addra => addra_i,
	wea   => wea_i,
	douta => douta_i,
	clkb  => clk,
	dinb  => dinb_i,
	addrb => addrb_i,
	web   => web_i,
	doutb => doutb_i
);

end Structural;
