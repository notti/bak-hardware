-- scratch2ifft falsch um 1 cycle ??!?!?
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity overlap_add is
generic(
    SCRATCH_READ_CYCLES : natural := 2;
    Y_READ_CYCLES       : natural := 2;
    X_READ_CYCLES       : natural := 2;
    H_READ_CYCLES       : natural := 1; 
    CMUL_CYCLES         : natural := 4;
    CADD_CYCLES         : natural := 1;
    FFT_CYCLES          : natural := 3
);
port(
    clk          : in std_logic;
    rst          : in std_logic;

    start        : in std_logic;
    nfft         : in std_logic_vector(4 downto 0);
    scale_sch    : in std_logic_vector(11 downto 0);
    scale_schi   : in std_logic_vector(11 downto 0);
    cmul_sch     : in std_logic_vector(1 downto 0);
    L            : in std_logic_vector(11 downto 0);
    n            : in std_logic_vector(15 downto 0);
    iq           : in std_logic;

    wave_index   : in std_logic_vector(3 downto 0);
    x_in         : in std_logic_vector(15 downto 0);
    x_index      : out std_logic_vector(15 downto 0);

    y_re_in      : in std_logic_vector(15 downto 0);
    y_im_in      : in std_logic_vector(15 downto 0);
    y_re_out     : out std_logic_vector(15 downto 0);
    y_im_out     : out std_logic_vector(15 downto 0);
    y_index      : out std_logic_vector(15 downto 0);
    y_we         : out std_logic;

    h_re_in      : in std_logic_vector(15 downto 0);
    h_im_in      : in std_logic_vector(15 downto 0);
    h_index      : out std_logic_vector(11 downto 0);

    ovfl_fft     : out std_logic;
    ovfl_ifft    : out std_logic;
    ovfl_cmul    : out std_logic;

    busy         : out std_logic;
    done         : out std_logic
);
end overlap_add;

architecture Structural of overlap_add is
    component fft
  port (
    sclr : in STD_LOGIC := 'X'; 
    fwd_inv_we : in STD_LOGIC := 'X'; 
    rfd : out STD_LOGIC; 
    start : in STD_LOGIC := 'X'; 
    fwd_inv : in STD_LOGIC := 'X'; 
    dv : out STD_LOGIC; 
    nfft_we : in STD_LOGIC := 'X'; 
    scale_sch_we : in STD_LOGIC := 'X'; 
    done : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    busy : out STD_LOGIC; 
    edone : out STD_LOGIC; 
    ovflo : out STD_LOGIC; 
    scale_sch : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
    xn_re : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xk_im : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xn_index : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    nfft : in STD_LOGIC_VECTOR ( 4 downto 0 ); 
    xk_re : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xn_im : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xk_index : out STD_LOGIC_VECTOR ( 11 downto 0 ) 
  );
end component;
component scratch
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(11 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(31 downto 0));
end component;

    attribute box_type: boolean;
