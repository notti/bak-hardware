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
    rx_refclk_n         : in  std_logic;
    rx_refclk_p         : in  std_logic;
    rx_rxn              : in  std_logic_vector(3 downto 0);
    rx_rxp              : in  std_logic_vector(3 downto 0);
    rx_txn              : out std_logic_vector(3 downto 0);
    rx_txp              : out std_logic_vector(3 downto 0);

-- overall settings
	depth				: in  std_logic_vector(15 downto 0);

-- control signals receiver
    rec_rst             : in  std_logic;
    rec_polarity        : in  std_logic_vector(2 downto 0);
    rec_descramble      : in  std_logic_vector(2 downto 0);
    rec_rxeqmix         : in  t_cfg_array(2 downto 0);
    rec_data_valid      : out std_logic_vector(2 downto 0);
    rec_enable          : in  std_logic_vector(2 downto 0);
    rec_input_select    : in  std_logic_vector(1 downto 0);
    rec_stream_valid    : out std_logic;

-- control signals trigger
    trig_rst            : in  std_logic;
    trig_arm            : in  std_logic;
    trig_ext            : in  std_logic;
    trig_int            : in  std_logic;
	trig_type		    : in  std_logic;
    trig_armed          : out std_logic;
    trig_trigd          : out std_logic;
	frame_clk			: out std_logic;

-- control signals average
    avg_rst             : in  std_logic;
    avg_width           : in  std_logic_vector(1 downto 0);
    avg_done            : out std_logic;
    avg_active          : out std_logic;
    avg_err             : out std_logic;

-- overlap_add
	core_rst			: in  std_logic;
	core_start          : in  std_logic;
	core_n              : in  std_logic_vector(4 downto 0);
	core_scale_sch      : in  std_logic_vector(11 downto 0);
	core_scale_schi     : in  std_logic_vector(11 downto 0);
	core_scale_cmul     : in  std_logic_vector(1 downto 0);
	core_L              : in  std_logic_vector(11 downto 0);
	core_iq             : in  std_logic;
    core_circular       : in std_logic;

	core_ov_fft         : out std_logic;
	core_ov_ifft        : out std_logic;
	core_ov_cmul        : out std_logic;

	core_busy           : out std_logic;
	core_done           : out std_logic;

-- signals for selectio oserdes transmitter
    tx_txn              : out std_logic_vector(7 downto 0);
    tx_txp              : out std_logic_vector(7 downto 0);
    tx_txclkn           : out std_logic;
    tx_txclkp           : out std_logic;

-- settings
	tx_rst				: in  std_logic;
    tx_deskew           : in  std_logic;
    tx_dc_balance       : in  std_logic;
    tx_muli             : in  std_logic_vector(15 downto 0);
    tx_mulq             : in  std_logic_vector(15 downto 0);
    tx_toggle_buf       : in  std_logic;
    tx_toggled          : out std_logic;
    tx_frame_offset     : in  std_logic_vector(15 downto 0);
    tx_resync           : in  std_logic;
	tx_busy				: out std_logic;
    tx_ovfl             : out std_logic;
    tx_ovfl_ack         : in  std_logic;
    tx_sat              : in  std_logic;
    tx_shift            : in  std_logic_vector(1 downto 0);

-- mem
	mem_req				: in  std_logic;
	mem_ack				: out std_logic;

	mem_clk				: in  std_logic;

	mem_dinia			: in  std_logic_vector(15 downto 0);
	mem_addria			: in  std_logic_vector(15 downto 0);
	mem_weaia			: in  std_logic_vector(1 downto 0);
	mem_doutia			: out std_logic_vector(15 downto 0);
	mem_dinib			: in  std_logic_vector(15 downto 0);
	mem_addrib			: in  std_logic_vector(15 downto 0);
	mem_weaib			: in  std_logic_vector(1 downto 0);
	mem_doutib			: out std_logic_vector(15 downto 0);

	mem_dinh			: in  std_logic_vector(31 downto 0);
	mem_addrh			: in  std_logic_vector(15 downto 0);
	mem_weh				: in  std_logic_vector(3 downto 0);
	mem_douth			: out std_logic_vector(31 downto 0);

	mem_dinoi			: in  std_logic_vector(31 downto 0);
	mem_addroi			: in  std_logic_vector(15 downto 0);
	mem_weoi			: in  std_logic_vector(3 downto 0);
	mem_doutoi			: out std_logic_vector(31 downto 0);

	mem_addroa			: in  std_logic_vector(15 downto 0);
	mem_doutoa			: out std_logic_vector(31 downto 0);

-- clk out
    sample_clk          : out std_logic;
    core_clk            : out std_logic
);
end main;

