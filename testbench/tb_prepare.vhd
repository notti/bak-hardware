LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_prepare IS
END tb_prepare;
 
ARCHITECTURE behavior OF tb_prepare IS 
 
    COMPONENT prepare
    PORT(
         sample_clk : IN  std_logic;
         sys_clk : IN  std_logic;
         rst : IN  std_logic;
         arm : IN  std_logic;
         avg_finished : IN  std_logic;
         stream_valid : IN  std_logic;
         sys_enable : OUT  std_logic;
         sample_enable : OUT  std_logic;
         do_arm : OUT  std_logic;
         avg_done : OUT  std_logic;
         active : OUT  std_logic;
         avg_clk : OUT  std_logic
        );
    END COMPONENT;
    

   signal sample_clk : std_logic := '0';
   signal sys_clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal arm : std_logic := '0';
   signal avg_finished : std_logic := '0';
   signal stream_valid : std_logic := '0';

   signal sys_enable : std_logic;
   signal sample_enable : std_logic;
   signal do_arm : std_logic;
   signal avg_done : std_logic;
   signal active : std_logic;
   signal avg_clk : std_logic;

   constant sample_clk_period : time := 10 ns;
   constant sys_clk_period : time := 10 ns;
   constant avg_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: prepare PORT MAP (
          sample_clk => sample_clk,
          sys_clk => sys_clk,
          rst => rst,
          arm => arm,
          avg_finished => avg_finished,
          stream_valid => stream_valid,
          sys_enable => sys_enable,
          sample_enable => sample_enable,
          do_arm => do_arm,
          avg_done => avg_done,
          active => active,
          avg_clk => avg_clk
        );

   -- Clock process definitions
   sample_clk_process :process
   begin
		sample_clk <= '0';
        wait for 2 ns;
        sys_clk <= '0';
		wait for sample_clk_period/2 - 2 ns;
		sample_clk <= '1';
        wait for 2 ns;
        sys_clk <= '1';
		wait for sample_clk_period/2 - 2 ns;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;
      rst <= '0';

      wait for sample_clk_period*10;

      stream_valid <= '1';

      wait for sample_clk_period*10;

      arm <= '1', '0' after sample_clk_period;

      wait for sample_clk_period*50;

      avg_finished <= '1';

      wait;
   end process;

END;