--    attribute box_type of fft: component is "black_box";
--    attribute box_type of scratch: component is "black_box";
--    attribute resource_sharing: string;
--    attribute resource_sharing of overlap_add: entity is "no";
--    attribute PERIOD: string;
--    attribute PERIOD of clk: signal is "200 Mhz";

    constant SCRATCH2FFT : natural := FFT_CYCLES - SCRATCH_READ_CYCLES;
    constant Y2SCRATCH : natural := Y_READ_CYCLES;
    constant H2CMUL : natural := H_READ_CYCLES;
    constant SCRATCH2CADD : natural := SCRATCH_READ_CYCLES;
    constant CMUL2SCRATCH : natural := H_READ_CYCLES + CMUL_CYCLES;
    constant CADD2Y : natural := SCRATCH_READ_CYCLES + CADD_CYCLES;

    type fsm_type is (INACTIVE, PREPARE, START_FFT_IFFT, WAIT_COMPLETE, COMPLETE);
    subtype address_t is std_logic_vector(11 downto 0);
    subtype data_t is std_logic_vector(15 downto 0);
    type address_dt is array(natural range <>) of address_t;
    type data_dt is array(natural range <>) of data_t;
    type ctrl_dt is array(natural range <>) of std_logic_vector(1 downto 0);
    type flag_dt is array(natural range <>) of std_logic;
    signal state : fsm_type;
    signal zero_pad : std_logic;
    signal zero_start : std_logic;
    signal mn_i : data_t;
    signal cmul_sch_i : std_logic_vector(1 downto 0);

	signal fwd_inv_we_i : std_logic;
	signal rfd_i        : std_logic;
	signal start_i      : std_logic;
	signal fwd_inv_i    : std_logic;
	signal dv_i         : std_logic;
	signal done_i       : std_logic;
	signal busy_i       : std_logic;
	signal edone_i      : std_logic;
	signal ovflo_fft    : std_logic;
	signal xn_re_i      : data_t;
	signal xk_im_i      : data_t;
	signal xn_index_i   : address_t;
	signal xk_re_i      : data_t;
	signal xn_im_i      : data_t;
	signal xk_index_i   : address_t;

    signal prepare_we   : std_logic;

    signal ifft_run    : std_logic;
    signal ifft_wdone  : std_logic;
    signal ifft_edone  : std_logic;
    signal ifft_rdone  : std_logic;
    signal ifft_start  : std_logic;
    signal ifft_write  : std_logic;
    signal ifft_busy   : std_logic;
    signal ifft_read   : std_logic;
    signal ifft_done   : flag_dt(CADD2Y downto 0);
    signal fft_run     : std_logic;
    signal fft_wdone   : std_logic;
    signal fft_edone   : std_logic;
    signal fft_rdone   : std_logic;
    signal fft_start   : std_logic;
    signal fft_write   : flag_dt(X_READ_CYCLES downto 0);
    signal fft_busy    : std_logic;
    signal fft_read    : std_logic;
    signal fft_done    : flag_dt(CMUL2SCRATCH downto 0);

    signal max_index_i : address_t;
    signal max_index   : address_t;

    signal L_i         : address_t;
    signal Lmax_i      : address_t;
    signal n_i         : data_t;
    signal offset_x    : data_t;
    signal offset_y    : data_t;
    signal last_cycle_x: std_logic;
    signal last_cycle_yr: flag_dt(Y2SCRATCH downto 0);
    signal first_cycle_yr: std_logic;
    signal last_cycle_yw: std_logic;

    signal x_index_i   : data_t;
    signal y_index_i   : data_t;
    signal fft_in_ctrl : ctrl_dt(FFT_CYCLES downto 0);
	
    signal scratch_din : std_logic_vector(31 downto 0);
	signal scratch_addr: address_t;
	signal scratch_we_i: std_logic_vector(0 downto 0);
	signal scratch_dout: std_logic_vector(31 downto 0);

    signal scratch_re_in : data_t;
    signal scratch_im_in : data_t;
    signal scratch_re_out : data_dt(SCRATCH2FFT downto 0);
    signal scratch_im_out : data_dt(SCRATCH2FFT downto 0);
    signal scratch_we  : std_logic;

    signal cmul_a_re    : data_dt(H2CMUL downto 0);
    signal cmul_a_im    : data_dt(H2CMUL downto 0);
    signal cadd_a_re    : data_dt(SCRATCH2CADD downto 0);
    signal cadd_a_im    : data_dt(SCRATCH2CADD downto 0);
    signal cmul_index   : address_dt(CMUL2SCRATCH downto 0);
    signal cmul_read    : flag_dt(CMUL2SCRATCH downto 0);
    signal cadd_index   : data_dt(CADD2Y downto 0);

    signal c_re         : data_t;
    signal c_im         : data_t;
    
    signal y_we_i       : flag_dt(CADD2Y downto 0);

    signal cmul_ovfl     : std_logic;
    signal cadd_ovfl     : std_logic;

    signal y2scratch_i   : std_logic;
    signal scratch_fill_cnt : address_dt(Y2SCRATCH downto 0);
    signal scratch_fill  : flag_dt(Y2SCRATCH downto 0);
    signal lgni : std_logic;
    signal m_i : address_t;
    signal zero_fill : std_logic;

    signal x_re_in      : std_logic_vector(15 downto 0);
    signal x_im_in      : std_logic_vector(15 downto 0);

    signal iq_i         : std_logic;
    signal last_y_cnt   : data_t;
    signal next_index_neg : std_logic;
    signal scale_sch_i : std_logic_vector(11 downto 0);
    signal scale_schi_i : std_logic_vector(11 downto 0);
    signal scale_sch_fft : std_logic_vector(11 downto 0);
    signal fft_read_i : flag_dt(CMUL2SCRATCH downto 0);
    signal ifft_read_i : flag_dt(CADD2Y downto 0);
