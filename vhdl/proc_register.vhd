-----------------------------------------------------------
-- implements register
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity proc_register is
port(
    avg_active          : in  std_logic;
    avg_done            : in  std_logic;
    avg_err             : in  std_logic;
    avg_rst             : out std_logic;
    avg_width           : out std_logic_vector(1 downto 0);
    core_L              : out std_logic_vector(11 downto 0);
    core_busy           : in  std_logic;
    core_circular       : out std_logic;
    core_done           : in  std_logic;
    core_iq             : out std_logic;
    core_n              : out std_logic_vector(4 downto 0);
    core_ov_cmul        : in  std_logic;
    core_ov_fft         : in  std_logic;
    core_ov_ifft        : in  std_logic;
    core_rst            : out std_logic;
    core_scale_cmul     : out std_logic_vector(1 downto 0);
    core_scale_sch      : out std_logic_vector(11 downto 0);
    core_scale_schi     : out std_logic_vector(11 downto 0);
    core_start          : out std_logic;
    depth               : out std_logic_vector(15 downto 0);
    rec_data_valid      : in  std_logic_vector(1 downto 0);
    rec_descramble      : out std_logic_vector(1 downto 0);
    rec_enable          : out std_logic_vector(1 downto 0);
    rec_input_select    : out std_logic_vector(0 downto 0);
    rec_input_select_changed : out std_logic;
    rec_polarity        : out std_logic_vector(1 downto 0);
    rec_rst             : out std_logic;
    rec_rxeqmix         : out t_cfg_array(1 downto 0);
    rec_stream_valid    : in  std_logic;
    trig_arm            : out std_logic;
    trig_armed          : in  std_logic;
    trig_int            : out std_logic;
    trig_rst            : out std_logic;
    trig_trigd          : in  std_logic;
    trig_type           : out std_logic;
    tx_busy             : in  std_logic;
    tx_dc_balance       : out std_logic;
    tx_deskew           : out std_logic;
    tx_frame_offset     : out std_logic_vector(15 downto 0);
    tx_muli             : out std_logic_vector(15 downto 0);
    tx_muli_wr          : out std_logic;
    tx_mulq             : out std_logic_vector(15 downto 0);
    tx_mulq_wr          : out std_logic;
    tx_ovfl             : in  std_logic;
    tx_ovfl_ack         : out std_logic;
    tx_resync           : out std_logic;
    tx_rst              : out std_logic;
    tx_sat              : out std_logic;
    tx_shift            : out std_logic_vector(1 downto 0);
    tx_shift_wr         : out std_logic;
    tx_toggle_buf       : out std_logic;
    tx_toggled          : in  std_logic;

-- CPU Interface

    fpga2bus_intr       : out std_logic_vector(15 downto 0);
    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    bus2fpga_wrce       : in  std_logic_vector(5 downto 0);
    bus2fpga_rdce       : in  std_logic_vector(5 downto 0);
    bus2fpga_be         : in  std_logic_vector(3 downto 0);
    bus2fpga_data       : in  std_logic_vector(31 downto 0);
    bus2fpga_reset      : in  std_logic;
    bus2fpga_clk        : in  std_logic
);
end proc_register;

architecture Structural of proc_register is

    type reg is array(5 downto 0) of std_logic_vector(31 downto 0);
    signal slv_reg                  : reg;

    signal rec_input_select_i       : std_logic_vector(0 downto 0);
    signal rec_input_select_r       : std_logic_vector(0 downto 0);
begin

