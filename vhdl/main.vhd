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
	trig_type		    : in  std_logic_vector(1 downto 0);
    trig_armed          : out std_logic;
    trig_trigd          : out std_logic;

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
	core_cmul_sch       : in  std_logic_vector(1 downto 0);
	core_L              : in  std_logic_vector(11 downto 0);
	core_iq             : in  std_logic;

	core_ov_fft         : out std_logic;
	core_ov_ifft        : out std_logic;
	core_ov_cmul        : out std_logic;

	core_busy           : out std_logic;
	core_done           : out std_logic;

-- signals for selectio oserdes transmitter
    txn                 : out std_logic_vector(7 downto 0);
    txp                 : out std_logic_vector(7 downto 0);
    txclkn              : out std_logic;
    txclkp              : out std_logic;

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
    tx_cmul_ovfl        : out std_logic;
	tx_busy				: out std_logic;

-- mem
	mem_req				: in  std_logic;
	mem_ack				: out std_logic;

	mem_clk				: in  std_logic;

	mem_dinia			: in  std_logic_vector(15 downto 0);
	mem_addria			: in  std_logic_vector(15 downto 0);
	mem_weaia			: in  std_logic;
	mem_doutia			: out std_logic_vector(15 downto 0);
	mem_dinib			: in  std_logic_vector(15 downto 0);
	mem_addrib			: in  std_logic_vector(15 downto 0);
	mem_weaib			: in  std_logic;
	mem_doutib			: out std_logic_vector(15 downto 0);

	mem_dinh			: in  std_logic_vector(31 downto 0);
	mem_addrh			: in  std_logic_vector(15 downto 0);
	mem_weh				: in  std_logic_vector(3 downto 0);
	mem_douth			: out std_logic_vector(31 downto 0);

	mem_dinoi			: in  std_logic_vector(31 downto 0);
	mem_addroi			: in  std_logic_vector(15 downto 0);
	mem_weoi			: in  std_logic_vector(3 downto 0);
	mem_doutoi			: out std_logic_vector(31 downto 0);

	mem_addroa			: in  std_logic_vector(31 downto 0);
	mem_doutoa			: out std_logic_vector(15 downto 0)
);
end main;

architecture Structural of main is

	signal mem_extern		   : std_logic;
	signal mem_clk_i		   : std_logic;

	signal core_mem_dinx	   : std_logic_vector(15 downto 0);
	signal core_mem_addrx	   : std_logic_vector(15 downto 0);
	signal mem_dinia_i		   : std_logic_vector(15 downto 0);
	signal mem_addria_i		   : std_logic_vector(15 downto 0);
	signal mem_weaia_i		   : std_logic;
	signal mem_doutia_i		   : std_logic_vector(15 downto 0);
	signal mem_dinib_i		   : std_logic_vector(15 downto 0);
	signal mem_addrib_i		   : std_logic_vector(15 downto 0);
	signal mem_weaib_i		   : std_logic;
	signal mem_doutib_i		   : std_logic_vector(15 downto 0);
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

    signal sample_clk          : std_logic;
    signal sample_rst          : std_logic;
	signal frame_clk		   : std_logic;
	signal wave_index		   : std_logic_vector(3 downto 0);
	signal trig_armed_i		   : std_logic;
	signal trig_trigd_i		   : std_logic;
	signal avg_active_i		   : std_logic;
	signal trig_arm_i		   : std_logic;

    signal clk_fb              : std_logic; -- feedback clk DCM
    signal core_clk            : std_logic; -- sample_clk*2
    signal core_clku           : std_logic;
	signal dcm_locked		   : std_logic;

	signal core_start_i		   : std_logic;
	signal core_rst_i		   : std_logic;
	signal core_busy_i		   : std_logic;

	signal tx_rst_i			   : std_logic;
	signal tx_toggle_buf_i	   : std_logic;
	signal tx_busy_i		   : std_logic;