begin
    assert (FFT_CYCLES - X_READ_CYCLES = 1) report "X read cycles + 1 cycle iq/demux != FFT_CYCLES!" severity error;

    fsm_p1: process(clk, rst)
    begin
        if rst = '1' then
            state <= INACTIVE;
        elsif clk = '1' and clk'event then
            case state is
                when INACTIVE  =>
                    if start = '1' then
                        state <= PREPARE;
                    else
                        state <= INACTIVE;
                    end if;
                when PREPARE => state <= START_FFT_IFFT;
                when START_FFT_IFFT => state <= WAIT_COMPLETE;
                when WAIT_COMPLETE =>
                    if ifft_done(CADD2Y) = '1' and last_cycle_x = '1' then
                        state <= COMPLETE;
                    else
                        state <= WAIT_COMPLETE;
                    end if;
                when COMPLETE => state <= INACTIVE;
            end case;
        end if;
    end process fsm_p1;

    fsm_p2: process(state)
    begin
        case state is
            when INACTIVE       => prepare_we <= '0'; busy <= '0'; done <= '0';
            when PREPARE        => prepare_we <= '1'; busy <= '1'; done <= '0';
            when START_FFT_IFFT => prepare_we <= '0'; busy <= '1'; done <= '0';
            when WAIT_COMPLETE  => prepare_we <= '0'; busy <= '1'; done <= '0';
            when COMPLETE       => prepare_we <= '0'; busy <= '0'; done <= '1';
        end case;
    end process fsm_p2;

    max_index <= "000000000111" when nfft = "00011" else 
                 "000000001111" when nfft = "00100" else 
                 "000000011111" when nfft = "00101" else 
                 "000000111111" when nfft = "00110" else 
                 "000001111111" when nfft = "00111" else 
                 "000011111111" when nfft = "01000" else 
                 "000111111111" when nfft = "01001" else 
                 "001111111111" when nfft = "01010" else 
                 "011111111111" when nfft = "01011" else 
                 "111111111111" when nfft = "01100" else 
                 "000000000000";

    prepare_p: process(clk, state)
    begin
        if clk = '1' and clk'event then
            if state = PREPARE then
                L_i <= L;
                Lmax_i <= L - 1;
                n_i <= n - 1;
                mn_i <= n + max_index - L -1;
                max_index_i <= max_index;
                m_i <= max_index - L;
                iq_i <= iq;
                cmul_sch_i <= cmul_sch;
                scale_sch_i <= scale_sch;
                scale_schi_i <= scale_schi;
            end if;
        end if;
    end process prepare_p;

    state_p: process(clk, state)
    begin
        if clk = '1' and clk'event then
            if state = PREPARE then
                offset_x <= (others => '0');
                last_cycle_x <= '0';
                last_cycle_yw <= '0';
                ovfl_fft <= '0';
                ovfl_ifft <= '0';
                ovfl_cmul <= '0';
                first_cycle_yr <= '1';
                offset_y <= (others => '0');
            else
                if ifft_done(CADD2Y) = '1' then
                    offset_y <= offset_y + L_i;
                end if;
                if fft_done(0) = '1' then
                    offset_x <= offset_x + L_i;
                end if;
                if ifft_done(0) = '1' then
                    first_cycle_yr <= '0';
                end if;
                if x_index_i = n_i and fft_in_ctrl(2)(0) = '1' then
                    last_cycle_x <= '1';
                end if;
                if ifft_read = '1' and y_index_i = n_i then
                    last_cycle_yw <= '1';
                end if;
                if ovflo_fft = '1' and (fft_read = '1' or fft_read_i = "00001" or fft_read_i = "00011" or fft_read_i = "00111" or fft_read_i = "01111" or fft_read_i = "11111") then
                    ovfl_fft <= '1';
                end if;
                if ovflo_fft = '1' and (ifft_read = '1' or ifft_read_i = "0001" or ifft_read_i = "0011" or ifft_read_i = "0111" or ifft_read_i = "1111") then
                    ovfl_ifft <= '1';
                end if;
                if cmul_ovfl = '1' then
                    ovfl_cmul <= '1';
                end if;
            end if;
        end if;
    end process state_p;

    process(clk)
    begin
        if clk = '1' and clk'event then
            if state = PREPARE  or ifft_write = '1' then
                last_cycle_yr(0) <= '0';
                last_y_cnt <= (others => '0');
                zero_start <= '0';
            else
                if ifft_busy = '1' and y_index_i = n_i then
                    last_cycle_yr(0) <= '1';
                end if;
                if last_cycle_yr(0) = '1' then
                    last_y_cnt <= last_y_cnt + 1;
                end if;
                if last_y_cnt = m_i then
                    zero_start <= '1';
                end if;
            end if;
        end if;
    end process;

    lgni_p: process(clk)
    begin
        if clk = '1' and clk'event then
            if scratch_fill(Y2SCRATCH) = '0' then
                lgni <= '0';
            else
                if scratch_fill_cnt(Y2SCRATCH) = m_i then
                    lgni <= '1';
                end if;
            end if;
        end if;
    end process lgni_p;

    delays: process(clk)
    begin
        if clk = '1' and clk'event then
            --scratch2fft_g: for i in SCRATCH2FFT downto 1 loop
            --    scratch_re_out(i) <= scratch_re_out(i-1);
            --    scratch_im_out(i) <= scratch_im_out(i-1);
            --end loop scratch2fft_g;
            scratch_re_out(1) <= scratch_re_out(0);
            scratch_im_out(1) <= scratch_im_out(0);
            --fft_cyc_g: for i in FFT_CYCLES downto 1 loop
            --    fft_in_ctrl(i) <= fft_in_ctrl(i-1);
            --end loop fft_cyc_g;
            fft_in_ctrl(3) <= fft_in_ctrl(2);
            fft_in_ctrl(2) <= fft_in_ctrl(1);
            fft_in_ctrl(1) <= fft_in_ctrl(0);
            --y2scratch_g: for i in Y2SCRATCH downto 1 loop
            --    scratch_fill_cnt(i) <= scratch_fill_cnt(i-1);
            --    scratch_fill(i) <= scratch_fill(i-1);
            --    last_cycle_yr(i) <= last_cycle_yr(i-1);
            --end loop y2scratch_g;
            scratch_fill_cnt(2) <= scratch_fill_cnt(1);
            scratch_fill(2) <= scratch_fill(1);
            last_cycle_yr(2) <= last_cycle_yr(1);
            scratch_fill_cnt(1) <= scratch_fill_cnt(0);
            scratch_fill(1) <= scratch_fill(0);
            last_cycle_yr(1) <= last_cycle_yr(0);
            --h2cmul_g: for i in H2CMUL downto 1 loop
            --    cmul_a_re(i) <= cmul_a_re(i-1);
            --    cmul_a_im(i) <= cmul_a_im(i-1);
            --end loop h2cmul_g;
            cmul_a_re(1) <= cmul_a_re(0);
            cmul_a_im(1) <= cmul_a_im(0);
            --scratch2cadd_g: for i in SCRATCH2CADD downto 1 loop
            --    cadd_a_re(i) <= cadd_a_re(i-1);
            --    cadd_a_im(i) <= cadd_a_im(i-1);
            --end loop scratch2cadd_g;
            cadd_a_re(2) <= cadd_a_re(1);
            cadd_a_im(2) <= cadd_a_im(1);
            cadd_a_re(1) <= cadd_a_re(0);
            cadd_a_im(1) <= cadd_a_im(0);
            --cmul2scratch_g: for i in CMUL2SCRATCH downto 1 loop
            --    cmul_index(i) <= cmul_index(i-1);
            --    cmul_read(i) <= cmul_read(i-1);
            --    fft_done(i) <= fft_done(i-1);
            --    fft_read_i(i) <= fft_read_i(i-1);
            --end loop cmul2scratch_g;
            cmul_index(5) <= cmul_index(4);
            cmul_read(5) <= cmul_read(4);
            fft_done(5) <= fft_done(4);
            fft_read_i(5) <= fft_read_i(4);
            cmul_index(4) <= cmul_index(3);
            cmul_read(4) <= cmul_read(3);
            fft_done(4) <= fft_done(3);
            fft_read_i(4) <= fft_read_i(3);
            cmul_index(3) <= cmul_index(2);
            cmul_read(3) <= cmul_read(2);
            fft_done(3) <= fft_done(2);
            fft_read_i(3) <= fft_read_i(2);
            cmul_index(2) <= cmul_index(1);
            cmul_read(2) <= cmul_read(1);
            fft_done(2) <= fft_done(1);
            fft_read_i(2) <= fft_read_i(1);
            cmul_index(1) <= cmul_index(0);
            cmul_read(1) <= cmul_read(0);
            fft_done(1) <= fft_done(0);
            fft_read_i(1) <= fft_read_i(0);
            --cadd2y_g: for i in CADD2Y downto 1 loop
            --    cadd_index(i) <= cadd_index(i-1);
            --    y_we_i(i) <= y_we_i(i-1);
            --    ifft_done(i) <= ifft_done(i-1);
            --    ifft_read_i(i) <= ifft_read_i(i-1);
            --end loop cadd2y_g;
            y_we_i(3) <= y_we_i(2);
            ifft_done(3) <= ifft_done(2);
            ifft_read_i(3) <= ifft_read_i(2);
            if cadd_index(1) >= mn_i then
                y_we_i(2) <= '0';
            else
                y_we_i(2) <= y_we_i(1);
            end if;
            ifft_done(2) <= ifft_done(1);
            ifft_read_i(2) <= ifft_read_i(1);
            y_we_i(1) <= y_we_i(0);
            ifft_done(1) <= ifft_done(0);
            ifft_read_i(1) <= ifft_read_i(0);
            if next_index_neg = '0' then
                cadd_index(3) <= cadd_index(2);
            else
                cadd_index(3) <= cadd_index(2) - n_i - 1;
            end if;
            cadd_index(2) <= cadd_index(1);
            if cadd_index(1) > n_i then
                next_index_neg <= '1';
            else
                next_index_neg <= '0';
            end if;
            cadd_index(1) <= cadd_index(0);
            --fft_wr_g: for i in 1 to X_READ_CYCLES loop
            --    fft_write(i) <= fft_write(i-1);
            --end loop fft_wr_g;
            fft_write(2) <= fft_write(1);
            fft_write(1) <= fft_write(0);
        end if;
    end process delays;

    zero_pad_p: process(clk)
    begin
        if clk = '1' and clk'event then
            if xn_index_i = X"000" then
                zero_pad <= '0';
            elsif xn_index_i = Lmax_i then
                zero_pad <= '1';
            end if;
        end if;
    end process zero_pad_p;


    fft_in_ctrl(0)(0) <= fft_write(0) and (not last_cycle_x) and (not zero_pad); -- pad zeroes when n > nmax
    fft_in_ctrl(0)(1) <= ifft_write;
    cmul_read(0) <= fft_read;

    xn_re_i <= x_re_in when fft_in_ctrl(FFT_CYCLES) = "01" else
               scratch_re_out(SCRATCH2FFT) when fft_in_ctrl(FFT_CYCLES) = "10" else
               (others => '0');
    xn_im_i <= x_im_in when fft_in_ctrl(FFT_CYCLES) = "01" else
               scratch_im_out(SCRATCH2FFT) when fft_in_ctrl(FFT_CYCLES) = "10" else
               (others => '0');

    start_i      <= fft_start or ifft_start; -- +1 cycle?
    fwd_inv_we_i <= fft_start or ifft_start;
    fwd_inv_i    <= fft_start;

    scratch_addr <= xn_index_i when ifft_write = '1' else
                    scratch_fill_cnt(Y2SCRATCH) when scratch_fill(Y2SCRATCH) = '1' else
                    xk_index_i when ifft_read = '1' else
                    cmul_index(CMUL2SCRATCH) when cmul_read(CMUL2SCRATCH) = '1' else
                    (others => '0');

    scratch_we <= '1' when cmul_read(CMUL2SCRATCH) = '1' else
                  '1' when scratch_fill(Y2SCRATCH) = '1' else
                  '0';
    zero_fill <= (first_cycle_yr or lgni) and not last_cycle_yr(Y2SCRATCH); -- TODO ok?
    scratch_re_in <= c_re when cmul_read(CMUL2SCRATCH) = '1' else
                     y_re_in when scratch_fill(Y2SCRATCH) = '1' and zero_fill = '0' and zero_start = '0' else
                     (others => '0');
    scratch_im_in <= c_im when cmul_read(CMUL2SCRATCH) = '1' else
                     y_im_in when scratch_fill(Y2SCRATCH) = '1' and zero_fill = '0' and zero_start = '0' else
                     (others => '0');

    y_index_i <= last_y_cnt when scratch_fill(0) = '1' and last_cycle_yr(0) = '1' else
                 scratch_fill_cnt(0) + offset_y when scratch_fill(0) = '1' and last_cycle_yr(0) = '0' else
                 cadd_index(CADD2Y) when y_we_i(CADD2Y) = '1' else
                 (others => '0');

    fft_run <= '1' when state = PREPARE else
               '1' when ifft_done(0) = '1' and last_cycle_x = '0' else
               '0';
    ifft_run <= fft_done(CMUL2SCRATCH);

    fft_wdone <= '1' when xn_index_i = max_index_i else
                 '0';
    -- ifft vorrang
    fft_edone <= edone_i when ifft_busy = '0' else
                 '0';
    fft_rdone <= '1' when xk_index_i = max_index_i else
                 '0';
    ifft_wdone <= '1' when xn_index_i = max_index_i else
                 '0';
    ifft_edone <= edone_i;
    ifft_rdone <= '1' when xk_index_i = max_index_i else
                 '0';

    scratch_fill(0) <= ifft_busy and not y2scratch_i;

    y2scratch_p: process(clk, ifft_write, ifft_busy)
    begin
        if clk = '1' and clk'event then
            if ifft_write = '1' or rst = '1' then
                y2scratch_i <= '0';
                scratch_fill_cnt(0) <= (others => '0');
            else
                if scratch_fill_cnt(0) = max_index_i then
                    y2scratch_i <= '1';
                end if;
                if scratch_fill(0) = '1' then
                   scratch_fill_cnt(0) <= scratch_fill_cnt(0) + 1; 
                end if;
            end if;
        end if;
    end process y2scratch_p;

    wave_i: entity work.wave
    port map(
        clk        => clk,
        en         => iq_i,
        rst        => prepare_we,
        wave_index => wave_index,
        run        => fft_write(X_READ_CYCLES),
        data       => x_in,
        i          => x_im_in,
        q          => x_re_in
    );

    cmul_i: entity work.cmul --TODO sch?
    port map(
        clk          => clk,
        sch          => cmul_sch_i,
        a_re         => cmul_a_re(H2CMUL),
        a_im         => cmul_a_im(H2CMUL),
        b_re         => h_re_in,
        b_im         => h_im_in,
        c_re         => c_re,
        c_im         => c_im,
        ovfl         => cmul_ovfl
    );
        
    cadd_i: entity work.cadd
    port map(
        clk          => clk,
        a_re         => cadd_a_re(SCRATCH2CADD),
        a_im         => cadd_a_im(SCRATCH2CADD),
        b_re         => scratch_re_out(0),
        b_im         => scratch_im_out(0),
        c_re         => y_re_out,
        c_im         => y_im_out,
        ovfl         => cadd_ovfl
    );

    y_we <= y_we_i(CADD2Y);

    fft_ctrl: entity work.fft_fsm
    port map(
        clk          => clk,
        rst          => rst,
        run          => fft_run,
        wdone        => fft_wdone,
        edone        => fft_edone,
        rdone        => fft_rdone,
        start        => fft_start,
        write        => fft_write(0),
        busy         => fft_busy,
        read         => fft_read,
        done         => fft_done(0)
    );

    ifft_ctrl: entity work.fft_fsm
    port map(
        clk          => clk,
        rst          => rst,
        run          => ifft_run,
        wdone        => ifft_wdone,
        edone        => ifft_edone,
        rdone        => ifft_rdone,
        start        => ifft_start,
        write        => ifft_write,
        busy         => ifft_busy,
        read         => ifft_read,
        done         => ifft_done(0)
    );
    ifft_read_i(0) <= ifft_read;
    fft_read_i(0) <= fft_read;
    y_we_i(0) <= ifft_read;

    scratch_i: scratch
	port map (
		clka  => clk,
		dina  => scratch_din,
		addra => scratch_addr,
		wea   => scratch_we_i,
		douta => scratch_dout
    );
    scratch_din(15 downto 0) <= scratch_re_in;
    scratch_din(31 downto 16) <= scratch_im_in;
    scratch_re_out(0) <= scratch_dout(15 downto 0);
    scratch_im_out(0) <= scratch_dout(31 downto 16);
    scratch_we_i(0) <= scratch_we;


    scale_sch_fft <= scale_sch_i when fwd_inv_i = '1' else
                     scale_schi_i;

    fft_inst: fft
    port map(
        sclr         => rst,
        fwd_inv_we   => fwd_inv_we_i,
        rfd          => rfd_i,
        start        => start_i,
        fwd_inv      => fwd_inv_i,
        dv           => dv_i,
        nfft_we      => prepare_we,
        scale_sch_we => fwd_inv_we_i,
        done         => done_i,
        clk          => clk,
        busy         => busy_i,
        edone        => edone_i,
        ovflo        => ovflo_fft,
        scale_sch    => scale_sch_fft,
        xn_re        => xn_re_i,
        xk_im        => xk_im_i,
        xn_index     => xn_index_i,
        nfft         => nfft,
        xk_re        => xk_re_i,
        xn_im        => xn_im_i,
        xk_index     => xk_index_i
    );
    cmul_a_im(0) <= xk_im_i;
    cadd_a_im(0) <= xk_im_i;
    cmul_a_re(0) <= xk_re_i;
    cadd_a_re(0) <= xk_re_i;
    cmul_index(0) <= xk_index_i;
    cadd_index(0) <= xk_index_i + offset_y;

    x_index_i <= xn_index_i + offset_x;

    x_index <= x_index_i;
    y_index <= y_index_i;

    h_index <= xk_index_i;

end Structural;

