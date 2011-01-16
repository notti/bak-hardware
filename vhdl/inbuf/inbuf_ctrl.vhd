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

library inbuf;
        use inbuf.all;

library misc;
	use misc.procedures.all;

entity inbuf_ctrl is
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;
		stream_valid		: in  std_logic;

		rst_out				: out std_logic;

        depth               : in  std_logic_vector(15 downto 0);
        width               : in  std_logic_vector(1 downto 0);
        depth_r             : out std_logic_vector(15 downto 0);
        width_r             : out std_logic_vector(1 downto 0);

		arm					: in  std_logic;
		trigger				: in  std_logic;

		frame_clk			: out std_logic;
		locked				: out std_logic;

		run					: out std_logic;
		done				: in  std_logic
);
end inbuf_ctrl;

architecture Structural of inbuf_ctrl is
        type inbuf_state is (RESET, EXT_TRIG, WRITE, FINISHED, INT_TRIG);
        signal state         : inbuf_state;
        signal next_state    : inbuf_state;
        signal depth_r_i     : std_logic_vector(15 downto 0);
        signal width_r_i     : std_logic_vector(1 downto 0);
        signal rst_i         : std_logic;
        signal frame_clk_i   : std_logic;
        signal frame_clk_cnt : std_logic_vector(15 downto 0);
		signal locked_i		 : std_logic;
begin

	rst_i     <= rst and not stream_valid;
	rst_out   <= rst_i;
	frame_clk <= frame_clk_i;

state_process: process(clk, rst_i, depth, width)
begin
    if rst_i = '1' then
        state <= RESET;
    elsif clk'event and clk = '1' then
		state <= next_state;
    end if;
end process state_process;

reg_process: process(clk, state, depth, width, rst_i)
begin
	if rst_i = '1' then
		depth_r_i <= (others => '0');
		width_r_i <= (others => '0');
	elsif clk'event and clk = '1' and state = RESET then
		depth_r_i <= depth;
		width_r_i <= width;
	end if;
end process reg_process;

next_state_process: process(clk, state, arm, trigger, done, frame_clk_i)
begin
	next_state <= state;
	case state is
		when RESET    =>	if arm = '1' then
								next_state <= EXT_TRIG;
							end if;
		when EXT_TRIG =>	if trigger = '1' then
								next_state <= WRITE;
							end if;
		when WRITE    =>	if done = '1' then
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

output_function_process: process(state)
begin
    case state is
		when RESET    => locked_i <= '0'; run <= '0';
		when EXT_TRIG => locked_i <= '0'; run <= '0';
		when WRITE    => locked_i <= '1'; run <= '1';
		when FINISHED => locked_i <= '1'; run <= '0';
		when INT_TRIG => locked_i <= '1'; run <= '0';
    end case;
end process output_function_process;

frame_clk_cnt_process: process(clk, locked_i, depth_r_i)
begin
	if locked_i = '0' then 
		frame_clk_cnt <= (others => '0');
    elsif clk'event and clk='1' then
		if frame_clk_cnt = depth_r_i then
			frame_clk_cnt <= (others => '0');
			frame_clk_i <= '1';
		else
            frame_clk_cnt <= frame_clk_cnt + 1;
			frame_clk_i <= '0';
        end if;
    end if;
end process frame_clk_cnt_process;

depth_r <= depth_r_i;
width_r <= width_r_i;
locked  <= locked_i;

end Structural;


