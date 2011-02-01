-----------------------------------------------------------
-- Project          : 
-- File             : proc2fpga.vhd
-- Author           : Gernot Vormayr
-- created          : July, 3rd 2009
-- last mod. by     : 
-- last mod. on     : 
-- contents         : 
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity proc2fpga is
port(
    rx_polarity          : out std_logic_vector(2 downto 0);
    rx_descramble        : out std_logic_vector(2 downto 0);
    rx_rxeqmix           : out t_cfg_array(2 downto 0);
    rx_data_valid        : in  std_logic_vector(2 downto 0);
    rx_enable            : out std_logic_vector(2 downto 0);
    rx_input_select      : out std_logic_vector(1 downto 0);
    rx_stream_valid      : in  std_logic;
    depth                : out std_logic_vector(15 downto 0);
    width                : out std_logic_vector(1 downto 0);
    arm_req              : out std_logic;
    arm_ack              : in  std_logic;
    rst_req              : out std_logic;
    rst_ack              : in  std_logic;
    avg_done             : in  std_logic;
    locked               : in  std_logic;
    tx_deskew_req        : out std_logic;
    tx_deskew_ack        : in  std_logic;
    mem_req              : out std_logic;
    mem_ack              : in  std_logic;

    fpga2bus_intr        : out std_logic_vector(31 downto 0);
    fpga2bus_error       : out std_logic;
    fpga2bus_wrack       : out std_logic;
    fpga2bus_rdack       : out std_logic;
    fpga2bus_data        : out std_logic_vector(31 downto 0);
    bus2fpga_wrce        : in  std_logic_vector(3 downto 0);
    bus2fpga_rdce        : in  std_logic_vector(3 downto 0);
    bus2fpga_be          : in  std_logic_vector(3 downto 0);
    bus2fpga_data        : in  std_logic_vector(31 downto 0);
    bus2fpga_addr        : in  std_logic_vector(15 downto 0);
    bus2fpga_reset       : in  std_logic;
    bus2fpga_clk         : in  std_logic
);
end proc2fpga;

architecture Structural of proc2fpga is
    type toggle_state is (RESET, OUT_TOG, WAIT_FINISH);

    signal slv_reg0             : std_logic_vector(31 downto 0);
    signal slv_reg1             : std_logic_vector(31 downto 0);
    signal slv_reg2             : std_logic_vector(31 downto 0);
    signal slv_reg3             : std_logic_vector(31 downto 0);

    signal arm_state            : toggle_state;
    signal arm_ack_sync         : std_logic;
    signal rst_state            : toggle_state;
    signal rst_ack_sync         : std_logic;
    signal tx_deskew_state      : toggle_state;
    signal tx_deskew_ack_sync   : std_logic;
begin

--reciever:
--    x  enable      ASYNC    1 0
--    x  polarity    SYNC_GTX 1 1
--    x  descramble  SYNC_GTX 1 2
--    x  rxeqmix[0]  ASYNC    0 3
--    x  rxeqmix[0]  ASYNC    0 4
--    r  data_valid  SYNC_PLB 0 5
--    0  0                    0 6
--    0  0                    0 7
--MUX:
--    x  select[0]   ASYNC    0 0
--    x  select[1]   ASYNC    0 1
--    r  data_valid  SYNC_PLB 0 2
--    0  0                    0 3
--    0  0                    0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--MEM:
--    t  arm         SYNC_GTX 0 0
--    r  done        SYNC_PLB 0 1
--    t  rst         SYNC_GTX 0 2
--    r  locked      SYNC_PLB 0 3
--    x  read_req             0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--    WI,DEPTH       ASYNC
--TX:
--    t  deskew      SYNC_GTX 0 0
--    0  0                    0 1
--    0  0                    0 2
--    0  0                    0 3
--    0  0                    0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--        <   3  ><   2  ><   1  ><   0  >
--        76543210765432107654321076543210
--  REG0: 00000vSE00vRXdpe00vRXdpe00vRXdpe   GTX
--  REG1: 00aqlrds000000WI<     DEPTH    >   MEM
--  REG2:                                    FFT
--  REG3:                                d   OUT
    
-- reciever:
    reciever_gen: for i in 0 to 2 generate
        signal recv_reg          : std_logic_vector(4 downto 0);
        signal data_valid_synced : std_logic;
    begin
        rx_enable(i)     <= recv_reg(0);
        rx_polarity(i)   <= recv_reg(1);
        rx_descramble(i) <= recv_reg(2);
        rx_rxeqmix(i)    <= recv_reg(4 downto 3);

        sync_data_valid_i: entity work.flag
        port map(
            flag_in      => rx_data_valid(i),
            flag_out     => data_valid_synced,
            clk          => bus2fpga_clk
        );

        recv_write_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
        begin
            if rising_edge(bus2fpga_clk) then
                if bus2fpga_reset = '1' then
                    recv_reg <= "00111";
                else
                    if bus2fpga_wrce = "1000" and bus2fpga_be(i) = '1' then
                        recv_reg <= bus2fpga_data((i+1)*8-4 downto i*8);
                    end if;
                end if;
            end if;
        end process recv_write_proc;
        slv_reg0((i+1)*8-1 downto i*8) <= "00" & data_valid_synced & recv_reg;
        fpga2bus_intr(i) <= data_valid_synced;
    end generate;