architecture Structural of main is

	signal mem_extern		   : std_logic;
	signal mem_clk_i		   : std_logic;

	signal core_mem_dinx	   : std_logic_vector(15 downto 0);
	signal core_mem_addrx	   : std_logic_vector(15 downto 0);
	signal mem_addria_i		   : std_logic_vector(15 downto 0);
	signal mem_weaia_i		   : std_logic_vector(1 downto 0);
	signal mem_doutia_i		   : std_logic_vector(15 downto 0);
	signal mem_weaib_i		   : std_logic_vector(1 downto 0);
	signal core_mem_diny	   : std_logic_vector(31 downto 0);
	signal core_mem_addry	   : std_logic_vector(15 downto 0);
	signal core_mem_douty	   : std_logic_vector(31 downto 0);
	signal core_mem_wey		   : std_logic;
	signal mem_dinoi_i		   : std_logic_vector(31 downto 0);
	signal mem_addroi_i		   : std_logic_vector(15 downto 0);
	signal mem_weoi_i		   : std_logic_vector(3 downto 0);
	signal mem_doutoi_i		   : std_logic_vector(31 downto 0);
	signal mem_addroa_i		   : std_logic_vector(15 downto 0);
	signal mem_doutoa_i		   : std_logic_vector(31 downto 0);

    signal sample_clk_i          : std_logic;
    signal sample_rst          : std_logic;
	signal frame_clk_i		   : std_logic;
	signal wave_index		   : std_logic_vector(3 downto 0);
	signal trig_armed_i		   : std_logic;
	signal trig_trigd_i		   : std_logic;
	signal avg_active_i		   : std_logic;
	signal trig_arm_i		   : std_logic;

--    signal clk_fb              : std_logic; -- feedback clk DCM
    signal core_clk_i          : std_logic; -- sample_clk_i*2
--    signal core_clku           : std_logic;
--	signal dcm_locked		   : std_logic;

	signal core_start_i		   : std_logic;
	signal core_rst_i		   : std_logic;
	signal core_busy_i		   : std_logic;

	signal tx_rst_i			   : std_logic;
	signal tx_toggle_buf_i	   : std_logic;
	signal tx_busy_i		   : std_logic;

    signal mem_extern_inbuf    : std_logic;
begin

	-- mem access handling

	mem_extern_process: process(sample_clk_i, sample_rst, mem_req, trig_armed_i, trig_trigd_i, avg_active_i, core_busy_i, tx_busy_i)
	begin
		if rising_edge(sample_clk_i) then
			if sample_rst = '1' then
				mem_extern <= '0';
            elsif trig_armed_i = '0' and trig_trigd_i = '0' and avg_active_i = '0' and core_busy_i = '0' and tx_busy_i = '0' then
                mem_extern <= mem_req;
			end if;
		end if;
	end process mem_extern_process;

	mem_ack <= mem_extern;

    mem_clk_mux : BUFGMUX_CTRL
    port map (
        O                       => mem_clk_i,
        I0                      => core_clk_i,
        I1                      => mem_clk,
        S                       => mem_extern
    );

	core_mem_dinx <= mem_doutia_i;
	mem_doutia    <= mem_doutia_i;
	mem_weaia_i   <= mem_weaia when mem_extern = '1' else
				     (others => '0');
	mem_addria_i  <= mem_addria when mem_extern = '1' else
					 core_mem_addrx;
	mem_weaib_i   <= mem_weaib when mem_extern = '1' else
				     (others => '0');

	core_mem_diny <= mem_doutoi_i;
	mem_dinoi_i   <= mem_dinoi when mem_extern = '1' else
					 core_mem_douty ;
	mem_addroi_i  <= mem_addroi when mem_extern = '1' else
					 core_mem_addry ;
	mem_weoi_i    <= mem_weoi when mem_extern = '1' else
					 (others => core_mem_wey);
	mem_doutoi    <= mem_doutoi_i;
	mem_addroa_i  <= mem_addroa;
	mem_doutoa    <= mem_doutoa_i;
    mem_extern_inbuf <= mem_extern or core_busy_i;
    
	-- entities

	trig_arm_i <= trig_arm when mem_extern = '0' and core_busy_i = '0' else
				  '0';

	inbuf_inst: entity work.inbuf
	port map(
		refclk_n            => rx_refclk_n,
		refclk_p            => rx_refclk_p,
		rxn                 => rx_rxn,
		rxp                 => rx_rxp,
		txn                 => rx_txn,
		txp                 => rx_txp,
		rec_rst             => rec_rst,
		rec_polarity        => rec_polarity,
		rec_descramble      => rec_descramble,
		rec_rxeqmix         => rec_rxeqmix,
		rec_data_valid      => rec_data_valid,
		rec_enable          => rec_enable,
		rec_input_select    => rec_input_select,
		rec_stream_valid    => rec_stream_valid,
		sample_clk          => sample_clk_i,
		sample_rst          => sample_rst,
		trig_rst            => trig_rst,
		trig_arm            => trig_arm_i,
		trig_ext            => trig_ext,
		trig_int            => trig_int,
		trig_type		    => trig_type,
		trig_armed          => trig_armed_i,
		trig_trigd          => trig_trigd_i,
		avg_rst             => avg_rst,
		avg_depth           => depth,
		avg_width           => avg_width,
		avg_done            => avg_done,
		avg_active          => avg_active_i,
		avg_err             => avg_err,
		frame_index         => open, -- don't we need this?
		frame_clk           => frame_clk_i,
		wave_index          => wave_index,
		mem_en              => mem_extern_inbuf,
		mem_clk             => mem_clk_i,
		mem_dina            => mem_dinia,
		mem_addra           => mem_addria_i,
		mem_wea             => mem_weaia_i,
		mem_douta           => mem_doutia_i,
		mem_dinb            => mem_dinib,
		mem_addrb           => mem_addrib,
		mem_web             => mem_weaib_i,
		mem_doutb           => mem_doutib
	);


	trig_armed <= trig_armed_i;
	trig_trigd <= trig_trigd_i;
	avg_active <= avg_active_i;
	frame_clk  <= frame_clk_i;
    sample_clk <= sample_clk_i;

