-----------------------------------------------------------
-- main
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity main is
port(
-- signals for gtx transciever
    refclk              : in  std_logic;
    rxn                 : in  std_logic_vector(3 downto 0);
    rxp                 : in  std_logic_vector(3 downto 0);
    txn                 : out std_logic_vector(3 downto 0);
    txp                 : out std_logic_vector(3 downto 0);

-- control signals receiver
    rec_polarity        : in  std_logic_vector(2 downto 0);
    rec_descramble      : in  std_logic_vector(2 downto 0);
    rec_rxeqmix         : in  t_cfg_array(2 downto 0);
    rec_data_valid      : out std_logic_vector(2 downto 0);
    rec_enable          : in  std_logic_vector(2 downto 0);
    rec_input_select    : in  std_logic_vector(1 downto 0);
    rec_input_select_req : in std_logic;
    rec_stream_valid    : out std_logic;
    sample_clk          : out std_logic;

-- control signals inbuf
    depth               : in  std_logic_vector(15 downto 0);
    depth_req           : in  std_logic;
    width               : in  std_logic_vector(1 downto 0);
    width_req           : in  std_logic;

    arm                 : in  std_logic;
    trigger_ext         : in  std_logic; --debounce
    trigger_int         : in  std_logic; --sync
	trigger_type		: in  std_logic;
	trigger_type_req    : in  std_logic;

    auto_conv           : in std_logic;
    auto_switch         : in std_logic;
    convolute_req       : in std_logic;
    switch_req          : in std_logic;
    cpu_req             : in std_logic;
    
);
end inbuf;

architecture Structural of main is



    signal avg_done            : std_logic;
    signal data_clk            : std_logic; -- recovered clk
    signal fft_clk             : std_logic; -- fft clk = data_clk*2
    signal fft_clku            : std_logic; -- fft clk unbuffered
    signal clkfb               : std_logic; -- feedback clk
    signal rst_out_i           : std_logic;
    signal rec_data_i          : t_data_array(2 downto 0);
    signal data_i              : t_data;
    signal rec_data_valid_i    : std_logic_vector(2 downto 0);
    signal stream_valid_i      : std_logic;
    signal rec_polarity_synced : std_logic_vector(2 downto 0);
    signal rec_enable_synced   : std_logic_vector(2 downto 0);

    signal arm_synced          : std_logic;
    signal arm_synced_dly      : std_logic;
    signal arm_toggle          : std_logic;

    signal select_synced       : std_logic;
    signal select_synced_dly   : std_logic;
    signal select_toggle       : std_logic;
	signal trigger_type_synced : std_logic;
	signal trigger_type_synced_dly : std_logic;
	signal trigger_toggle	   : std_logic;
    signal depth_synced        : std_logic;
    signal depth_synced_dly    : std_logic;
    signal depth_toggle        : std_logic;
    signal width_synced        : std_logic;
    signal width_synced_dly    : std_logic;
    signal width_toggle        : std_logic;
	signal trigger_type_r	   : std_logic;
    signal select_r            : std_logic_vector(1 downto 0);
    signal width_r             : std_logic_vector(1 downto 0);
    signal depth_r             : std_logic_vector(15 downto 0);

    signal inbuf_addr_data     : std_logic_vector(15 downto 0);
    signal inbuf_we            : std_logic;
    signal inbuf_data_out      : std_logic_vector(15 downto 0);
    signal inbuf_data_in       : std_logic_vector(15 downto 0);

	signal trig				   : std_logic;
	signal frame_trg		   : std_logic;
    signal pll_locked          : std_logic;
    signal dcm_locked          : std_logic;
    signal auto_conv_syn       : std_logic;
    signal auto_switch_syn     : std_logic;
    signal convolute_req_syn   : std_logic;
    signal switch_req_syn      : std_logic;
    signal cpu_req_syn         : std_logic;
    signal conv_done           : std_logic;
