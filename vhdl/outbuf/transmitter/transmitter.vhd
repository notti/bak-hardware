-----------------------------------------------------------
-- Project			: 
-- File				: transmitter.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: Transmitter for DS90CR486 Reciever
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library outbuf;
        use outbuf.all;

entity transmitter is
generic(
        CLK_FREQ            : integer := 100000000
);
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;

-- signals for selectio oserdes transmitter
        tx                  : out std_logic_vector(7 downto 0);
        txclk               : out std_logic;

-- control signals
        bal                 : in std_logic;
        ds_opt              : in std_logic
);
end transmitter;

architecture Structural of transmitter is

COMPONENT transmitter_pll
PORT(
	CLKIN1_IN : IN std_logic;
	RST_IN : IN std_logic;          
	CLKOUT0_OUT : OUT std_logic;
        CLKOUT1_OUT : OUT std_logic;
	LOCKED_OUT : OUT std_logic
);
END COMPONENT;

        type oserdes_input_arr is array(7 downto 0) of std_logic_vector(3 downto 0);
        type data_arr is array(7 downto 0) of std_logic_vector(7 downto 0);

        signal locked_i         : std_logic;
        signal reset_i          : std_logic;
        signal clkhigh_i        : std_logic;
        signal clkdiv_i         : std_logic;

        signal outdata_short_i  : oserdes_input_arr;
        signal outdata_long_i   : data_arr;
        signal outclk_short_i   : std_logic_vector(3 downto 0);
        signal outclk_long_i    : std_logic_vector(7 downto 0);
        signal data_out_phase_i : std_logic;
begin
transmitter_pll_i: transmitter_pll
port map(
        CLKIN1_IN           => clk,
        RST_IN              => rst,
        CLKOUT0_OUT         => clkhigh_i,
        CLKOUT1_OUT         => clkdiv_i,
        LOCKED_OUT          => locked_i
);

outputs_generate: for i in 0 to 7 generate
    tx_oserdes_inst_i : OSERDES
    generic map(
          DATA_RATE_OQ      => "DDR", -- Specify data rate to "DDR" or "SDR" 
          DATA_RATE_TQ      => "BUF", -- Specify data rate to "DDR", "SDR", or "BUF" 
          DATA_WIDTH        => 4, -- Specify data width - For DDR: 4,6,8, or 10 
                           -- For SDR or BUF: 2,3,4,5,6,7, or 8 
          INIT_OQ           => '0',  -- INIT for Q1 register - '1' or '0' 
          INIT_TQ           => '0',  -- INIT for Q2 register - '1' or '0' 
          SERDES_MODE       => "MASTER", --Set SERDES mode to "MASTER" or "SLAVE" 
          SRVAL_OQ          => '0', -- Define Q1 output value upon SR assertion - '1' or '0' 
          SRVAL_TQ          => '0', -- Define Q1 output value upon SR assertion - '1' or '0' 
          TRISTATE_WIDTH    => 1
    ) -- Specify parallel to serial converter width 
                               -- When DATA_RATE_TQ = DDR: 2 or 4 
                               -- When DATA_RATE_TQ = SDR or BUF: 1 " 
    port map(
          OQ                => tx(i),    -- 1-bit output
          SHIFTOUT1         => open, -- 1-bit data expansion output
          SHIFTOUT2         => open, -- 1-bit data expansion output
          TQ                => open,    -- 1-bit 3-state control output
          CLK               => clkhigh_i,  -- 1-bit clock input
          CLKDIV            => clkdiv_i,  -- 1-bit divided clock input
          D1                => outdata_short_i(i)(0),    -- 1-bit parallel data input
          D2                => outdata_short_i(i)(1),    -- 1-bit parallel data input
          D3                => outdata_short_i(i)(2),    -- 1-bit parallel data input
          D4                => outdata_short_i(i)(3),    -- 1-bit parallel data input
          D5                => '0',    -- 1-bit parallel data input
          D6                => '0',    -- 1-bit parallel data input
          OCE               => '1',  -- 1-bit clcok enable input
          REV               => '0',  -- Must be tied to logic zero
          SHIFTIN1          => '0', -- 1-bit data expansion input
          SHIFTIN2          => '0', -- 1-bit data expansion input
          SR                => not locked_i,   -- 1-bit set/reset input
          T1                => '0',   -- 1-bit parallel 3-state input
          T2                => '0',   -- 1-bit parallel 3-state input
          T3                => '0',   -- 1-bit parallel 3-state input
          T4                => '0',   -- 1-bit parallel 3-state input
          TCE               => '0'  -- 1-bit 3-state signal clock enable input
    );
