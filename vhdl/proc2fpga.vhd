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
    rx_input_select_req  : out std_logic;
    rx_stream_valid      : in  std_logic;
    depth                : out std_logic_vector(15 downto 0);
    depth_req            : out std_logic;
    width                : out std_logic_vector(1 downto 0);
    width_req            : out std_logic;
    arm                  : out std_logic;
    rx_rst               : out std_logic;
    tx_rst               : out std_logic;
    avg_done             : in  std_logic;
    locked               : in  std_logic;
    tx_deskew            : out std_logic;
    mem_req              : out std_logic;
    mem_ack              : in  std_logic;
    dc_balance           : out std_logic;
    muli                 : out std_logic_vector(15 downto 0);
    muli_req             : out std_logic;
    mulq                 : out std_logic_vector(15 downto 0);
    mulq_req             : out std_logic;
    buf_used             : in  std_logic;
    toggle_buf           : out std_logic;

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
    signal slv_reg0              : std_logic_vector(31 downto 0);
    signal slv_reg1              : std_logic_vector(31 downto 0);
    signal slv_reg2              : std_logic_vector(31 downto 0);
    signal slv_reg3              : std_logic_vector(31 downto 0);

    signal rx_input_select_req_r : std_logic;
    signal muli_req_r            : std_logic;
    signal mulq_req_r            : std_logic;
    signal arm_r                 : std_logic;
    signal rx_rst_r              : std_logic;
	signal tx_deskew_r           : std_logic;
	signal tx_rst_r              : std_logic;
	signal toggle_buf_r			 : std_logic;
	signal width_req_r			 : std_logic;
	signal depth_req_r           : std_logic;
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
--    x  read_req    SYNC_GTX 0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--    WI,DEPTH       ASYNC
--TX:
--    t  deskew      SYNC_GTX 0 0
--    x  dc_balance  SYNC_GTX 0 1
--    t  reset       SYNC_GTX 0 2
--    x  buf_used    SYNC_GTX 0 3
--    0  0                    0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--        <   3  ><   2  ><   1  ><   0  >
--        76543210765432107654321076543210
--  REG0: 00000vSE00vRXdpe00vRXdpe00vRXdpe   GTX
--  REG1: 000qlrda000000WI<     DEPTH    >   MEM
--  REG2: <     MULQ     ><     MULI     >   MUL 
--  REG3:                             urbd   OUT
    
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
        fpga2bus_intr(i*2) <= data_valid_synced;
        fpga2bus_intr((i+1)*2-1) <= not data_valid_synced;
    end generate;

-- MUX:
    rx_input_select <= slv_reg0(25 downto 24);
    sync_stream_valid_i: entity work.flag
    port map(
        flag_in     => rx_stream_valid,
        flag_out    => slv_reg0(26),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(6) <= slv_reg0(26);
    fpga2bus_intr(7) <= not slv_reg0(26);
    slv_reg0(31 downto 27) <= "00000";
    mux_write_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg0(25 downto 24) <= "00";
                rx_input_select_req_r <= '0';
            else
                if bus2fpga_wrce = "1000" and bus2fpga_be(3) = '1' then
                    slv_reg0(25 downto 24) <= bus2fpga_data(25 downto 24);
                    rx_input_select_req_r <= not rx_input_select_req_r;
                end if;
            end if;
        end if;
    end process mux_write_proc;
	rx_input_select_req <= rx_input_select_req_r;
--MEM:
    depth <= slv_reg1(15 downto 0);
    width <= slv_reg1(17 downto 16);
    arm_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce, bus2fpga_be, bus2fpga_data)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                arm_r <= '0';
            else
                if bus2fpga_wrce = "0100" and bus2fpga_be(3) = '1' then
                    if bus2fpga_data(24) = '1' then
                        arm_r <= not arm_r;
                    end if;
                end if;
            end if;
        end if;
    end process;
	arm <= arm_r;
    sync_done_i: entity work.flag
    port map(
        flag_in     => avg_done,
        flag_out    => slv_reg1(25),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(8) <= slv_reg1(25);
    rst_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce, bus2fpga_be, bus2fpga_data)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rx_rst_r <= '0';
            else
                if bus2fpga_wrce = "0100" and bus2fpga_be(3) = '1' then
                    if bus2fpga_data(26) = '1' then
                        rx_rst_r <= not rx_rst_r;
                    end if;
                end if;
            end if;
        end if;
    end process;
	rx_rst <= rx_rst_r;
    sync_locked_i: entity work.flag
    port map(
        flag_in     => locked,
        flag_out    => slv_reg1(27),
        clk         => bus2fpga_clk
    );
    fpga2bus_intr(9) <= slv_reg1(27);
    fpga2bus_intr(10) <= not slv_reg1(27);
    sync_mem_ack_i: entity work.flag
    port map(
        flag_in     => mem_ack,
        flag_out    => slv_reg1(28),
        clk         => bus2fpga_clk
    );
    slv_reg1(23 downto 18) <= "000000";
    slv_reg1(31 downto 29) <= "000";
    mem_write_proc: process(bus2fpga_clk) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg1(17 downto 0) <= (others => '0');
                mem_req <= '0';
				depth_req_r <= '0';
				width_req_r <= '0';
            else
                if bus2fpga_wrce = "0100" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg1(7 downto 0) <= bus2fpga_data(7 downto 0);
						depth_req_r <= not depth_req_r;
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg1(15 downto 8) <= bus2fpga_data(15 downto 8);
						depth_req_r <= not depth_req_r;
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg1(17 downto 16) <= bus2fpga_data(17 downto 16);
						width_req_r <= not width_req_r;
                    end if;
                    if bus2fpga_be(3) = '1' then
                        mem_req <= bus2fpga_data(28);
                    end if;
                end if;
            end if;
        end if;
    end process mem_write_proc;
	width_req <= width_req_r;
	depth_req <= depth_req_r;
