-----------------------------------------------------------
-- Input buffer
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity inbuf is
port(
    sys_clk             : in  std_logic;

-- signals for gtx transciever
    refclk_n            : in  std_logic;
    refclk_p            : in  std_logic;
    rxn                 : in  std_logic_vector(5 downto 0);
    rxp                 : in  std_logic_vector(5 downto 0);
    txn                 : out std_logic_vector(5 downto 0);
    txp                 : out std_logic_vector(5 downto 0);

-- control signals receiver
    rec_rst             : in  std_logic;
    rec_polarity        : in  std_logic_vector(1 downto 0);
    rec_descramble      : in  std_logic_vector(1 downto 0);
    rec_rxeqmix         : in  t_cfg_array(1 downto 0);
    rec_data_valid      : out std_logic_vector(1 downto 0);
    rec_enable          : in  std_logic_vector(1 downto 0);
    rec_input_select    : in  std_logic_vector(0 downto 0);
    rec_input_select_changed : in  std_logic;
    rec_stream_valid    : out std_logic;

    sample_clk          : out std_logic;
    sample_rst          : out std_logic;

-- control signals trigger
    trig_rst            : in  std_logic;
    trig_arm            : in  std_logic;
    trig_ext            : in  std_logic;
    trig_int            : in  std_logic;
	trig_type		    : in  std_logic;
    trig_armed          : out std_logic;
    trig_trigd          : out std_logic;

-- control signals average
    avg_rst             : in  std_logic;
    avg_depth           : in  std_logic_vector(15 downto 0);
    avg_width           : in  std_logic_vector(1 downto 0);
    avg_done            : out std_logic;
    avg_active          : out std_logic;
    avg_err             : out std_logic;

-- wallclk
    frame_index         : out std_logic_vector(15 downto 0);
    frame_clk           : out std_logic;
    wave_index          : out std_logic_vector(3 downto 0);

-- mem
    mem_dina            : in  std_logic_vector(15 downto 0);
    mem_addra           : in  std_logic_vector(15 downto 0);
    mem_wea             : in  std_logic_vector(1 downto 0);
    mem_ena             : in  std_logic;
    mem_douta           : out std_logic_vector(15 downto 0);
    mem_dinb            : in  std_logic_vector(15 downto 0);
    mem_addrb           : in  std_logic_vector(15 downto 0);
    mem_web             : in  std_logic_vector(1 downto 0);
    mem_doutb           : out std_logic_vector(15 downto 0);
    mem_enb             : in  std_logic
);
end inbuf;

architecture Structural of inbuf is
    signal sample_rst_gen     : std_logic;
    signal sample_rst_i        : std_logic;
    signal sample_clk_i        : std_logic;
    signal rxclk_i             : std_logic_vector(1 downto 0);
    signal rec_rst_out         : std_logic_vector(1 downto 0);
    signal rec_data_i          : t_data_array(1 downto 0);
    signal rec_data_valid_i    : std_logic_vector(1 downto 0);
    signal data_i              : t_data;
    signal stream_valid_i      : std_logic;

    signal trig_rst_i          : std_logic;
    signal trig_rst_sync       : std_logic;
	signal frame_trg		   : std_logic;
	signal trig				   : std_logic;
    signal trig_int_synced     : std_logic;
    signal trig_armed_unsynced : std_logic;
    signal trig_type_synced    : std_logic;

    signal avg_rst_i           : std_logic;
    signal avg_rst_sync        : std_logic;
    signal avg_err_unsynced    : std_logic;

    signal wave_index_i        : std_logic_vector(3 downto 0);

    signal prepare_rst         : std_logic;
    signal avg_finished        : std_logic;
    signal sample_enable       : std_logic;
    signal arm_i               : std_logic;
    signal arm_i_synced        : std_logic;
    signal avg_clk             : std_logic;
    signal trig_ext_synced     : std_logic;