-- x  rec_enable(0)                    1 0
-- x  rec_polarity(0)                  1 1
-- x  rec_descramble(0)                1 2
-- x  rec_rxeqmix(0)(0)                0 3
-- x  rec_rxeqmix(0)(1)                0 4
-- r  rec_data_valid(0)                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  rec_enable(1)                    1 0
-- x  rec_polarity(1)                  1 1
-- x  rec_descramble(1)                1 2
-- x  rec_rxeqmix(0)(1)                0 3
-- x  rec_rxeqmix(1)(1)                0 4
-- r  rec_data_valid(1)                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- 0  0                                0 0
-- 0  0                                0 1
-- 0  0                                0 2
-- 0  0                                0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  rec_input_select(0)              0 0
-- 0  0                                0 1
-- r  rec_stream_valid                 0 2
-- 0  0                                0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rec_rst                          0 7
-------------------------------------------------------------------------------
-- x  depth(0)                         0 0
-- x  depth(1)                         0 1
-- x  depth(2)                         0 2
-- x  depth(3)                         0 3
-- x  depth(4)                         0 4
-- x  depth(5)                         0 5
-- x  depth(6)                         0 6
-- x  depth(7)                         0 7
-- x  depth(8)                         0 0
-- x  depth(9)                         0 1
-- x  depth(10)                        0 2
-- x  depth(11)                        0 3
-- x  depth(12)                        0 4
-- x  depth(13)                        0 5
-- x  depth(14)                        0 6
-- x  depth(15)                        0 7
-- x  trig_type                        0 0
-- 0                                   0 1
-- t  trig_arm                         0 2  r  trig_armed
-- t  trig_int                         0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rst                              0 7
-- x  avg_width(0)                     0 0
-- x  avg_width(1)                     0 1
-- r  avg_active                       0 2
-- r  avg_err                          0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rst                              0 7
-------------------------------------------------------------------------------
-- x  core_scale_sch(0)                0 0
-- x  core_scale_sch(1)                1 1
-- x  core_scale_sch(2)                0 2
-- x  core_scale_sch(3)                1 3
-- x  core_scale_sch(4)                0 4
-- x  core_scale_sch(5)                1 5
-- x  core_scale_sch(6)                0 6
-- x  core_scale_sch(7)                1 7
-- x  core_scale_sch(8)                0 0
-- x  core_scale_sch(9)                1 1
-- x  core_scale_sch(10)               1 2
-- x  core_scale_sch(11)               0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  core_scale_schi(0)               0 0
-- x  core_scale_schi(1)               1 1
-- x  core_scale_schi(2)               0 2
-- x  core_scale_schi(3)               1 3
-- x  core_scale_schi(4)               0 4
-- x  core_scale_schi(5)               1 5
-- x  core_scale_schi(6)               0 6
-- x  core_scale_schi(7)               1 7
-- x  core_scale_schi(8)               0 0
-- x  core_scale_schi(9)               1 1
-- x  core_scale_schi(10)              1 2
-- x  core_scale_schi(11)              0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-------------------------------------------------------------------------------
-- x  core_L(0)                        0 0
-- x  core_L(1)                        0 1
-- x  core_L(2)                        0 2
-- x  core_L(3)                        0 3
-- x  core_L(4)                        0 4
-- x  core_L(5)                        0 5
-- x  core_L(6)                        0 6
-- x  core_L(7)                        0 7
-- x  core_L(8)                        0 0
-- x  core_L(9)                        0 1
-- x  core_L(10)                       0 2
-- x  core_L(11)                       0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- x  core_scale_cmul(0)               0 6
-- x  core_scale_cmul(1)               0 7
-- x  core_n(0)                        1 0
-- x  core_n(1)                        1 1
-- x  core_n(2)                        0 2
-- x  core_n(3)                        0 3
-- x  core_n(4)                        0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  core_iq                          0 0
-- t  core_start                       0 1  r  core_busy
-- r  core_ov_fft                      0 2
-- r  core_ov_ifft                     0 3
-- r  core_ov_cmul                     0 4
-- x  core_circular                    0 5
-- 0  0                                0 6
-- t  core_rst                         0 7
-------------------------------------------------------------------------------
-- x  tx_muli(0)                       0 0
-- x  tx_muli(1)                       0 1
-- x  tx_muli(2)                       0 2
-- x  tx_muli(3)                       0 3
-- x  tx_muli(4)                       0 4
-- x  tx_muli(5)                       0 5
-- x  tx_muli(6)                       0 6
-- x  tx_muli(7)                       0 7
-- x  tx_muli(8)                       0 0
-- x  tx_muli(9)                       0 1
-- x  tx_muli(10)                      0 2
-- x  tx_muli(11)                      0 3
-- x  tx_muli(12)                      0 4
-- x  tx_muli(13)                      0 5
-- x  tx_muli(14)                      0 6
-- x  tx_muli(15)                      0 7
-- x  tx_mulq(0)                       0 0
-- x  tx_mulq(1)                       0 1
-- x  tx_mulq(2)                       0 2
-- x  tx_mulq(3)                       0 3
-- x  tx_mulq(4)                       0 4
-- x  tx_mulq(5)                       0 5
-- x  tx_mulq(6)                       0 6
-- x  tx_mulq(7)                       0 7
-- x  tx_mulq(8)                       0 0
-- x  tx_mulq(9)                       0 1
-- x  tx_mulq(10)                      0 2
-- x  tx_mulq(11)                      0 3
-- x  tx_mulq(12)                      0 4
-- x  tx_mulq(13)                      0 5
-- x  tx_mulq(14)                      0 6
-- x  tx_mulq(15)                      0 7
-------------------------------------------------------------------------------
-- x  tx_frame_offset(0)               0 0
-- x  tx_frame_offset(1)               0 1
-- x  tx_frame_offset(2)               0 2
-- x  tx_frame_offset(3)               0 3
-- x  tx_frame_offset(4)               0 4
-- x  tx_frame_offset(5)               0 5
-- x  tx_frame_offset(6)               0 6
-- x  tx_frame_offset(7)               0 7
-- x  tx_frame_offset(8)               0 0
-- x  tx_frame_offset(9)               0 1
-- x  tx_frame_offset(10)              0 2
-- x  tx_frame_offset(11)              0 3
-- x  tx_frame_offset(12)              0 4
-- x  tx_frame_offset(13)              0 5
-- x  tx_frame_offset(14)              0 6
-- x  tx_frame_offset(15)              0 7
-- t  tx_deskew                        0 0
-- x  tx_dc_balance                    0 1
-- t  tx_toggle                        0 2  r  tx_busy
-- t  tx_resync                        0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  tx_rst                           0 7
-- 0  0                                0 0
-- 0  0                                0 1
-- 0  0                                0 2
-- 0  0                                0 3
-- x  tx_sat                           1 4
-- w  tx_ovfl                          0 5  r  tx_ovfl
-- x  tx_shift(0)                      0 6
-- x  tx_shift(1)                      0 7
    
    reciever_gen: for i in 0 to 1 generate
        signal recv_reg          : std_logic_vector(4 downto 0);
    begin
        rec_enable(i)   <= recv_reg(0);
        rec_polarity(i) <= recv_reg(1);
        rec_descramble(i) <= recv_reg(2);
        rec_rxeqmix(i)  <= recv_reg(4 downto 3);

        rec_gtx_write_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
        begin
            if rising_edge(bus2fpga_clk) then
                if bus2fpga_reset = '1' then
                    recv_reg <= "00111";
                else
                    if bus2fpga_wrce = "100000" and bus2fpga_be(i) = '1' then
                        recv_reg <= bus2fpga_data((i+1)*8-4 downto i*8);
                    end if;
                end if;
            end if;
        end process rec_gtx_write_proc;
        slv_reg(0)((i+1)*8-1 downto i*8) <= "00" & rec_data_valid(i) & recv_reg;
    end generate;

    rec_input_select_i <= slv_reg(0)(24 downto 24);
    rec_input_select <= rec_input_select_i;

    rec_input_select_changed <= or_many(rec_input_select_i xor rec_input_select_r);

    rec_input_select_changed_p: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            rec_input_select_r <= rec_input_select_i;
        end if;
    end process rec_input_select_changed_p;

    slv_reg(0)(26) <= rec_stream_valid;
    rec_rst <= bus2fpga_data(31) when bus2fpga_wrce = "100000" and bus2fpga_be(3) = '1' else
               '1' when bus2fpga_reset = '1' else
               '0';
    slv_reg(0)(23 downto 16) <= "00000000";
    slv_reg(0)(25) <= '0';
    slv_reg(0)(31 downto 27) <= "00000";
    write_proc0: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(0)(24 downto 24) <= "0";
            else
                if bus2fpga_wrce = "100000" and bus2fpga_be(3) = '1' then
                    slv_reg(0)(24 downto 24) <= bus2fpga_data(24 downto 24);
                end if;
            end if;
        end if;
    end process write_proc0;
