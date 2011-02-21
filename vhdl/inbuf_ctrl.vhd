-----------------------------------------------------------
-- Project			: 
-- File				: inbuf_ctrl.vhd
-- Author			: Gernot Vormayr
-- created			: Jan, 7th 2011
-- contents			: ctrl
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity inbuf_ctrl is
port(
	clk                 : in  std_logic;
	rst                 : in  std_logic;
	stream_valid		: in  std_logic;

	depth_1             : in  std_logic_vector(15 downto 0);
	width               : in  std_logic_vector(1 downto 0);

	arm					: in  std_logic;
	trigger				: in  std_logic;

	frame_clk			: out std_logic;
	locked				: out std_logic;
	done                : out std_logic;
	
	addra               : out std_logic_vector(15 downto 0);
	addrb               : out std_logic_vector(15 downto 0);
	we                  : out std_logic;
	active              : out std_logic;
	add                 : out std_logic
);
end inbuf_ctrl;

architecture Structural of inbuf_ctrl is
	type inbuf_state is (RESET, EXT_TRIG, WRITE, FINISHED, INT_TRIG);
	signal state         : inbuf_state;
	signal next_state    : inbuf_state;
	signal rst_i         : std_logic;
	signal frame_clk_i   : std_logic;
	signal frame_clk_cnt : std_logic_vector(15 downto 0);
	signal locked_i		 : std_logic;
	signal width_cnt	 : std_logic_vector(3 downto 0);
	signal width_max	 : std_logic_vector(3 downto 0);
	signal addrb_cnt     : std_logic_vector(15 downto 0);
begin
	width_max <= "0111" when width = "11" else
				 "0011" when width = "10" else
				 "0001" when width = "01" else
				 "0000";

	rst_i     <= rst or not stream_valid;
	frame_clk <= frame_clk_i;

	state_process: process(clk, rst_i)
	begin
		if rst_i = '1' then
			state <= RESET;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process state_process;

	next_state_process: process(clk, state, arm, trigger, frame_clk_i, frame_clk_cnt, depth_1, width_cnt, width_max)
	begin
		next_state <= state;
		case state is
			when RESET    =>	if arm = '1' then
									next_state <= EXT_TRIG;
								end if;
			when EXT_TRIG =>	if trigger = '1' then
									next_state <= WRITE;
								end if;
			when WRITE    =>	if frame_clk_cnt = depth_1 and width_cnt = width_max then
									next_state <= FINISHED;
								end if;
			when FINISHED =>	if arm = '1' then
									next_state <= INT_TRIG;
								end if;
			when INT_TRIG =>	if frame_clk_i = '1' then
									next_state <= WRITE;
								end if;
		end case;
	end process next_state_process;

	output_function_process: process(state, frame_clk_i)
	begin
		case state is
			when RESET    => locked_i <= '0'; we <= '0'; done <= '0'; active <= '0';
			when EXT_TRIG => locked_i <= '0'; we <= '0'; done <= '0'; active <= '1';
			when WRITE    => locked_i <= '1'; we <= '1'; done <= '0'; active <= '1';
			when FINISHED => locked_i <= '1'; we <= '0'; done <= '1'; active <= '0';
			when INT_TRIG => locked_i <= '1'; we <= '0' or frame_clk_i; done <= '0'; active <= '1';
		end case;
	end process output_function_process;

	frame_clk_cnt_process: process(clk, locked_i, depth_1, state)
	begin
		if locked_i = '0' then 
			frame_clk_cnt <= (others => '0');
			frame_clk_i <= '0';
		elsif rising_edge(clk) then
			if frame_clk_cnt = depth_1 then
				frame_clk_cnt <= (others => '0');
				frame_clk_i <= '1';
			else
				frame_clk_cnt <= frame_clk_cnt + 1;
				frame_clk_i <= '0';
			end if;
		end if;
	end process frame_clk_cnt_process;

	addrb_cnt_process: process(clk, rst_i, locked_i, depth_1)
	begin
		if locked_i = '0' then
			addrb_cnt <= depth_1 - 2;
		elsif rising_edge(clk) then
			if addrb_cnt = depth_1 then
				addrb_cnt <= (others => '0');
			else
				addrb_cnt <= addrb_cnt + 1;
			end if;
		end if;
	end process addrb_cnt_process;

	width_cnt_process: process(clk, state, frame_clk_cnt)
	begin
		if not(state = WRITE) then
			width_cnt <= (others => '0');
		elsif rising_edge(clk) then
			if frame_clk_cnt = depth_1 then
				width_cnt <= width_cnt + 1;
			end if;
		end if;
	end process width_cnt_process;

	locked  <= locked_i;
	addra   <= frame_clk_cnt;
	add     <= '1' when width_cnt > "0000" else
			   '0';
	addrb   <= addrb_cnt;

end Structural;


