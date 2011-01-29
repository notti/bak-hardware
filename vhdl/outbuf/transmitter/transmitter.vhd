-----------------------------------------------------------
-- Project			: 
-- File				: transmitter.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Transmitter for DS90CR486 Reciever
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
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library outbuf;
    use outbuf.all;

library misc;
    use misc.procedures.all;

entity transmitter is
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        e1                  : in  std_logic_vector(23 downto 0);
        e2                  : in  std_logic_vector(23 downto 0);
        deskew              : in  std_logic;

-- signals for selectio oserdes transmitter
        txn                 : out std_ulogic_vector(7 downto 0);
        txp                 : out std_ulogic_vector(7 downto 0);
        txclkn              : out std_ulogic;
        txclkp              : out std_ulogic
);
end transmitter;

architecture Structural of transmitter is
        type data_arr is array (3 downto 0) of std_logic_vector(6 downto 0);
        type ubal_arr is array(7 downto 0) of std_logic_vector(5 downto 0);
        type deskew_states is (RESET, OUT_DESKEW, OUT_DATA, DESKEW_SYNC);

        signal txclk            : std_ulogic;
        signal locked_i         : std_logic;
        signal nlocked_i        : std_logic;
        signal reset_i          : std_logic;
        signal ckm              : std_ulogic;
        signal ckh              : std_ulogic;
        signal ckf              : std_ulogic;
        signal in_start         : std_logic;
        signal frame_scan       : std_logic;
   
        signal buf_cycle        : std_logic_vector(1 downto 0);
        signal out_run          : std_logic;
        signal out_cycle        : std_logic_vector(2 downto 0);
        signal outclk_short_i   : std_logic_vector(3 downto 0);
        signal CLKFBOUT_CLKFBIN : std_logic;
        signal out_en           : std_logic;
        signal nout_en          : std_logic;
        signal outdata_unbalanced : ubal_arr;
        signal deskew_cnt       : std_logic_vector(11 downto 0);
        signal deskew_out       : std_logic;
        signal deskew_state     : deskew_states;
        signal frame_sync       : std_logic;
        signal ckf_dly          : std_logic;
        signal en_balance       : std_logic;
        
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
        if locked_i = '0' then
            in_start <= '0';
        elsif ckf'event and ckf = '1' then
            in_start <= '1';
        end if;
    end process in_start_p;
    frame_scan_p: process(clk, in_start, buf_cycle)
    begin
        if in_start = '0' then
            frame_scan <= '0';
        elsif clk'event and clk = '1' and buf_cycle = "11" then
            frame_scan <= '1';
        end if;
    end process;
    frame_sync_p: process(clk, ckf, rst)
    begin
        if rst = '1' then
            ckf_dly <= '0';
        elsif clk'event and clk = '1' then
            ckf_dly <= ckf;
        end if;
    end process;
    frame_sync <= ckf and not ckf_dly;
    buf_cycle_p: process(clk, in_start)
    begin
        if in_start = '0' then
            buf_cycle <= "10";
        elsif clk'event and clk='1' then
            buf_cycle <= buf_cycle + 1;
        end if;
    end process buf_cycle_p;
    out_run_p: process(ckf, in_start)
    begin
        if rst = '1' then
            out_run <= '0';
        elsif ckf'event and ckf = '1' then
            out_run <= in_start;
        end if;
    end process out_run_p;
    out_cycle_p: process(ckm, out_run, out_cycle)
    begin
        if out_run = '0' or out_cycle = "111" then
            out_cycle <= (others => '0');
        elsif ckm'event and ckm = '1' then
            out_cycle <= out_cycle + 1;
        end if;
    end process;
    out_en_p: process(ckm, out_run)
    begin
        if rst = '1' then
            out_en <= '0';
        elsif ckm'event and ckm='1' then
            out_en <= out_run;
        end if;
    end process;
    deskew_p: process(clk, frame_scan, deskew_cnt, deskew, deskew_state, in_start)
    begin
        if rst = '1' then
            deskew_state <= RESET;
            deskew_cnt <= (others => '0');
        elsif clk'event and clk = '1' then
            case deskew_state is
                when RESET =>
                    if in_start = '1' then
                        deskew_state <= OUT_DESKEW;
                    end if;
                    deskew_cnt <= (others => '0');
                    deskew_out <= '0';
                when OUT_DESKEW =>
                    if and_many(deskew_cnt) = '1' then
                        deskew_state <= OUT_DATA;
                    end if;
                    deskew_cnt <= deskew_cnt + 1;
                    deskew_out <= '1';
                when OUT_DATA =>
                    if deskew = '1' then
                        deskew_state <= DESKEW_SYNC;
                    end if;
                    deskew_cnt <= (others => '0');
                    deskew_out <= '0';
                when DESKEW_SYNC =>
                    if frame_sync = '1' then
                        deskew_state <= OUT_DESKEW;
                    end if;
                    deskew_cnt <= (others => '0');
                    deskew_out <= '0';
            end case;
        end if;
    end process;

    outdata_unbalanced(0) <= reverse(e2( 5 downto  0));
    outdata_unbalanced(1) <= reverse(e2(13 downto  8));
    outdata_unbalanced(2) <= reverse(e2(21 downto 16));
    outdata_unbalanced(3) <= reverse(e2(23 downto 22) & e2(15 downto 14) & e2(7 downto 6));
    outdata_unbalanced(4) <= reverse(e1( 5 downto  0));
    outdata_unbalanced(5) <= reverse(e1(13 downto  8));
    outdata_unbalanced(6) <= reverse(e1(21 downto 16));
    outdata_unbalanced(7) <= reverse(e1(23 downto 22) & e1(15 downto 14) & e1(7 downto 6));
    nout_en <= not out_en;
    en_balance <= frame_scan and not deskew_out;

    outputs_generate: for i in 0 to 7 generate
        signal outdata_long     : data_arr;
        signal outdata_short    : std_logic_vector(3 downto 0);
        signal outdata_balanced : std_logic_vector(6 downto 0);
        signal outdata_final    : std_logic_vector(6 downto 0);
        signal tx               : std_ulogic;
        signal tq               : std_ulogic;
    begin
        balance_i: entity outbuf.balance
        port map(
            clk => clk,
            rst => rst,
            en => en_balance,
            unbalanced => outdata_unbalanced(i),
            balanced => outdata_balanced
        );
        outdata_final <= "1111000" when deskew_out = '1' and buf_cycle(0) = '1' else
                         "1110000" when deskew_out = '1' and buf_cycle(0) = '0' else
                         outdata_balanced;
        long_buf_p: process(clk, buf_cycle, frame_scan, outdata_final)
        begin
            if clk'event and clk = '1' and frame_scan = '1' then
                outdata_long(conv_integer(buf_cycle)) <= outdata_final;
            end if;
        end process long_buf_p;

        outdata_short_p: process(ckm, out_run, out_cycle, outdata_long)
        begin
            if out_run = '0' then
                outdata_short <= (others => '0');
            elsif ckm'event and ckm = '1' then
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