end generate;

txclk_oserdes_inst_i : OSERDES
generic map(
      DATA_RATE_OQ      => "DDR", -- Specify data rate to "DDR" or "SDR" 
      DATA_RATE_TQ      => "BUF", -- Specify data rate to "DDR", "SDR", or "BUF" 
      DATA_WIDTH        => 4, -- Specify data width - For DDR: 4,6,8, or 10 
                       -- For SDR or BUF: 2,3,4,5,6,7, or 8 
      INIT_OQ           => '0',  -- INIT for Q1 register - '1' or '0' 
      INIT_TQ           => '0',  -- INIT for Q2 register - '1' or '0' 
      SERDES_MODE       => "MASTER", --Set SERDES mode to "MASTER" or "SLAVE" 
      SRVAL_OQ          => '0', -- Define Q1 output value upon SR assertion - '1' or '0' 
      SRVAL_TQ          => '0', -- Define Q1 output value upon SR assertion - '1' or '0' 
      TRISTATE_WIDTH    => 1
) -- Specify parallel to serial converter width 
                           -- When DATA_RATE_TQ = DDR: 2 or 4 
                           -- When DATA_RATE_TQ = SDR or BUF: 1 " 
port map(
      OQ                => txclk,    -- 1-bit output
      SHIFTOUT1         => open, -- 1-bit data expansion output
      SHIFTOUT2         => open, -- 1-bit data expansion output
      TQ                => open,    -- 1-bit 3-state control output
      CLK               => clkhigh_i,  -- 1-bit clock input
      CLKDIV            => clkdiv_i,  -- 1-bit divided clock input
      D1                => outclk_short_i(0),    -- 1-bit parallel data input
      D2                => outclk_short_i(1),    -- 1-bit parallel data input
      D3                => outclk_short_i(2),    -- 1-bit parallel data input
      D4                => outclk_short_i(3),    -- 1-bit parallel data input
      D5                => '0',    -- 1-bit parallel data input
      D6                => '0',    -- 1-bit parallel data input
      OCE               => '1',  -- 1-bit clcok enable input
      REV               => '0',  -- Must be tied to logic zero
      SHIFTIN1          => '0', -- 1-bit data expansion input
      SHIFTIN2          => '0', -- 1-bit data expansion input
      SR                => not locked_i,   -- 1-bit set/reset input
      T1                => '0',   -- 1-bit parallel 3-state input
      T2                => '0',   -- 1-bit parallel 3-state input
      T3                => '0',   -- 1-bit parallel 3-state input
      T4                => '0',   -- 1-bit parallel 3-state input
      TCE               => '0'  -- 1-bit 3-state signal clock enable input
);

data_switch: process(clkdiv_i, data_out_phase_i, locked_i)
begin
    if locked_i='0' then
        data_out_phase_i <= '0';
    elsif clkdiv_i'event and clkdiv_i='1' then
        if data_out_phase_i='0' then
            for i in 0 to 7 loop
                outdata_short_i(i) <= outdata_long_i(i)(3 downto 0);
            end loop;
            outclk_short_i <= outclk_long_i(3 downto 0);
            data_out_phase_i <= '1';
        else
            for i in 0 to 7 loop
                outdata_short_i(i) <= outdata_long_i(i)(7 downto 4);
            end loop;
            outclk_short_i <= outclk_long_i(7 downto 4);
            data_out_phase_i <= '0';
        end if;
    end if;
end process;

outdata_long_i(0) <= "10011100";
outdata_long_i(1) <= "10011100";
outdata_long_i(2) <= "10011100";
outdata_long_i(3) <= "10011100";
outdata_long_i(4) <= "10011100";
outdata_long_i(5) <= "10011100";
outdata_long_i(6) <= "10011100";
outdata_long_i(7) <= "10011100";

outclk_long_i     <= "11110000";

end Structural;

