-----------------------------------------------------------
-- Project			: 
-- File				: average_mem.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Average Buffer
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_ARITH.ALL;
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

    signal data1_i  : std_logic_vector(15 downto 0);
    signal data2_i  : std_logic_vector(15 downto 0);
    signal dina_i   : std_logic_vector(18 downto 0);
    signal dinb_i   : std_logic_vector(18 downto 0);
    signal douta_i  : std_logic_vector(18 downto 0);
    signal doutb_i  : std_logic_vector(18 downto 0);
    signal web_i    : std_logic_vector(0 downto 0);
    signal wea_i    : std_logic_vector(0 downto 0);
    signal add_i    : std_logic;
    signal run_i    : std_logic;
    signal rst_i    : std_logic;
    signal addra_i  : std_logic_vector(15 downto 0);
    signal depth_r  : std_logic_vector(15 downto 0);
    signal width_r  : std_logic_vector(1 downto 0);
    signal done_i   : std_logic;

begin
    done <= done_i;

    inbuf_ctrl: entity inbuf.inbuf_ctrl
    port map(
        clk          => clk,
        rst          => rst,
        stream_valid => stream_valid,
        rst_out      => rst_i,
        depth        => depth,
        width        => width,
        depth_r      => depth_r,
        width_r      => width_r,
        arm          => arm,
        trigger      => trigger,
        frame_clk    => frame_clk,
        locked       => locked,
        run          => run_i,
        done         => done_i
    );

    mem_ctrl: entity mem_ctrl
    port map(
        clk          => clk,
        rst          => rst_i,
        depth        => depth_r,
        width        => width_r,
        run          => run_i,
        done         => done_i,
        addr         => addra_i,
        we           => wea_i(0),
        add          => add_i
    );

    data_slow_p: process(clk, data1_i, data2_i, rst_i)
    begin
        if rst_i = '0' then
            data1_i <= (others => '0');
            data2_i <= (others => '0');
        elsif clk'event and clk = '1' then
            data1_i <= data;
            data2_i <= data1_i;
        end if;
    end process data_slow_p;

    dina_i <= ("000" & data2_i) + douta_i when add_i = '1' else
              ("000" & data2_i);

    multiplexer_out: process(doutb_i, width)
    begin
        case width is
            when "01"   => dout <= doutb_i(16 downto 1);
            when "10"   => dout <= doutb_i(17 downto 2);
            when "11"   => dout <= doutb_i(18 downto 3);
            when others => dout <= doutb_i(15 downto 0);
        end case;
    end process multiplexer_out;

    multiplexer_in: process(din, width)
    begin
        case width is
            when "01"   => dinb_i <= ("00" & din & "0");
            when "10"   => dinb_i <= ("0" & din & "00");
            when "11"   => dinb_i <= (din & "000");
            when others => dinb_i <= ("000" & din);
        end case;
    end process multiplexer_in;

    web_i(0) <= web;

inbuf_mem_i: inbuf_mem
port map(
	clka  => clk,
	dina  => dina_i,
	addra => addra_i,
	wea   => wea_i,
	douta => douta_i,
	clkb  => clk_data,
	dinb  => dinb_i,
	addrb => addr,
	web   => web_i,
	doutb => doutb_i
);

end Structural;