--    CLKOUT0_BUFG_INST : BUFG
--      port map (I=>CLKOUT0_BUF,
--                O=>CLKOUT0_OUT);
--   
--   CLKOUT1_BUFG_INST : BUFG
--      port map (I=>CLKOUT1_BUF,
--                O=>CLKOUT1_OUT);
   
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
                CLKOUT0=>ckh,
                CLKOUT1=>ckm,
                CLKOUT2=>ckf,
                CLKOUT3=>open,
                CLKOUT4=>open,
                CLKOUT5=>open,
                LOCKED=>locked_i);

    nlocked_i <= not locked_i;

    clk_generate: if 1 = 1 generate
        signal outdata_long     : data_arr;
        signal outdata_short    : std_logic_vector(3 downto 0);
        signal outdata_final    : std_logic_vector(6 downto 0);
        signal tx               : std_ulogic;
        signal tq               : std_ulogic;
    begin
        outdata_final <= "1111100" when deskew_out = '1' and buf_cycle(0) = '1' else
                         "1100000" when deskew_out = '1' and buf_cycle(0) = '0' else
                         "1100011" when deskew_out = '0' and buf_cycle(0) = '1' else
                         "1000011";
        long_buf_p: process(clk, buf_cycle, frame_scan, outdata_final)
        begin
            if clk'event and clk = '1' and frame_scan = '1' then
                outdata_long(conv_integer(buf_cycle)) <= outdata_final;
            end if;
        end process long_buf_p;

        outdata_short_p: process(ckm, out_run, out_cycle, outdata_long)
        begin
            if out_run = '0' then
                outdata_short <= (others => '0');
            elsif ckm'event and ckm = '1' then
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