begin

	-- mem access handling

	mem_extern_process: process(sample_clk, sample_rst, )
	begin
		if sample_clk'event and sample_clk = '1' then
			if sample_rst = '1' or mem_req = '0' then
				mem_extern <= '0';
			elsif mem_req = '1' and trig_armed_i = '0' and trig_trigd_i = '0' and avg_active_i = '0' and core_busy_i = '0' and tx_busy_i = '0' then
				mem_extern <= '1';
			end if;
		end if;
	end process mem_extern_process;

	mem_ack <= mem_extern;

    mem_clk_mux : BUFGMUX_CTRL
    port map (
        O                       => mem_clk_i,
        I0                      => core_clk,
        I1                      => mem_clk,
        S                       => mem_extern
    );

	mem_dinia_i   <= mem_dinia when mem_extern = '1' else
					 (others => '0');
	core_mem_dinx <= mem_doutia_i when mem_extern = '0' else
					 (others => '0');
	mem_doutia    <= mem_doutia_i when mem_extern = '1' else
				     (others => '0');
	mem_weaia_i   <= '0' when mem_extern = '0' else
				     mem_weaia;
	mem_addria_i  <= core_mem_addrx when mem_extern = '0' else
					 mem_addria;
	mem_dinib_i   <= mem_dinib when mem_extern = '1' else
					 (others => '0');
	mem_doutib    <= mem_doutib_i when mem_extern = '1' else
				     (others => '0');
	mem_weaib_i   <= '0' when mem_extern = '0' else
				     mem_weaib;
	mem_addrib_i  <= mem_addrib when mem_extern = '1' else
					 (others => '0');

	core_mem_diny <= mem_doutoi_i when mem_extern = '0' else
					 (others => '0');
	mem_dinoi_i   <= core_mem_douty when mem_extern = '0' else
					 mem_dinoi;
	mem_addroi_i  <= core_mem_addry when mem_extern = '0' else
					 mem_addroi;
	mem_weoi_i    <= (others => core_memwey) when mem_extern = '0' else
					 mem_weoi;
	mem_doutoi    <= mem_doutoi_i when mem_extern = '1' else
					 (others => '0');
	mem_addroa_i  <= mem_addroa when mem_extern = '1' else
					 (others => '0');
	mem_doutoa    <= mem_doutoa_i when mem_extern = '1' else
					 (others => '0');
    
	-- entities

	trig_arm_i <= trig_arm when mem_extern = '0' and core_busy_i = '0' else
				  '0';

	inbuf_inst: entity work.inbuf
	port map(
		refclk              => refclk,
		rxn                 => rxn,
		rxp                 => rxp,
		txn                 => txn,
		txp                 => txp,
		rec_rst             => rec_rst,
		rec_polarity        => rec_polarity,
		rec_descramble      => rec_descramble,
		rec_rxeqmix         => rec_rxeqmix,
		rec_data_valid      => rec_data_valid,
		rec_enable          => rec_enable,
		rec_input_select    => rec_input_select,
		rec_stream_valid    => rec_stream_valid,
		sample_clk          => sample_clk,
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
		frame_clk           => frame_clk,
		wave_index          => wave_index,
		mem_en              => mem_extern,
		mem_clk             => mem_clk_i,
		mem_dina            => mem_dinia_i,
		mem_addra           => mem_addria_i,
		mem_wea             => mem_weaia_i,
		mem_douta           => mem_doutia_i,
		mem_dinb            => mem_dinib_i,
		mem_addrb           => mem_addrib_i,
		mem_web             => mem_weaib_i,
		mem_doutb           => mem_doutib_i,
	);

	trig_armed <= trig_armed_i;
	trig_trigd <= trig_trigd_i;
	avg_active <= avg_active_i;

    core_clk_gen: DCM_BASE
    generic map (
        CLKIN_DIVIDE_BY_2     => FALSE,
        CLKIN_PERIOD          => 10.0,
        CLK_FEEDBACK          => "1X",
        DCM_PERFORMANCE_MODE  => "MAX_SPEED",
        DFS_FREQUENCY_MODE    => "LOW",
        DLL_FREQUENCY_MODE    => "LOW",
        DUTY_CYCLE_CORRECTION => TRUE,
        FACTORY_JF            => X"F0F0",
        PHASE_SHIFT           => 0,
        STARTUP_WAIT          => FALSE
	)
	port map (
        CLK0                  => clk_fb,
        CLK180                => open,
        CLK270                => open,
        CLK2X                 => core_clku,
        CLK2X180              => open,
        CLK90                 => open,
        CLKDV                 => open,
        CLKFX                 => open,
        CLKFX180              => open,
        LOCKED                => dcm_locked,
        CLKFB                 => clk_fb,
        CLKIN                 => sample_clk,
        RST                   => sample_rst
    );

    core_clk_buf: BUFG
    port map
    (
        I            => core_clku,
        O            => core_clk
    );

	core_rst_i   <= core_rst or not dcm_locked;
	core_start_i <= core_start when mem_extern = '0' and trig_armed_i = '0' and trig_trigd_i = '0' and avg_active_i = '0' and tx_busy_i = '0' else
					'0';

	core_inst: entity work.core
	port map(
		clk             => core_clk,
		rst             => core_rst_i,

		core_start      => core_start_i,
		core_n          => core_n,
		core_scale_sch  => core_scale_sch,
		core_scale_schi => core_scale_schi,
		core_cmul_sch   => core_cmul_sch,
		core_L          => core_L,
		core_depth      => depth,
		core_iq         => core_iq,

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
		clk             => sample_clk,
		rst             => tx_rst_i,
		frame_clk       => frame_clk,

		txn             => txn,
		txp             => txp,
		txclkn          => txclkn,
		txclkp          => txclkp,

		depth           => depth,
		tx_deskew       => tx_deskew,
		dc_balance      => tx_dc_balance,
		muli            => tx_muli,
		mulq            => tx_mulq,
		toggle_buf      => tx_toggle_buf_i,
		toggled         => tx_toggled,
		frame_offset    => tx_frame_offset,
		resync          => tx_resync,
		cmul_ovfl       => tx_cmul_ovfl,
		busy			=> tx_busy_i,

		mem_clk         => mem_clk_i,
		mem_dini        => mem_dinoi_i,
		mem_addri       => mem_addroi_i,
		mem_wei         => mem_weoi_i,
		mem_douti       => mem_doutoi_i,
		mem_addra       => mem_addroa_i,
		mem_douta       => mem_doutoa_i,
	);

	tx_busy <= tx_busy_i;

end Structural;

