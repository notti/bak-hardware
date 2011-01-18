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
        use IEEE.STD_LOGIC_SIGNED.ALL;

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
    read_req     : in std_logic;
    read_ack     : out std_logic;
    clk_bus      : in std_logic;

    clk_data     : in std_logic;
	we           : in std_logic;
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
    signal davg_i   : std_logic_vector(18 downto 0);
    signal din_i    : std_logic_vector(18 downto 0);
    signal douta_i  : std_logic_vector(18 downto 0);
    signal doutb_i  : std_logic_vector(18 downto 0);
    signal wea_i    : std_logic_vector(0 downto 0);
    signal add_i    : std_logic;
    signal start_i  : std_logic;
    signal active_i : std_logic;
    signal addra_i  : std_logic_vector(15 downto 0);
    signal addrb_i  : std_logic_vector(15 downto 0);
    signal clka     : std_logic;
    signal read_ack_i : std_logic;
    signal we_i     : std_logic;
    signal arm_i    : std_logic;

begin

    clk_mux: BUFGMUX
    port map (
      O => clka,
      I0 => clk,
      I1 => clk_data,
      S => read_ack_i
    );

    inbuf_arb: entity inbuf.inbuf_arb
    port map(
        clk         => clk_bus,
        rst         => rst,

        read_req    => read_req,
        read_ack    => read_ack_i,
        active      => active_i
    );

    arm_i <= arm and not read_ack_i;

    inbuf_ctrl: entity inbuf.inbuf_ctrl
    port map(
        clk          => clk,
        rst          => rst,
        stream_valid => stream_valid,
        depth        => depth,
        width        => width,
        arm          => arm_i,
        trigger      => trigger,
        frame_clk    => frame_clk,
        locked       => locked,
        done         => done,
        addra        => addra_i,
        addrb        => addrb_i,
        we           => we_i,
        active       => active_i,
        add          => add_i
    );

    wea_i(0) <= we_i when read_ack_i = '0' else
                we;

    davg_i <= SXT(data,19) + doutb_i when add_i = '1' else
              SXT(data,19);

    multiplexer_out: process(doutb_i, width)
    begin
        case width is
            when "01"   => dout <= douta_i(16 downto 1);
            when "10"   => dout <= douta_i(17 downto 2);
            when "11"   => dout <= douta_i(18 downto 3);
            when others => dout <= douta_i(15 downto 0);
        end case;
    end process multiplexer_out;

    multiplexer_in: process(din, width)
    begin
        case width is
            when "01"   => din_i <= ("00" & din & "0");
            when "10"   => din_i <= ("0" & din & "00");
            when "11"   => din_i <= (din & "000");
            when others => din_i <= ("000" & din);
        end case;
    end process multiplexer_in;

    dina_i <= davg_i when read_ack_i = '0' else
              din_i;

inbuf_mem_i: inbuf_mem
port map(
	clka  => clka,
	dina  => dina_i,
	addra => addra_i,
	wea   => wea_i,
	douta => douta_i,
	clkb  => clk,
	dinb  => (others => '0'),
	addrb => addrb_i,
	web   => "0",
	doutb => doutb_i
);

    read_ack <= read_ack_i;

end Structural;
