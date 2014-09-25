-----------------------------------------------------------
-- fsm for automatic alignment and alignment signal generation
--
--  _____     _______  wait 16 cycles   _________  wait 16 cycles  _________
-- |reset|-->|poweron|---------------->|blank_clk|--------------->|wait_sync|
-- |_____|   |_______| pwr_on_cnt      |_________| blank_cnt      |_________|
--                                        ^  ^                      |  |
--                                        |  |______________________|  | aligned = 1 and valid = 1
--                                        |    wait 1024 cycles        | for 128 cycles
--                                        |      wait_cnt              | aligned_cnt
--                                        |                        ____V_
--                                        |_______________________|synced|
--                                       aligned = 0 or valid = 0 |______|
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.procedures.all;

entity align_fsm is
generic(
	SYNC_PWR_ON_LEN     : integer := 4; -- pwr_on_cnt len
	SYNC_BLANK_LEN      : integer := 12; -- blank_cnt len
	SYNC_WAIT_LEN       : integer := 12; -- wait_cnt len
	SYNC_ALIGNED_LEN    : integer := 5 -- aligned_cnt len
);
port(
	clk                 : in  std_logic;
	rst                 : in  std_logic;
	enable              : in  std_logic;
	aligned             : in  std_logic;
	valid               : in  std_logic;

	align               : out std_logic;
	tx                  : out std_logic_vector(19 downto 0);
	unsynced            : out std_logic
);
end align_fsm;

architecture Structural of align_fsm is
	type reciever_state is (RESET, POWERON, BLANK_CLK, WAIT_SYNC, SYNCED);
	signal state        : reciever_state;
	signal next_state   : reciever_state;

	signal pwr_on_cnt_r : std_logic_vector(SYNC_PWR_ON_LEN-1 downto 0);
	signal blank_cnt_r  : std_logic_vector(SYNC_BLANK_LEN-1 downto 0);
	signal aligned_cnt_r: std_logic_vector(SYNC_ALIGNED_LEN-1 downto 0);
	signal wait_cnt_r   : std_logic_vector(SYNC_WAIT_LEN-1 downto 0);
begin


	next_state_process: process(clk, rst, enable)
	begin
        if rising_edge(clk) then
            if rst = '1' or enable = '0' then
                state <= RESET;
            else
                state <= next_state;
            end if;
		end if;
	end process next_state_process;

	state_register_process: process(state, aligned, valid, pwr_on_cnt_r, blank_cnt_r, aligned_cnt_r, wait_cnt_r)
	begin
		next_state <= state;
		case state is
			when RESET      =>  next_state <= POWERON;
			when POWERON    =>  if and_many(pwr_on_cnt_r) = '1' then
									next_state <= BLANK_CLK;
								end if;
			when BLANK_CLK  =>  if and_many(blank_cnt_r) = '1' then
									next_state <= WAIT_SYNC;
								end if;
			when WAIT_SYNC  =>  if and_many(aligned_cnt_r) = '1' then
									next_state <= SYNCED;
								elsif and_many(wait_cnt_r) = '1' then
									next_state <= BLANK_CLK;
								end if;
			when SYNCED     =>  if aligned='0' or valid='0' then
									next_state <= BLANK_CLK;
								end if;
		end case;
	end process state_register_process;

	output_function_process: process(state)
	begin
		case state is
			when RESET      => align <= '0'; tx <= (others => '0');        unsynced <= '1';
			when POWERON    => align <= '0'; tx <= "11111111110000000000"; unsynced <= '1';
			when BLANK_CLK  => align <= '0'; tx <= (others => '0');        unsynced <= '1';
			when WAIT_SYNC  => align <= '1'; tx <= "11111111110000000000"; unsynced <= '1';
			when SYNCED     => align <= '0'; tx <= "11111111110000000000"; unsynced <= '0';
		end case;
	end process output_function_process;

	pwr_on_cnt_r_process: process(clk, state)
	begin
		if rising_edge(clk) then
            if not (state = POWERON) then
                pwr_on_cnt_r <= (others => '0');
            else
                pwr_on_cnt_r <= pwr_on_cnt_r + 1;
            end if;
		end if;
	end process pwr_on_cnt_r_process;

	blank_cnt_r_process: process(clk, state)
	begin
		if rising_edge(clk) then
            if not (state = BLANK_CLK) then
		    	blank_cnt_r <= (others => '0');
            else
                blank_cnt_r <= blank_cnt_r + 1;
            end if;
		end if;
	end process blank_cnt_r_process;

	aligned_cnt_r_process: process(clk, state, aligned, valid)
	begin
		if rising_edge(clk) then
            if (not (state = WAIT_SYNC)) or aligned = '0' or valid = '0' then
                aligned_cnt_r <= (others => '0');
            else
                aligned_cnt_r <= aligned_cnt_r + 1;
            end if;
		end if;
	end process aligned_cnt_r_process;

	wait_cnt_r_process: process(clk, state)
	begin
		if rising_edge(clk) then
            if not (state = WAIT_SYNC) then
                wait_cnt_r <= (others => '0');
            else
                wait_cnt_r <= wait_cnt_r + 1;
            end if;
		end if;
	end process wait_cnt_r_process;

end Structural;