--MUL
    muli <= slv_reg2(15 downto 0);
    mulq <= slv_reg2(31 downto 16);
    mul_write_proc: process(bus2fpga_clk) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg2(17 downto 0) <= (others => '0');
                muli_req_r <= '0';
                mulq_req_r <= '0';
            else
                if bus2fpga_wrce = "0010" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg2(7 downto 0) <= bus2fpga_data(7 downto 0);
                        muli_req_r <= not muli_req_r;
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg2(15 downto 8) <= bus2fpga_data(15 downto 8);
                        muli_req_r <= not muli_req_r;
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg2(23 downto 16) <= bus2fpga_data(23 downto 16);
                        mulq_req_r <= not mulq_req_r;
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg2(31 downto 24) <= bus2fpga_data(31 downto 24);
                        mulq_req_r <= not mulq_req_r;
                    end if;
                end if;
            end if;
        end if;
    end process mul_write_proc;
	muli_req <= muli_req_r;
	mulq_req <= mulq_req_r;
	slv_reg1(24) <= '0';
	slv_reg1(26) <= '0';
--TX
    tx_process: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce, bus2fpga_be, bus2fpga_data)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                tx_deskew_r <= '0';
                tx_rst_r <= '0';
                toggle_buf_r <= '0';
            else
                if bus2fpga_wrce = "0001" and bus2fpga_be(0) = '1' then
                    if bus2fpga_data(0) = '1' then
                        tx_deskew_r <= not tx_deskew_r;
                    end if;
                    if bus2fpga_data(2) = '1' then
                        tx_rst_r <= not tx_rst_r;
                    end if;
                    if bus2fpga_data(3) = '1' then
                        toggle_buf_r <= not toggle_buf_r;
                    end if;
                end if;
            end if;
        end if;
    end process;
	tx_deskew  <= tx_deskew_r;
	tx_rst     <= tx_rst_r;
	toggle_buf <= toggle_buf_r;
    dc_balance <= slv_reg3(1);
    tx_write_proc: process(bus2fpga_clk) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg3(1) <= '0';
            else
                if bus2fpga_wrce = "0001" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg3(1) <= bus2fpga_data(1);
                    end if;
                end if;
            end if;
        end if;
    end process tx_write_proc;
    sync_buf_used_i: entity work.flag
    port map(
        flag_in     => buf_used,
        flag_out    => slv_reg3(3),
        clk         => bus2fpga_clk
    );
    slv_reg3(31 downto 4) <= (others => '0');
    slv_reg3(2) <= '0';
    slv_reg3(0) <= '0';

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
    -- 1 not rec0_valid
    -- 2 rec1_valid
    -- 3 not rec1_valid
    -- 4 rec2_valid
    -- 5 not rec2_valid
    -- 6 stream_valid
    -- 7 not stream_valid
    -- 8 done
    -- 9 locked
    -- 10 not locked
    fpga2bus_intr(31 downto 11) <= (others=>'0');

    fpga2bus_rdack <= or_many(bus2fpga_rdce);
    fpga2bus_wrack <= or_many(bus2fpga_wrce);
    fpga2bus_error <= '0';

end Structural;

