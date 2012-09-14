-----------------------------------------------------------
-- Transmitter for DS90CR486 Reciever
-- no DC Balance:
--
-- scheme: c 1     1     0     0     0     1     1
--        0d e2d8  e2d5  e2d4  e2d3  e2d2  e2d1  e2d0
--        1d e2d17 e2d16 e2d13 e2d12 e2d11 e2d10 e2d9
--        2d NA    NA    NA    e2d21 e2d20 e2d19 e2d18
--        3d e2d23 e2d23 e2d22 e2d15 e2d14 e2d7  e2d6
--        4d e1d8  e1d5  e1d4  e1d3  e1d2  e1d1  e1d0
--        5d e1d17 e1d16 e1d13 e1d12 e1d11 e1d10 e1d9
--        6d NA    NA    NA    e1d21 e1d20 e1d19 e1d18
--        7d e1d23 e1d23 e1d22 e1d15 e1d14 e1d7  e1d6
--
-- deskew: not supported
--
-- DC Balance:
--
-- scheme: c 1     1/0   0     0     0     1     1
--        0d e2d0  e2d1  e2d2  e2d3  e2d4  e2d5  dcb
--        1d e2d8  e2d9  e2d10 e2d11 e2d12 e2d13 dcb
--        2d e2d16 e2d17 e2d18 e2d19 e2d20 e2d21 dcb
--        3d e2d6  e2d7  e2d14 e2d15 e2d22 e2d23 dcb
--        4d e1d0  e1d1  e1d2  e1d3  e1d4  e1d5  dcb
--        5d e1d8  e1d9  e1d10 e1d11 e1d12 e1d13 dcb
--        6d e1d16 e1d17 e1d18 e1d19 e1d20 e1d21 dcb
--        7d e1d6  e1d7  e1d14 e1d15 e1d22 e1d23 dcb
--
-- deskew: c 1     1     1     1     1     0     0
--      0-7d 1     1     1     1     0     0     0
--         
--         c 1     1     0     0     0     0     0
--      0-7d 1     1     1     0     0     0     0
--
-- oserdes ddr 4 bit -> 7 cycles
--     |     0     | |     1     | |     2     | |     3     |
--  d: 0 1 2 3 4 5 b 0 1 2 3 4 5 b 0 1 2 3 4 5 b 0 1 2 3 4 5 b
--     |  0  | |  1  | |  2  | |  3  | |  4  | |  5  | |  6  | 
--      ______        ______        ______        ______        
-- clk /      \______/      \______/      \______/      \_____ 100Mhz
--      ___     ___     ___     ___     ___     ___     ___   
-- ckm /   \___/   \___/   \___/   \___/   \___/   \___/   \__ 175Mhz
--      _   __   _   _   _   _   _   _      _   _   _   _   _ 
-- ckh / \_/  \_/ \_/ \_/ \_/ \_/ \_/ \_/\_/ \_/ \_/ \_/ \_/ \ 350Mhz
--                                                                        
--     s0            s1            s3            s4            s0            s1            s2
--                                 |  0  | |  1  | |  2  | |  3  | |  4  | |  5  | |  6  | 
--                                 s0(3-0) s0(6-4) s1(4-1) s1(6-5) s2(5-2) s2(6-6) s3(6-3)
--                                         s1(0-0)         s2(1-0)         s3(2-0)
--1100
--0111
--1000
--1111
--0001
--1110
--0011
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity transmitter is
port(
	clk                 : in  std_logic;
	rst                 : in  std_logic;
	e1                  : in  std_logic_vector(23 downto 0);
	e2                  : in  std_logic_vector(23 downto 0);
	deskew              : in  std_logic;
    dc_balance          : in  std_logic;

-- signals for selectio oserdes transmitter
	txn                 : out std_logic_vector(7 downto 0);
	txp                 : out std_logic_vector(7 downto 0);
	txclkn              : out std_logic;
	txclkp              : out std_logic
);
end transmitter;

