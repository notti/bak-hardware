library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity average_mem is
port(
    clk          : in std_logic;
    rst          : in std_logic;

    width        : in std_logic_vector(1 downto 0);
    depth        : in std_logic_vector(15 downto 0);
    trig         : in std_logic;
    done         : out std_logic;
    active       : out std_logic;
    err			 : out std_logic;
    data         : in std_logic_vector(15 downto 0);
	data_valid	 : in std_logic;

    memclk       : in std_logic;
    ext          : in std_logic;
    dina         : in std_logic_vector(15 downto 0);
    addra        : in std_logic_vector(15 downto 0);
    wea          : in std_logic;
    douta        : out std_logic_vector(15 downto 0);
    dinb         : in std_logic_vector(15 downto 0);
    addrb        : in std_logic_vector(15 downto 0);
    web          : in std_logic;
    doutb        : out std_logic_vector(15 downto 0)
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

    type avg_state is (IDLE, FIRST, RUN, FINISHED, FAILED);
    signal state        : avg_state;
    signal next_state   : avg_state;

    signal dina_i       : std_logic_vector(18 downto 0);
    signal addra_i      : std_logic_vector(15 downto 0);
    signal wea_i        : std_logic;
    signal douta_i      : std_logic_vector(18 downto 0);
    signal dinb_i       : std_logic_vector(18 downto 0);
    signal addrb_i      : std_logic_vector(15 downto 0);
    signal web_i        : std_logic;
    signal doutb_i      : std_logic_vector(18 downto 0);

    signal cycle_cnt    : std_logic_vector(1 downto 0);
    signal frame_cnt    : std_logic_vector(15 downto 0);
    signal read_cnt     : std_logic_vector(15 downto 0);
    signal max          : std_logic_vector(15 downto 0);
    signal max_1        : std_logic_vector(15 downto 0);
    signal width_i      : std_logic_vector(1 downto 0);
begin

    done <=   '1' when state = FINISHED else
              '0';
	err <=    '1' when state = FAILED else
		      '0';
    active <= '1' when state = FIRST or state = RUN else
              '0';

    reg: process (clk, state, depth, width)
    begin
        if rising_edge(clk) then
            if state = IDLE and trig = '1' then
                max <= depth - 1;
                max_1 <= depth - 3;
                width_i <= width;
            end if;
        end if;
    end process reg;

    process (clk)
    begin
        if clk = '1' and clk'event then
            if rst = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    fsm_b: process (clk, state, trig, width_i, frame_cnt, cycle_cnt, depth, width, data_valid, max, max_1)
    begin
        case state is
            when IDLE =>
                if trig = '1' then
                    next_state <= FIRST;
                else
                    next_state <= IDLE;
                end if;
            when FIRST =>
				if data_valid = '0' then
					next_state <= FAILED;
				elsif width_i = "00" and frame_cnt = max then
                    next_state <= FINISHED;
                elsif width_i /= "00" and frame_cnt = max_1 then
                    next_state <= RUN;
                else
                    next_state <= FIRST;
                end if;
            when RUN =>
				if data_valid = '0' then
					next_state <= FAILED;
                elsif cycle_cnt = width_i and frame_cnt = max then
                    next_state <= FINISHED;
                else
                    next_state <= RUN;
                end if;
            when FINISHED =>
                next_state <= IDLE;
			when FAILED =>
				next_state <= IDLE;
        end case;
    end process fsm_b;

    counter: process (clk)
    begin
        if clk='1' and clk'event then
            if state = IDLE or frame_cnt = max then
                frame_cnt <= (others => '0');
            elsif state = FIRST or state = RUN then
                frame_cnt <= frame_cnt + 1;
            end if;
            if state = IDLE then
                cycle_cnt <= (others => '0');
            elsif frame_cnt = max then
                cycle_cnt <= cycle_cnt + 1;
            end if;
            if state = IDLE or read_cnt = max then
                read_cnt <= (others => '0');
            elsif state = RUN then
                read_cnt <= read_cnt + 1;
            end if;
        end if;
    end process counter;

    addra_i <= addra when ext = '1' else
               frame_cnt;
    addrb_i <= addrb when ext = '1' else
               read_cnt;
    wea_i  <= wea when ext = '1' else
              '1' when state = FIRST or state = RUN else
              '0';
    web_i  <= web when ext = '1' else
              '0';
    dina_i <= SXT(data, 19) when ext = '0' and cycle_cnt = "00" else
              SXT(data, 19) + doutb_i when ext = '0' and cycle_cnt /= "00" else
              ("00" & dina & "0") when width_i = "01" else
              ("0" & dina & "00") when width_i = "10" else
              (dina & "000") when width_i = "11" else
              ("000" & dina);
    dinb_i <= ("00" & dinb & "0") when width_i = "01" else
              ("0" & dinb & "00") when width_i = "10" else
              (dinb & "000") when width_i = "11" else
              ("000" & dinb);
    douta <= douta_i(16 downto 1) when width_i = "01" else
             douta_i(17 downto 2) when width_i = "10" else
             douta_i(18 downto 3) when width_i = "11" else
             douta_i(15 downto 0);
    doutb <= doutb_i(16 downto 1) when width_i = "01" else
             doutb_i(17 downto 2) when width_i = "10" else
             doutb_i(18 downto 3) when width_i = "11" else
             doutb_i(15 downto 0);

	inbuf_mem_i: inbuf_mem
	port map(
		clka  => memclk,
		dina  => dina_i,
		addra => addra_i,
		wea(0)=> wea_i,
		douta => douta_i,
		clkb  => memclk,
		dinb  => dinb_i,
		addrb => addrb_i,
		web(0)=> web_i,
		doutb => doutb_i
	);

end Structural;

