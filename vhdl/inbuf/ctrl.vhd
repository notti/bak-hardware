-----------------------------------------------------------
-- Project			: 
-- File				: ctrl.vhd
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

entity ctrl is
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        depth               : in  std_logic_vector(15 downto 0);
        width               : in  std_logic_vector(1 downto 0);
        data_valid          : in  std_logic;
        start               : in  std_logic;
        sample              : out std_logic;
        pos                 : out std_logic_vector(15 downto 0);
        done                : out std_logic
);
end ctrl;

architecture Structural of ctrl is
        type average_state is (RESET, WAIT_START, AVERAGE, FINISHED);
        signal state        : average_state;
        signal pos_cnt_r    : std_logic_vector(15 downto 0);
        signal width_cnt_r  : std_logic_vector(2 downto 0);
        signal depth_r      : std_logic_vector(15 downto 0);
        signal width_r      : std_logic_vector(1 downto 0);
begin

state_process: process(clk, rst, data_valid, start, depth, width, width_r)
begin
    if rst='1' or data_valid='0' then
        state <= RESET;
        depth_r <= (others => '0');
        width_r <= (others => '0');
    elsif clk'event and clk='1' then
        depth_r <= depth_r;
        width_r <= width_r;
        case state is
            when RESET      =>  state <= WAIT_START;
            when WAIT_START =>  if start = '1' then
                                    state <= AVERAGE;
                                    depth_r <= depth;
                                    width_r <= width;
                                end if;
            when AVERAGE    =>  if width_cnt_r > width_r then
                                    state <= FINISHED;
                                end if;
            when FINISHED       =>  if start = '1' then
                                    state <= AVERAGE;
                                    depth_r <= depth;
                                    width_r <= width;
                                end if;
        end case;
    end if;
end process state_process;

output_function_process: process(state)
begin
    case state is
        when RESET      => done <= '0'; sample <= '0';
        when WAIT_START => done <= '0'; sample <= '0';
        when AVERAGE    => done <= '0'; sample <= '1';
        when FINISHED       => done <= '1'; sample <= '0';
    end case;
end process output_function_process;

cnt_r_process: process(clk, state, pos_cnt_r)
begin
    if not(state=AVERAGE) then
        width_cnt_r <= (others => '0');
        pos_cnt_r <= (others => '0');
    elsif clk'event and clk='1' then
        if pos_cnt_r = depth_r then
            width_cnt_r <= width_cnt_r + 1;
            pos_cnt_r <= (others => '0');
        else
            pos_cnt_r <= pos_cnt_r + 1;
        end if;
    end if;
end process cnt_r_process;


    pos <= pos_cnt_r;

end Structural;