begin
    sync_gen: for i in 0 to 2 generate
        sync_enable_i: entity work.flag
        port map(
            flag_in      => rec_enable(i),
            flag_out     => rec_enable_synced(i),
            clk          => data_clk
        );
        sync_polarity_i: entity work.flag
        port map(
            flag_in      => rec_polarity(i),
            flag_out     => rec_polarity_synced(i),
            clk          => data_clk
        );
    end generate;
    sync_arm_i: entity work.flag
    port map(
        flag_in      => arm,
        flag_out     => arm_synced,
        clk          => data_clk
    );
    arm_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            arm_synced_dly <= arm_synced;
        end if;
    end process;
    arm_toggle <= arm_synced_dly xor arm_synced;

    work_clk_gen : DCM_BASE
    generic map (
        CLKIN_DIVIDE_BY_2 => FALSE,
        CLKIN_PERIOD => 10.0,
        CLK_FEEDBACK => "1X",
        DCM_PERFORMANCE_MODE => "MAX_SPEED",
        DFS_FREQUENCY_MODE => "LOW",
        DLL_FREQUENCY_MODE => "LOW",
        DUTY_CYCLE_CORRECTION => TRUE,
        FACTORY_JF => X"F0F0",
        PHASE_SHIFT => 0,
        STARTUP_WAIT => FALSE)
    port map (
        CLK0 => clkfb,
        CLK180 => open,
        CLK270 => open,
        CLK2X => fft_clku,
        CLK2X180 => open,
        CLK90 => open,
        CLKDV => open,
        CLKFX => open,
        CLKFX180 => open,
        LOCKED => dcm_locked,
        CLKFB => clkfb,
        CLKIN => data_clk,
        RST => not pll_locked
    );

    fft_clku_i : BUFG
    port map
    (
        I            => fft_clku,
        O            => fft_clk
    );

    sync_select_i: entity work.flag
    port map(
        flag_in      => rec_input_select_req,
        flag_out     => select_synced,
        clk          => data_clk
    );
    select_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            select_synced_dly <= select_synced;
        end if;
    end process;
    select_toggle <= select_synced_dly xor select_synced;
	select_r_p: process(data_clk, rst, select_toggle, rec_input_select)
    begin
        if rst = '1' then
            select_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if select_toggle = '1' then
                select_r <= rec_input_select;
            end if;
        end if;
    end process;

    sync_depth_i: entity work.flag
    port map(
        flag_in      => depth_req,
        flag_out     => depth_synced,
        clk          => data_clk
    );
    depth_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            depth_synced_dly <= depth_synced;
        end if;
    end process;
    depth_toggle <= depth_synced_dly xor depth_synced;
    depth_r_p: process(data_clk, rst, depth_toggle, depth)
    begin
        if rst = '1' then
            depth_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if depth_toggle = '1' then
                depth_r <= depth;
            end if;
        end if;
    end process;
    sync_width_i: entity work.flag
    port map(
        flag_in      => width_req,
        flag_out     => width_synced,
        clk          => data_clk
    );
    width_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            width_synced_dly <= width_synced;
        end if;
    end process;
    width_toggle <= width_synced_dly xor width_synced;
    width_r_p: process(data_clk, rst, width_toggle, width)
    begin
        if rst = '1' then
            width_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if width_toggle = '1' then
                width_r <= width;
            end if;
        end if;
    end process;
    sync_trigger_type_i: entity work.flag
    port map(
        flag_in      => trigger_type_req,
        flag_out     => trigger_type_synced,
        clk          => data_clk
    );
    trigger_type_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            trigger_type_synced_dly <= trigger_type_synced;
        end if;
    end process;
    trigger_type_toggle <= trigger_type_synced_dly xor trigger_type_synced;
    trigger_type_r_p: process(data_clk, rst, trigger_type_toggle, trigger_type)
    begin
        if rst = '1' then
            trigger_type_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if trigger_type_toggle = '1' then
                trigger_type_r <= trigger_type;
            end if;
        end if;
    end process;

    sync_auto_conv_i: entity work.flag
    port map(
        flag_in      => auto_conv,
        flag_out     => auto_conv_syn,
        clk          => data_clk
    );
    sync_auto_switch_i: entity work.flag
    port map(
        flag_in      => auto_switch,
        flag_out     => auto_switch_syn,
        clk          => data_clk
    );
    sync_convolute_req_i: entity work.flag
    port map(
        flag_in      => convolute_req,
        flag_out     => convolute_req_syn,
        clk          => data_clk
    );
    sync_switch_req_i: entity work.flag
    port map(
        flag_in      => switch_req,
        flag_out     => switch_req_syn,
        clk          => data_clk
    );
    sync_cpu_req_i: entity work.flag
    port map(
        flag_in      => cpu_req,
        flag_out     => cpu_req_syn,
        clk          => data_clk
    );
	

    overlap_add_i: entity work.overlap_add
    port map(
        clk          => fft_clk,
        rst          => --fixme

        start        => --fixme
        nfft         => --fixme
        scale_sch    => --fixme
        scale_schi   => --fixme
        cmul_sch     => --fixme
        L            => --fixme
        n            => depth_r,
        iq           => --fixme

        wave_index   => --fixme
        x_in         => --fixme
        x_index      => --fixme

        y_re_in      => --fixme
        y_im_in      => --fixme
        y_re_out     => --fixme
        y_im_out     => --fixme
        y_index      => --fixme
        y_we         => --fixme

        h_re_in      => --fixme
        h_im_in      => --fixme
        h_index      => --fixme

        ovfl_fft     => --fixme
        ovfl_ifft    => --fixme
        ovfl_cmul    => --fixme

        busy         => --fixme
        done         => conv_done
    );

    --outbuf

    sync_mem_i: entity work.flag
    port map(
        flag_in      => mem_req,
        flag_out     => mem,
        clk          => clk
    );
    mem_p: process(clk)
    begin
        if rising_edge(clk) then
            mem_ack <= mem;
        end if;
    end process;
    sync_deskew_i: entity work.flag
    port map(
        flag_in      => tx_deskew,
        flag_out     => deskew_synced,
        clk          => clk
    );
    deskew_dly: process(clk)
    begin
        if rising_edge(clk) then
            deskew_synced_dly <= deskew_synced;
        end if;
    end process;
    deskew <= deskew_synced_dly xor deskew_synced;
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst,
        flag_out     => rst_synced,
        clk          => clk
    );
    rst_dly: process(clk)
    begin
        if rising_edge(clk) then
            rst_synced_dly <= rst_synced;
        end if;
    end process;
    rst_toggle <= rst_synced_dly xor rst_synced;
    rst_i <= or_many(rst_toggle & bus2fpga_reset & (not pll_locked));
    
    sync_dc_balance: entity work.flag
    port map(
        flag_in      => dc_balance,
        flag_out     => dc_balance_sync,
        clk          => clk
    );
    sync_depth_i: entity work.flag
    port map(
        flag_in      => depth_req,
        flag_out     => depth_synced,
        clk          => clk
    );
    depth_dly: process(clk)
    begin
        if rising_edge(clk) then
            depth_synced_dly <= depth_synced;
        end if;
    end process;
    depth_toggle <= depth_synced_dly xor depth_synced;
    depth_r_p: process(clk, rst_i, depth_toggle, depth)
    begin
        if rst_i = '1' then
            depth_r <= (others => '0');
		elsif rising_edge(clk) then
            if depth_toggle = '1' then
                depth_r <= depth - 1;
            end if;
        end if;
    end process;
    genweb: for i in 0 to 3 generate
        web_0(i) <= '1' when bus2fpga_be(i) = '1' and bus2fpga_rnw = '0' and bus2fpga_cs = "0100" else '0';
        web_1(i) <= '1' when bus2fpga_be(i) = '1' and bus2fpga_rnw = '0' and bus2fpga_cs = "1000" else '0';
    end generate;
    fpga2bus_data <= doutb_0 when bus2fpga_cs = "0100" else
                     doutb_1;
    fpga2bus_error <= '0';
    rd <= '1' when (bus2fpga_cs = "1000" or bus2fpga_cs = "0100") and bus2fpga_rnw = '1' else '0';
    wr <= '1' when (bus2fpga_cs = "1000" or bus2fpga_cs = "0100") and bus2fpga_rnw = '0' else '0';
    rdack: process(bus2fpga_clk, bus2fpga_reset, rd)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rddly <= '0';
            else
                rddly <= rd;
            end if;
        end if;
    end process;
    rd_rq <= rd and not(rddly);
    rdack_dly: process(bus2fpga_clk, bus2fpga_reset, rd_rq)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rdackdly <= '0';
				rdackdly1 <= '0';
            else
                rdackdly <= rd_rq;
				rdackdly1 <= rdackdly;
            end if;
        end if;
    end process;
    fpga2bus_rdack <= rdackdly1;
    fpga2bus_wrack <= wr;

end Structural;