architecture Structural of transmitter is
	type data_arr is array (3 downto 0) of std_logic_vector(6 downto 0);
	type ubal_arr is array(7 downto 0) of std_logic_vector(5 downto 0);
	type nbal_arr is array(7 downto 0) of std_logic_vector(6 downto 0);
	type deskew_states is (RESET, OUT_DESKEW, OUT_DATA, DESKEW_SYNC);

	signal locked_i         : std_logic;
	signal nlocked_i        : std_logic;
	signal ckm              : std_ulogic;
	signal ckh              : std_ulogic;
	signal ckf              : std_ulogic;
	signal in_start         : std_logic;
	signal frame_scan       : std_logic;

	signal buf_cycle        : std_logic_vector(1 downto 0);
	signal out_run          : std_logic;
	signal out_cycle        : unsigned(2 downto 0);
	signal CLKFBOUT_CLKFBIN : std_logic;
	signal out_en           : std_logic;
	signal nout_en          : std_logic;
	signal outdata_unbalanced : ubal_arr;
	signal outdata_nobalanced : nbal_arr;
	signal deskew_cnt       : std_logic_vector(11 downto 0);
	signal deskew_out       : std_logic;
	signal deskew_state     : deskew_states;
	signal frame_sync       : std_logic;
	signal ckf_dly          : std_logic;
	signal en_balance       : std_logic;
	signal CLKOUT0          : std_ulogic;
	signal CLKOUT1          : std_ulogic;
	signal CLKOUT2          : std_ulogic;

    signal rst_r            : std_logic;

	
	function reverse(a: in std_logic_vector) return std_logic_vector is
		variable result: std_logic_vector(a'length - 1 downto 0);
	begin
		for i in result'range loop
			result((a'length-1)-i) := a(i+a'low);
		end loop;
		return result;
	end;

begin
    in_start_p: process(ckf, locked_i)
    begin
        if rising_edge(ckf) then
            if locked_i = '0' then
                in_start <= '0';
            else
                in_start <= '1';
            end if;
        end if;
    end process in_start_p;
    frame_scan_p: process(clk, in_start, buf_cycle)
    begin
        if rising_edge(clk) and buf_cycle = "11" then
            if in_start = '0' then
                frame_scan <= '0';
            else
                frame_scan <= '1';
            end if;
        end if;
    end process;
    frame_sync_p: process(clk, ckf, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ckf_dly <= '0';
            else
                ckf_dly <= ckf;
            end if;
        end if;
    end process;
    frame_sync <= ckf and not ckf_dly;
    buf_cycle_p: process(clk, in_start)
    begin
        if rising_edge(clk) then
            if in_start = '0' then
                buf_cycle <= "10";
            else
                buf_cycle <= buf_cycle + 1;
            end if;
        end if;
    end process buf_cycle_p;
    out_run_p: process(ckf, rst, in_start)
    begin
        if rising_edge(ckf) then
            if rst = '1' then
                out_run <= '0';
            else
                out_run <= in_start;
            end if;
        end if;
    end process out_run_p;
    out_cycle_p: process(ckm, out_run, out_cycle)
    begin
        if rising_edge(ckm) then
            if out_run = '0' then
                out_cycle <= (others => '0');
            else
                out_cycle <= (out_cycle + 1) mod 7;
            end if;
        end if;
    end process;
    rst_r_p: process(clk, rst)
    begin
        if rising_edge(clk) then
            rst_r <= rst;
        end if;
    end process;
    out_en_p: process(ckm, rst, out_run)
    begin
        if rising_edge(ckm) then
            if rst_r = '1' then -- registered reset signal to prevent timing errors
                out_en <= '0';
            else
                out_en <= out_run;
            end if;
        end if;
    end process;
    deskew_cnt_p: process(clk, deskew_state)
    begin
        if rising_edge(clk) then
            if not (deskew_state = OUT_DESKEW) then
                deskew_cnt <= (others => '0');
            else
                deskew_cnt <= deskew_cnt + 1;
            end if;
        end if;
    end process;
    deskew_p: process(clk, rst, frame_scan, dc_balance, deskew_cnt, deskew, deskew_state, in_start)
    begin
        if rising_edge(clk) then
            if rst = '1' or dc_balance = '0' then
                deskew_state <= RESET;
            else
                case deskew_state is
                    when RESET =>
                        if in_start = '1' then
                            deskew_state <= OUT_DESKEW;
                        end if;
                        deskew_out <= '0';
                    when OUT_DESKEW =>
                        if and_many(deskew_cnt) = '1' then
                            deskew_state <= OUT_DATA;
                        end if;
                        deskew_out <= '1';
                    when OUT_DATA =>
                        if deskew = '1' then
                            deskew_state <= DESKEW_SYNC;
                        end if;
                        deskew_out <= '0';
                    when DESKEW_SYNC =>
                        if frame_sync = '1' then
                            deskew_state <= OUT_DESKEW;
                        end if;
                        deskew_out <= '0';
                end case;
            end if;
        end if;
    end process;

    outdata_unbalanced(0) <= e2( 5 downto  0);
    outdata_unbalanced(1) <= e2(13 downto  8);
    outdata_unbalanced(2) <= e2(21 downto 16);
    outdata_unbalanced(3) <= e2(23 downto 22) & e2(15 downto 14) & e2(7 downto 6);
    outdata_unbalanced(4) <= e1( 5 downto  0);
    outdata_unbalanced(5) <= e1(13 downto  8);
    outdata_unbalanced(6) <= e1(21 downto 16);
    outdata_unbalanced(7) <= e1(23 downto 22) & e1(15 downto 14) & e1(7 downto 6);
    outdata_nobalanced(0) <= e2(8) & e2(5 downto 0);
    outdata_nobalanced(1) <= e2(17 downto 16) & e2(13 downto 9);
    outdata_nobalanced(2) <= "000" & e2(21 downto 18);
    outdata_nobalanced(3) <= e2(23) & e2(23) & e2(22) & e2(15 downto 14) & e2(7 downto 6);
    outdata_nobalanced(4) <= e1(8) & e1(5 downto 0);
    outdata_nobalanced(5) <= e1(17 downto 16) & e1(13 downto 9);
    outdata_nobalanced(6) <= "000" & e1(21 downto 18);
    outdata_nobalanced(7) <= e1(23) & e1(23) & e1(22) & e1(15 downto 14) & e1(7 downto 6);
    nout_en <= not out_en;
    en_balance <= frame_scan and (not deskew_out) and dc_balance;

    outputs_generate: for i in 0 to 7 generate
        signal outdata_long     : data_arr;
        signal outdata_short    : std_logic_vector(3 downto 0);
        signal outdata_balanced : std_logic_vector(6 downto 0);
        signal outdata_final    : std_logic_vector(6 downto 0);
        signal tx               : std_ulogic;
        signal tq               : std_ulogic;
    begin
        balance_i: entity work.balance
        port map(
            clk => clk,
            rst => rst,
            en => en_balance,
            unbalanced => outdata_unbalanced(i),
            balanced => outdata_balanced
        );
        outdata_final <= "1111000" when deskew_out = '1' and buf_cycle(0) = '1' else
                         "1110000" when deskew_out = '1' and buf_cycle(0) = '0' else
                         outdata_balanced when dc_balance = '1' else
                         outdata_nobalanced(i);
        long_buf_p: process(clk, buf_cycle, frame_scan, outdata_final)
        begin
            if rising_edge(clk) and frame_scan = '1' then
                outdata_long(conv_integer(buf_cycle)) <= outdata_final;
            end if;
        end process long_buf_p;

        outdata_short_p: process(ckm, out_run, out_cycle, outdata_long)
        begin
            if rising_edge(ckm) then
                if out_run = '0' then
                    outdata_short <= (others => '0');
                else
                    case out_cycle is
                        when "000" => outdata_short <= outdata_long(0)(6 downto 3);
                        when "001" => outdata_short <= outdata_long(0)(2 downto 0) & outdata_long(1)(6 downto 6);
                        when "010" => outdata_short <= outdata_long(1)(5 downto 2);
                        when "011" => outdata_short <= outdata_long(1)(1 downto 0) & outdata_long(2)(6 downto 5);
                        when "100" => outdata_short <= outdata_long(2)(4 downto 1);
                        when "101" => outdata_short <= outdata_long(2)(0 downto 0) & outdata_long(3)(6 downto 4);
                        when "110" => outdata_short <= outdata_long(3)(3 downto 0);
                        when others => null;
                    end case;
                end if;
            end if;
        end process outdata_short_p;

        tx_oserdes_inst_i : OSERDES
        generic map(
              DATA_RATE_OQ      => "DDR",
              DATA_RATE_TQ      => "DDR",
              DATA_WIDTH        => 4,
              INIT_OQ           => '0',
              INIT_TQ           => '1',
              SERDES_MODE       => "MASTER",
              SRVAL_OQ          => '0',
              SRVAL_TQ          => '1',
              TRISTATE_WIDTH    => 4
        ) 
        port map(
              OQ                => tx,
              SHIFTOUT1         => open,
              SHIFTOUT2         => open,
              TQ                => tq,
              CLK               => ckh,
              CLKDIV            => ckm,
              D1                => outdata_short(3),
              D2                => outdata_short(2),
              D3                => outdata_short(1),
              D4                => outdata_short(0),
              D5                => '0',
              D6                => '0',
              OCE               => out_en,
              REV               => '0',
              SHIFTIN1          => '0',
              SHIFTIN2          => '0',
              SR                => nlocked_i,
              T1                => nout_en,
              T2                => nout_en,
              T3                => nout_en,
              T4                => nout_en,
              TCE               => out_en
        );
        tx_pin_i: OBUFTDS
        generic map(
            IOSTANDARD => "LVDS_25"
        )
        port map(
            I  => tx,
            T  => tq,
            O  => txp(i),
            OB => txn(i)
        );
    end generate;

   
    PLL_INST : PLL_BASE
    generic map( CLKIN_PERIOD => 10.000,
            CLKOUT0_DIVIDE => 2,
            CLKOUT1_DIVIDE => 4,
            CLKOUT2_DIVIDE => 28,
            CLKOUT0_PHASE => 0.000,
            CLKOUT1_PHASE => 0.000,
            CLKOUT2_PHASE => 0.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT2_DUTY_CYCLE => 0.500,
            DIVCLK_DIVIDE => 1,
            CLKFBOUT_MULT => 7,
            CLKFBOUT_PHASE => 0.0)
    port map (CLKFBIN=>CLKFBOUT_CLKFBIN,
              RST=>rst,
              CLKIN=>clk,
              CLKFBOUT=>CLKFBOUT_CLKFBIN,
              CLKOUT0=>CLKOUT0,
              CLKOUT1=>CLKOUT1,
              CLKOUT2=>CLKOUT2,
              CLKOUT3=>open,
              CLKOUT4=>open,
              CLKOUT5=>open,
              LOCKED=>locked_i);
    CLKOUT0_BUFG_INST : BUFG
      port map (I=>CLKOUT0,
                O=>ckh);
   
    CLKOUT1_BUFG_INST : BUFG
      port map (I=>CLKOUT1,
                O=>ckm);
    CLKOUT2_BUFG_INST : BUFG
      port map (I=>CLKOUT2,
                O=>ckf);

    nlocked_i <= not locked_i;

    clk_generate: if 1 = 1 generate
        signal outdata_long     : data_arr;
        signal outdata_short    : std_logic_vector(3 downto 0);
        signal outdata_final    : std_logic_vector(6 downto 0);
        signal tx               : std_ulogic;
        signal tq               : std_ulogic;
    begin
        outdata_final <= "1100011" when dc_balance = '0' else
                         "1111100" when deskew_out = '1' and buf_cycle(0) = '1' else
                         "1100000" when deskew_out = '1' and buf_cycle(0) = '0' else
                         "1100011" when deskew_out = '0' and buf_cycle(0) = '1' else
                         "1000011";
        long_buf_p: process(clk, buf_cycle, frame_scan, outdata_final)
        begin
            if rising_edge(clk) and frame_scan = '1' then
                outdata_long(conv_integer(buf_cycle)) <= outdata_final;
            end if;
        end process long_buf_p;

        outdata_short_p: process(ckm, out_run, out_cycle, outdata_long)
        begin
            if rising_edge(ckm) then
                if out_run = '0' then
                    outdata_short <= (others => '0');
                else
                    case out_cycle is
                        when "000" => outdata_short <= outdata_long(0)(6 downto 3);
                        when "001" => outdata_short <= outdata_long(0)(2 downto 0) & outdata_long(1)(6 downto 6);
                        when "010" => outdata_short <= outdata_long(1)(5 downto 2);
                        when "011" => outdata_short <= outdata_long(1)(1 downto 0) & outdata_long(2)(6 downto 5);
                        when "100" => outdata_short <= outdata_long(2)(4 downto 1);
                        when "101" => outdata_short <= outdata_long(2)(0 downto 0) & outdata_long(3)(6 downto 4);
                        when "110" => outdata_short <= outdata_long(3)(3 downto 0);
                        when others => null;
                    end case;
                end if;
            end if;
        end process outdata_short_p;

        tx_oserdes_inst_i : OSERDES
        generic map(
              DATA_RATE_OQ      => "DDR",
              DATA_RATE_TQ      => "DDR",
              DATA_WIDTH        => 4,
              INIT_OQ           => '0',
              INIT_TQ           => '1',
              SERDES_MODE       => "MASTER",
              SRVAL_OQ          => '0',
              SRVAL_TQ          => '1',
              TRISTATE_WIDTH    => 4
        ) 
        port map(
              OQ                => tx,
              SHIFTOUT1         => open,
              SHIFTOUT2         => open,
              TQ                => tq,
              CLK               => ckh,
              CLKDIV            => ckm,
              D1                => outdata_short(3),
              D2                => outdata_short(2),
              D3                => outdata_short(1),
              D4                => outdata_short(0),
              D5                => '0',
              D6                => '0',
              OCE               => out_en,
              REV               => '0',
              SHIFTIN1          => '0',
              SHIFTIN2          => '0',
              SR                => nlocked_i,
              T1                => nout_en,
              T2                => nout_en,
              T3                => nout_en,
              T4                => nout_en,
              TCE               => out_en
        );
        tx_pin_i: OBUFTDS
        generic map(
            IOSTANDARD => "LVDS_25"
        )
        port map(
            I  => tx,
            T  => tq,
            O  => txclkp,
            OB => txclkn
        );
    end generate;

end Structural;