-- MUX:
    rx_input_select <= slv_reg0(25 downto 24);
    sync_stream_valid_i: entity work.flag
    port map(
        flag_in     => rx_stream_valid,
        flag_out    => slv_reg0(26),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(3) <= slv_reg0(26);
    slv_reg0(31 downto 27) <= "00000";
    mux_write_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg0(25 downto 24) <= "00";
            else
                if bus2fpga_wrce = "1000" and bus2fpga_be(3) = '1' then
                    slv_reg0(25 downto 24) <= bus2fpga_data(25 downto 24);
                end if;
            end if;
        end if;
    end process mux_write_proc;
--MEM:
    depth <= slv_reg1(15 downto 0);
    width <= slv_reg1(17 downto 16);
    sync_arm_ack_i: entity work.flag
    port map(
        flag_in     => arm_ack,
        flag_out    => arm_ack_sync,
        clk         => bus2fpga_clk
    );
    arm_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce, arm_state)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                arm_state <= RESET;
            else
                case arm_state is
                    when RESET =>
                        if bus2fpga_wrce = "0100" and bus2fpga_be(3) = '1' then
                            if bus2fpga_data(24) = '1' then
                                arm_state <= OUT_TOG;
                            end if;
                        end if;
                        slv_reg1(24) <= '0';
                        arm_req      <= '0';
                    when OUT_TOG =>
                        if arm_ack_sync = '1' then
                            arm_state <= WAIT_FINISH;
                        end if;
                        slv_reg1(24) <= '1';
                        arm_req      <= '1';
                    when WAIT_FINISH =>
                        if arm_ack_sync = '0' then
                            arm_state <= RESET;
                        end if;
                        slv_reg1(24) <= '1';
                        arm_req      <= '0';
                end case;
            end if;
        end if;
    end process;
    sync_done_i: entity work.flag
    port map(
        flag_in     => avg_done,
        flag_out    => slv_reg1(25),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(4) <= slv_reg1(25);
    sync_rst_ack_i: entity work.flag
    port map(
        flag_in     => rst_ack,
        flag_out    => rst_ack_sync,
        clk         => bus2fpga_clk
    );
    rst_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rst_state <= RESET;
            else
                case rst_state is
                    when RESET =>
                        if bus2fpga_wrce = "0100" and bus2fpga_be(3) = '1' then
                            if bus2fpga_data(26) = '1' then
                                rst_state <= OUT_TOG;
                            end if;
                        end if;
                        slv_reg1(26) <= '0';
                        rst_req      <= '0';
                    when OUT_TOG =>
                        if rst_ack_sync = '1' then
                            rst_state <= WAIT_FINISH;
                        end if;
                        slv_reg1(26) <= '1';
                        rst_req      <= '1';
                    when WAIT_FINISH =>
                        if rst_ack_sync = '0' then
                            rst_state <= RESET;
                        end if;
                        slv_reg1(26) <= '1';
                        rst_req      <= '0';
                end case;
            end if;
        end if;
    end process;
    sync_locked_i: entity work.flag
    port map(
        flag_in     => locked,
        flag_out    => slv_reg1(27),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(5) <= slv_reg1(27);
    sync_locked_inst: entity work.flag
    port map(
        flag_in     => mem_ack,
        flag_out    => slv_reg1(28),
        clk         => bus2fpga_clk
    );
    slv_reg1(23 downto 18) <= "000000";
    slv_reg1(31 downto 30) <= "00";
    mem_write_proc: process(bus2fpga_clk) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg1(17 downto 0) <= (others => '0');
                mem_req <= '0';
            else
                if bus2fpga_wrce = "0100" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg1(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg1(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg1(17 downto 16) <= bus2fpga_data(17 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        mem_req <= bus2fpga_data(28);
                    end if;
                end if;
            end if;
        end if;
    end process mem_write_proc;
--TX
    sync_tx_deskew_ack_i: entity work.flag
    port map(
        flag_in     => tx_deskew_ack,
        flag_out    => tx_deskew_ack_sync,
        clk         => bus2fpga_clk
    );
    tx_deskew_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                tx_deskew_state <= RESET;
            else
                case tx_deskew_state is
                    when RESET =>
                        if bus2fpga_wrce = "0001" and bus2fpga_be(0) = '1' then
                            if bus2fpga_data(0) = '1' then
                                tx_deskew_state <= OUT_TOG;
                            end if;
                        end if;
                        slv_reg3(0)   <= '0';
                        tx_deskew_req <= '0';
                    when OUT_TOG =>
                        if tx_deskew_ack_sync = '1' then
                            tx_deskew_state <= WAIT_FINISH;
                        end if;
                        slv_reg3(0)   <= '1';
                        tx_deskew_req <= '1';
                    when WAIT_FINISH =>
                        if tx_deskew_ack_sync = '0' then
                            tx_deskew_state <= RESET;
                        end if;
                        slv_reg3(0)   <= '1';
                        tx_deskew_req <= '0';
                end case;
            end if;
        end if;
    end process;

    slave_reg_read_proc : process(bus2fpga_rdce, slv_reg0, slv_reg1, slv_reg2, slv_reg3) is
    begin
        case bus2fpga_rdce is
            when "1000" => fpga2bus_data <= slv_reg0;
            when "0100" => fpga2bus_data <= slv_reg1;
            when "0010" => fpga2bus_data <= slv_reg2;
            when "0001" => fpga2bus_data <= slv_reg3;
            when others => fpga2bus_data <= (others => '0');
        end case;
    end process slave_reg_read_proc;

    -- 0 rec0_valid
    -- 1 rec1_valid
    -- 2 rec2_valid
    -- 3 stream_valid
    -- 4 done
    -- 5 locked
    fpga2bus_intr(31 downto 6) <= (others=>'0');

    fpga2bus_rdack <= or_many(bus2fpga_rdce);
    fpga2bus_wrack <= or_many(bus2fpga_wrce);
    fpga2bus_error <= '0';

end Structural;

