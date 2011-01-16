-----------------------------------------------------------
-- Project			: 
-- File				: mem_ctrl.vhd
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

entity mem_ctrl is
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        depth               : in  std_logic_vector(15 downto 0);
        width               : in  std_logic_vector(1 downto 0);

		run					: in  std_logic;
		done				: out std_logic;

		addr				: out std_logic_vector(15 downto 0);
		we					: out std_logic;
		add					: out std_logic
);
end mem_ctrl;

architecture Structural of mem_ctrl is
        type mem_state is (RESET, WAIT0, WAIT1, WRITE, FINISHED);
        signal state         : mem_state;
        signal next_state    : mem_state;
		signal addr_cnt		 : std_logic_vector(15 downto 0);
		signal width_cnt	 : std_logic_vector(3 downto 0);
		signal width_max	 : std_logic_vector(3 downto 0);
begin

	width_max <= "1000" when width = "11" else
				 "0100" when width = "10" else
				 "0010" when width = "01" else
				 "0001";
	addr <= addr_cnt;

state_process: process(clk, rst)
begin
    if rst = '1' then
        state <= RESET;
    elsif clk'event and clk='1' then
		state <= next_state;
    end if;
end process state_process;

next_state_process: process(clk, state, run, width_cnt, width_max)
begin
	next_state <= state;
	case state is
		when RESET =>	if run = '1' then
				     		next_state <= WAIT0;
				     	end if;
		when WAIT0 =>	next_state <= WAIT1;
		when WAIT1 =>	next_state <= WRITE;
		when WRITE   =>	if width_cnt = width_max then
							next_state <= FINISHED;
						end if;
		when FINISHED  =>	if run = '1' then
							next_state <= WAIT0;
						end if;
	end case;
end process next_state_process;

output_function_process: process(state)
begin
    case state is
		when RESET    => we <= '0'; done <= '0';
		when WAIT0    => we <= '0'; done <= '0';
		when WAIT1    => we <= '0'; done <= '0';
		when WRITE    => we <= '1'; done <= '0';
		when FINISHED => we <= '0'; done <= '1';
    end case;
end process output_function_process;

addr_cnt_process: process(clk, state)
begin
	if not (state = WRITE) then 
		addr_cnt <= (others => '0');
		width_cnt <= (others => '0');
    elsif clk'event and clk='1' then
		if addr_cnt = depth then
			addr_cnt <= (others => '0');
			width_cnt <= width_cnt + 1;
		else
            addr_cnt <= addr_cnt + 1;
			width_cnt <= width_cnt;
        end if;
    end if;
end process addr_cnt_process;

add <= '1' when width_cnt > "0000" else
	   '0';

end Structural;