begin
    receiver_i: entity work.receiver
    port map(
        refclk_n            => refclk_n,
        refclk_p            => refclk_p,
        rst                 => rec_rst,
        rxn                 => rxn,
        rxp                 => rxp,
        txn                 => txn,
        txp                 => txp,
        rxclk               => rxclk_i,
        rst_out             => rec_rst_out,
        data                => rec_data_i,
        polarity            => rec_polarity,
        descramble          => rec_descramble,
        rxeqmix             => rec_rxeqmix,
        cdr_valid           => rec_data_valid_i,
        enable              => rec_enable
    );

    -- async clock mux since we don't know if rxclk_i(i) is actually active
    -- those might rest at '1' or '0' if the PLL is synching
    async_mux_inst0: BUFGCTRL
    port map
    (
        O => sample_clk_i,
        I0 => rxclk_i(0),
        I1 => rxclk_i(1),
        CE0 => '1',
        CE1 => '1',
        S0 => not rec_input_select(0),
        S1 => rec_input_select(0),
        IGNORE0 => '1',
        IGNORE1 => '1'
    );


    -- reset everything sample clk related on:
    --  * input select changed
    --  * selected receiver reset
    --  * selected receiver loss of sync
    sample_rst_gen <= or_many(rec_input_select_changed & rec_rst_out(conv_integer(rec_input_select)) & not rec_data_valid_i(conv_integer(rec_input_select)));

    sample_rst_generate: entity work.async_rst
    port map (
        clk => sample_clk_i,
        rst_in => sample_rst_gen,
        rst_out => sample_rst_i
    );

    sample_rst     <= sample_rst_i;
    sample_clk     <= sample_clk_i;
    rec_sync_gen: for i in 0 to 1 generate
    begin
        rec_data_valid_i: entity work.flag
        port map(
            flag_in      => rec_data_valid_i(i),
            flag_out     => rec_data_valid(i),
            clk          => sys_clk
        );
    end generate;

	mux_process: process(sample_clk_i)
	begin
		if rising_edge(sample_clk_i) then
            data_i <= rec_data_i(conv_integer(rec_input_select));
            stream_valid_i <= rec_data_valid_i(conv_integer(rec_input_select));
		end if;
	end process;

    sync_rec_stream_valid: entity work.flag
    port map(
        flag_in     => stream_valid_i,
        flag_out    => rec_stream_valid,
        clk         => sys_clk
    );

    --------------------
    -- sample_clk_i

    avg_rst_generate: entity work.async_rst
    port map (
        clk => sample_clk_i,
        rst_in => avg_rst,
        rst_out => avg_rst_sync
    );
    
    avg_rst_i <= avg_rst_sync or sample_rst_i; 

    wallclk_i : entity work.wallclk
    port map(
       clk                      => sample_clk_i,
       rst                      => avg_rst_i,
       n                        => avg_depth,
       wave_index               => wave_index_i,
       frame_clk                => frame_clk,
       frame_trg                => frame_trg,
       frame_index              => frame_index
    );

    wave_index_p: process(sample_clk_i)
    begin
        if rising_edge(sample_clk_i) then
            if avg_rst_i = '1' then
                wave_index <= (others => '0');
            elsif trig = '1' then
                wave_index <= wave_index_i;
            end if;
        end if;
    end process wave_index_p;

    trig_rst_generate: entity work.async_rst
    port map (
        clk => sample_clk_i,
        rst_in => trig_rst,
        rst_out => trig_rst_sync
    );
    trig_rst_i <= trig_rst_sync or sample_rst_i;

    arm_i_syncer: entity work.toggle
    port map(
        toggle_in => arm_i,
        toggle_out => arm_i_synced,
        clk_from => sample_clk_i,
        clk_to => sys_clk
    );

    sync_trig_type: entity work.flag
    port map(
        flag_in    => trig_type,
        flag_out   => trig_type_synced,
        clk        => sample_clk_i
    );

    sync_trig_int: entity work.toggle
    port map(
        toggle_in   => trig_int,
        toggle_out  => trig_int_synced,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );

    sync_inbuf_trigger: entity work.flag
    port map(
        flag_in     => trig_ext,
        flag_out    => trig_ext_synced,
        clk         => sample_clk_i
    );


    trigger_i : entity work.trigger
    port map(
        clk         => sample_clk_i,
        rst         => trig_rst_i,
        typ         => trig_type_synced,
        trigger_ext => trig_ext_synced,
        trigger_int => trig_int_synced,
        frame_trg   => frame_trg,
        arm         => arm_i_synced,
        armed       => trig_armed_unsynced,
        trig        => trig
    );

    sync_trig_armed: entity work.flag
    port map(
        flag_in     => trig_armed_unsynced,
        flag_out    => trig_armed,
        clk         => sys_clk
    );

    sync_trig_trigd: entity work.toggle
    port map(
        toggle_in   => trig,
        toggle_out  => trig_trigd,
        clk_from    => sample_clk_i,
        clk_to      => sys_clk
    );
    
    --

    prepare_rst <= avg_rst or trig_rst;

    prepare_i: entity work.prepare
    port map(
        sample_clk  => sample_clk_i,
        sys_clk     => sys_clk,
        rst         => prepare_rst,

        arm         => trig_arm,
        avg_finished=> avg_finished,

        sample_enable => sample_enable, 
        do_arm      => arm_i,
        avg_done    => avg_done,
        active      => avg_active,
        avg_clk     => avg_clk
    );
        

    average_mem_i: entity work.average_mem
    port map(
        clk                     => sample_clk_i,
        rst                     => avg_rst_i,
        width                   => avg_width,
        depth                   => avg_depth,
        trig                    => trig,
        done                    => avg_finished,
		err						=> avg_err_unsynced,
        data                    => data_i,
        data_valid              => stream_valid_i,
        memclk                  => avg_clk,
        sample_enable           => sample_enable,
        dina                    => mem_dina,
        addra                   => mem_addra,
        wea                     => mem_wea,
        ena                     => mem_ena,
        douta                   => mem_douta,
        dinb                    => mem_dinb,
        addrb                   => mem_addrb,
        web                     => mem_web,
        enb                     => mem_enb,
        doutb                   => mem_doutb
    );

    sync_avg_err: entity work.flag
    port map(
        flag_in     => avg_err_unsynced,
        flag_out    => avg_err,
        clk         => sys_clk
    );


end Structural;