-------------------------------------------------------------------------------
    depth     <= slv_reg(1)(15 downto 0);
    trig_type <= slv_reg(1)(16);
    trig_arm  <= bus2fpga_data(18) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                 '0';
    trig_int  <= bus2fpga_data(19) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                 '0';
    trig_rst  <= bus2fpga_data(23) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                 '1' when bus2fpga_reset = '1' else
                 '0';
    
    avg_width <= slv_reg(1)(25 downto 24);
    avg_rst   <= bus2fpga_data(31) when bus2fpga_wrce = "010000" and bus2fpga_be(3) = '1' else
                 '1' when bus2fpga_reset = '1' else
                 '0';
    
    write_proc1: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(1)(17 downto 0) <= (others => '0');
                slv_reg(1)(25 downto 24) <= (others => '0');
            else
                if bus2fpga_wrce = "010000" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(1)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(1)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(1)(17 downto 16) <= bus2fpga_data(17 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(1)(25 downto 24) <= bus2fpga_data(25 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc1;

    slv_reg(1)(18) <= trig_armed;
    slv_reg(1)(26) <= avg_active;
    slv_reg(1)(27) <= avg_err;

    slv_reg(1)(23 downto 19) <= (others => '0');
    slv_reg(1)(31 downto 28) <= (others => '0');
-------------------------------------------------------------------------------
    core_scale_sch  <= slv_reg(2)(11 downto 0);
    core_scale_schi <= slv_reg(2)(27 downto 16);
    
    write_proc2: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(2)(11 downto 0) <= "011010101010";
                slv_reg(2)(27 downto 16) <= "011010101010";
            else
                if bus2fpga_wrce = "001000" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(2)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(2)(11 downto 8) <= bus2fpga_data(11 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(2)(23 downto 16) <= bus2fpga_data(23 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(2)(27 downto 24) <= bus2fpga_data(27 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc2;

    slv_reg(2)(15 downto 12) <= (others => '0');
    slv_reg(2)(31 downto 28) <= (others => '0');
-------------------------------------------------------------------------------
    core_L          <= slv_reg(3)(11 downto 0);
    core_n          <= slv_reg(3)(20 downto 16);
    core_scale_cmul <= slv_reg(3)(15 downto 14);
    core_iq         <= slv_reg(3)(24);
    core_circular   <= slv_reg(3)(29);
    core_start      <= bus2fpga_data(25) when bus2fpga_wrce = "000100" and bus2fpga_be(3) = '1' else
                       '0';
    core_rst        <= bus2fpga_data(31) when bus2fpga_wrce = "000100" and bus2fpga_be(3) = '1' else
                       '1' when bus2fpga_reset = '1' else
                       '0';

    write_proc3: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(3)(11 downto 0) <= (others => '0');
                slv_reg(3)(15 downto 14) <= (others => '0');
                slv_reg(3)(20 downto 16) <= "00011";
                slv_reg(3)(24) <= '0';
                slv_reg(3)(29) <= '0';
            else
                if bus2fpga_wrce = "000100" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(3)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(3)(11 downto 8) <= bus2fpga_data(11 downto 8);
                        slv_reg(3)(15 downto 14) <= bus2fpga_data(15 downto 14);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(3)(20 downto 16) <= bus2fpga_data(20 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(3)(24) <= bus2fpga_data(24);
                        slv_reg(3)(29) <= bus2fpga_data(29);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc3;

    slv_reg(3)(25) <= core_busy;
    slv_reg(3)(26) <= core_ov_fft;
    slv_reg(3)(27) <= core_ov_ifft;
    slv_reg(3)(28) <= core_ov_cmul;

    slv_reg(3)(13 downto 12) <= (others => '0');
    slv_reg(3)(23 downto 21) <= (others => '0');
    slv_reg(3)(31 downto 30) <= (others => '0');
-------------------------------------------------------------------------------
    tx_muli_wr <= '1' when (bus2fpga_wrce = "000010" and (bus2fpga_be(0) = '1' or bus2fpga_be(1) = '1')) or bus2fpga_reset = '1' else
                  '0';
    tx_muli    <= slv_reg(4)(15 downto 0);
    tx_mulq_wr <= '1' when (bus2fpga_wrce = "000010" and (bus2fpga_be(2) = '1' or bus2fpga_be(3) = '1')) or bus2fpga_reset = '1' else
                  '0';
    tx_mulq    <= slv_reg(4)(31 downto 16);

    write_proc4: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(4)(31 downto 0) <= (others => '0');
            else
                if bus2fpga_wrce = "000010" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(4)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(4)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(4)(23 downto 16) <= bus2fpga_data(23 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(4)(31 downto 24) <= bus2fpga_data(31 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc4;
-------------------------------------------------------------------------------
    tx_frame_offset <= slv_reg(5)(15 downto 0);

    tx_deskew       <= bus2fpga_data(16) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    tx_dc_balance   <= slv_reg(5)(17);
    tx_toggle_buf   <= bus2fpga_data(18) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    tx_resync       <= bus2fpga_data(19) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    tx_rst          <= bus2fpga_data(23) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                     '1' when bus2fpga_reset = '1' else
                     '0';
    tx_sat          <= slv_reg(5)(28);

    tx_shift_wr     <= '1' when (bus2fpga_wrce = "000001" and bus2fpga_be(3) = '1') or bus2fpga_reset = '1' else
                       '0';
    tx_shift        <= slv_reg(5)(31 downto 30);

    write_proc5: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(5)(15 downto 0) <= (others => '0');
                slv_reg(5)(17) <= '0';
                slv_reg(5)(28) <= '1';
                slv_reg(5)(31 downto 30) <= (others => '0');
            else
                if bus2fpga_wrce = "000001" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(5)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(5)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(5)(17) <= bus2fpga_data(17);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(5)(28) <= bus2fpga_data(28);
                        slv_reg(5)(31 downto 30) <= bus2fpga_data(31 downto 30);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc5;

    tx_ovfl_ack <= '1' when bus2fpga_wrce = "000001" and bus2fpga_be(3) = '1' and bus2fpga_data(29) = '0' else
                   '0';

    slv_reg(5)(16) <= '0';
    slv_reg(5)(18) <= tx_busy;
    slv_reg(5)(27 downto 19) <= (others => '0');
    slv_reg(5)(29) <= tx_ovfl;
--=============================================================================
    slave_reg_read_proc: process(bus2fpga_rdce, slv_reg)
    begin
        case bus2fpga_rdce is
            when "100000" => fpga2bus_data <= slv_reg(0);
            when "010000" => fpga2bus_data <= slv_reg(1);
            when "001000" => fpga2bus_data <= slv_reg(2);
            when "000100" => fpga2bus_data <= slv_reg(3);
            when "000010" => fpga2bus_data <= slv_reg(4);
            when "000001" => fpga2bus_data <= slv_reg(5);
            when others => fpga2bus_data <= (others => '0');
        end case;
    end process slave_reg_read_proc;

    fpga2bus_intr <= (
        0  => slv_reg(0)(5),
        1  => not slv_reg(0)(5),
        2  => slv_reg(0)(13),
        3  => not slv_reg(0)(13),
        4  => slv_reg(0)(26),
        5  => not slv_reg(0)(26),
        6  => trig_trigd,
        7  => avg_done,
        8  => core_done,
        9  => tx_toggled,
        10 => slv_reg(5)(29),
        others => '0');

    fpga2bus_rdack <= or_many(bus2fpga_rdce);
    fpga2bus_wrack <= or_many(bus2fpga_wrce);
    fpga2bus_error <= '0';

end Structural;