--    core_clk_gen: DCM_BASE
--    generic map (
--        CLKIN_DIVIDE_BY_2     => FALSE,
--        CLKIN_PERIOD          => 10.0,
--        CLK_FEEDBACK          => "1X",
--        DCM_PERFORMANCE_MODE  => "MAX_SPEED",
--        DFS_FREQUENCY_MODE    => "LOW",
--        DLL_FREQUENCY_MODE    => "LOW",
--        DUTY_CYCLE_CORRECTION => TRUE,
--        FACTORY_JF            => X"F0F0",
--        PHASE_SHIFT           => 0,
--        STARTUP_WAIT          => FALSE
--	)
--	port map (
--        CLK0                  => clk_fb,
--        CLK180                => open,
--        CLK270                => open,
--        CLK2X                 => core_clku,
--        CLK2X180              => open,
--        CLK90                 => open,
--        CLKDV                 => open,
--        CLKFX                 => open,
--        CLKFX180              => open,
--        LOCKED                => dcm_locked,
--        CLKFB                 => clk_fb,
--        CLKIN                 => sample_clk_i,
--        RST                   => sample_rst
--    );
--
--    core_clk_buf: BUFG
--    port map
--    (
--        I            => core_clku,
--        O            => core_clk_i
--    );
--
--    core_clk <= core_clk_i;
    core_clk_i <= sample_clk_i;

    core_clk <= core_clk_i;
    core_rst_i <= core_rst or sample_rst;

--	core_rst_i   <= core_rst or not dcm_locked;
	core_start_i <= core_start when mem_extern = '0' and trig_armed_i = '0' and trig_trigd_i = '0' and avg_active_i = '0' and tx_busy_i = '0' else
					'0';

	core_inst: entity work.core
	port map(
		clk             => core_clk_i,
		rst             => core_rst_i,

		core_start      => core_start_i,
		core_n          => core_n,
		core_scale_sch  => core_scale_sch,
		core_scale_schi => core_scale_schi,
		core_scale_cmul => core_scale_cmul,
		core_L          => core_L,
		core_depth      => depth,
		core_iq         => core_iq,
        core_circular   => core_circular,

		core_ov_fft     => core_ov_fft,
		core_ov_ifft    => core_ov_ifft,
		core_ov_cmul    => core_ov_cmul,

		core_busy       => core_busy_i,
		core_done       => core_done,

		wave_index      => wave_index,

		mem_dinx        => core_mem_dinx,
		mem_addrx       => core_mem_addrx,

		mem_diny        => core_mem_diny,
		mem_addry       => core_mem_addry,
		mem_douty       => core_mem_douty,
		mem_wey         => core_mem_wey,

		mem_clkh        => mem_clk, -- always external no need for mux
		mem_dinh        => mem_dinh,
		mem_addrh       => mem_addrh,
		mem_weh         => mem_weh,
		mem_douth       => mem_douth
	);

	core_busy <= core_busy_i;

	tx_rst_i <= sample_rst or tx_rst;
	tx_toggle_buf_i <= tx_toggle_buf when mem_extern = '0' and core_busy_i = '0' else
					   '0';

	outbuf_inst: entity work.outbuf
	port map(
		clk             => sample_clk_i,
		rst             => tx_rst_i,
		frame_clk       => frame_clk_i,

		txn             => tx_txn,
		txp             => tx_txp,
		txclkn          => tx_txclkn,
		txclkp          => tx_txclkp,

		depth           => depth,
		tx_deskew       => tx_deskew,
		dc_balance      => tx_dc_balance,
		muli            => tx_muli,
		mulq            => tx_mulq,
		toggle_buf      => tx_toggle_buf_i,
		toggled         => tx_toggled,
		frame_offset    => tx_frame_offset,
		resync          => tx_resync,
		busy			=> tx_busy_i,
        ovfl            => tx_ovfl,
        ovfl_ack        => tx_ovfl_ack,
        sat             => tx_sat,
        shift           => tx_shift,

		mem_clk         => mem_clk_i,
		mem_dini        => mem_dinoi_i,
		mem_addri       => mem_addroi_i,
		mem_wei         => mem_weoi_i,
		mem_douti       => mem_doutoi_i,
		mem_addra       => mem_addroa_i,
		mem_douta       => mem_doutoa_i
	);

	tx_busy <= tx_busy_i;

end Structural;

