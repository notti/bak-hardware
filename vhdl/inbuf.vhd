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
    mem_en              : in  std_logic;
    mem_clk             : in  std_logic;
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
    signal sample_rst_gen0     : std_logic;
    signal sample_rst_gen1     : std_logic;
    signal sample_rst_gen2     : std_logic;
    signal sample_rst_gen3     : std_logic;
    signal sample_rst_i        : std_logic;
    signal sample_clk_i        : std_logic;
    signal rxclk_i             : std_logic_vector(1 downto 0);
    signal rec_rst_out         : std_logic_vector(1 downto 0);
    signal rec_data_i          : t_data_array(1 downto 0);
    signal rec_data_valid_i    : std_logic_vector(1 downto 0);
    signal data_i              : t_data;
    signal stream_valid_i      : std_logic;

    signal trig_rst_i          : std_logic;
	signal frame_trg		   : std_logic;
	signal trig				   : std_logic;
    signal trig_armed_i        : std_logic;

    signal avg_rst_i           : std_logic;
    signal avg_active_i        : std_logic;

    signal wave_index_i        : std_logic_vector(3 downto 0);

    signal mem_en_i            : std_logic;
    signal mem_clk_i           : std_logic;
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
        data_valid          => rec_data_valid_i,
        enable              => rec_enable
    );

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


    rst_generate: process(sample_clk_i, rec_input_select_changed, rec_rst_out, rec_input_select)
    begin
        if rec_input_select_changed = '1' or rec_rst_out(conv_integer(rec_input_select)) = '1' then
            sample_rst_gen0 <= '1';
            sample_rst_gen1 <= '1';
            sample_rst_gen2 <= '1';
            sample_rst_gen3 <= '1';
        elsif rising_edge(sample_clk_i) then
            sample_rst_gen0 <= '0';
            sample_rst_gen1 <= sample_rst_gen0;
            sample_rst_gen2 <= sample_rst_gen1;
            sample_rst_gen3 <= sample_rst_gen2;
        end if;
    end process rst_generate;

    sample_rst_i <= sample_rst_gen3;

    sample_rst     <= sample_rst_i;
    sample_clk     <= sample_clk_i;
    rec_data_valid <= rec_data_valid_i;

	mux_process: process(sample_clk_i)
	begin
		if rising_edge(sample_clk_i) then
            data_i <= rec_data_i(conv_integer(rec_input_select));
            stream_valid_i <= rec_data_valid_i(conv_integer(rec_input_select));
		end if;
	end process;

    rec_stream_valid <= stream_valid_i;

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

    wave_index_p: process(sample_clk_i, avg_rst_i, trig, wave_index_i)
    begin
        if rising_edge(sample_clk_i) then
            if avg_rst_i = '1' then
                wave_index <= (others => '0');
            else
                if trig = '1' then
                    wave_index <= wave_index_i;
                end if;
            end if;
        end if;
    end process wave_index_p;

    trig_rst_i <= trig_rst or sample_rst_i;

    trigger_i : entity work.trigger
    port map(
        clk         => sample_clk_i,
        rst         => trig_rst_i,
        typ         => trig_type,
        trigger_ext => trig_ext,
        trigger_int => trig_int,
        frame_trg   => frame_trg,
        arm         => trig_arm,
        armed       => trig_armed_i,
        trig        => trig
    );

    trig_trigd <= trig;
    trig_armed <= trig_armed_i;
    
    avg_rst_i <= avg_rst or sample_rst_i; 

    mem_en_i <= '0' when trig_armed_i = '1' or avg_active_i = '1' else
                mem_en;

    mem_clk_mux : BUFGCTRL
    port map (
        O                       => mem_clk_i,
        I0                      => sample_clk_i,
        I1                      => mem_clk,
        CE0                     => '1',
        CE1                     => '1',
        S0                      => not mem_en_i,
        S1                      => mem_en_i,
        IGNORE0                 => '1',
        IGNORE1                 => '1'

    );

    average_mem_i: entity work.average_mem
    port map(
        clk                     => sample_clk_i,
        rst                     => avg_rst_i,
        width                   => avg_width,
        depth                   => avg_depth,
        trig                    => trig,
        done                    => avg_done,
        active                  => avg_active_i,
		err						=> avg_err,
        data                    => data_i,
        data_valid              => stream_valid_i,
        memclk                  => mem_clk_i,
        ext                     => mem_en_i,
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

    avg_active <= avg_active_i;

end Structural;

