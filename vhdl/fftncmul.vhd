library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity fftncmul is
port(
    clk          : in  std_logic;
    rst          : in  std_logic;

    prepare      : in  std_logic;
    run          : in  std_logic;

    wave_index   : in  std_logic_vector(3 downto 0);
    L            : in  std_logic_vector(11 downto 0);
    NH           : in  std_logic_vector(15 downto 0);
    Nx           : in  std_logic_vector(15 downto 0);
    iq           : in  std_logic;

    xn_addr      : out std_logic_vector(15 downto 0);
    xn_in        : in  signed(15 downto 0);

    xn_re        : out signed(15 downto 0);
    xn_im        : out signed(15 downto 0);

    xk_re        : in  signed(15 downto 0);
    xk_im        : in  signed(15 downto 0);
    xk_index     : in  std_logic_vector(11 downto 0);

    H_re         : in  signed(15 downto 0);
    H_im         : in  signed(15 downto 0);
    H_index      : out std_logic_vector(11 downto 0);

    scratch_re   : out signed(15 downto 0);
    scratch_im   : out signed(15 downto 0);
    scratch_wr   : out std_logic;
    scratch_index: out std_logic_vector(11 downto 0);

    start_fft    : out std_logic;
    edone        : in  std_logic;
    dv           : in  std_logic;

    scale_cmul   : in  std_logic_vector(1 downto 0);
    ovfl_cmul    : out std_logic;

    mem_busy     : out std_logic;
    fft_unload   : out std_logic;
    done         : out std_logic;
    was_last     : out std_logic
);
end fftncmul;

architecture Structural of fftncmul is
    type fft_fsm_type is (INACTIVE, LOAD, INCR, WAIT_FFT, UNLOAD, FINISHED);

    signal state : fft_fsm_type;
    signal addr_cnt     : std_logic_vector(15 downto 0);
    signal addr_cnt_1   : std_logic_vector(15 downto 0);
    signal block_cnt    : std_logic_vector(15 downto 0);
    signal addr         : std_logic_vector(15 downto 0);
    signal addr_1       : std_logic_vector(15 downto 0);
    signal re           : signed(15 downto 0);
    signal im           : signed(15 downto 0);
    signal addr_l_L     : std_logic;
    signal addr_l_Nx    : std_logic;
    signal addr_l_NH    : std_logic;
    signal addr_l_NH_1  : std_logic;
    signal addr_l_NH_2  : std_logic;
    signal addr_l_NH_3  : std_logic;
    signal addr_l_NH_4  : std_logic;
    signal addr_l_L_1   : std_logic;
    signal addr_l_Nx_1  : std_logic;
    signal nzero_pad    : std_logic;
    signal nzero_pad_1  : std_logic;
    signal nzero_pad_2  : std_logic;
    signal nzero_pad_3  : std_logic;
    signal nzero_pad_4  : std_logic;
    signal do_fft       : std_logic;
    signal do_fft_1     : std_logic;
    signal do_fft_2     : std_logic;
    signal wave_run     : std_logic;
    signal wave_run_1   : std_logic;
    signal wave_run_2   : std_logic;
    signal wave_run_i   : std_logic;
    signal xk_re_1      : signed(15 downto 0);
    signal xk_re_2      : signed(15 downto 0);
    signal xk_im_1      : signed(15 downto 0);
    signal xk_im_2      : signed(15 downto 0);
    signal xk_index_1   : std_logic_vector(11 downto 0);
    signal xk_index_2   : std_logic_vector(11 downto 0);
    signal xk_index_3   : std_logic_vector(11 downto 0);
    signal xk_index_4   : std_logic_vector(11 downto 0);
    signal xk_index_5   : std_logic_vector(11 downto 0);
    signal xk_index_6   : std_logic_vector(11 downto 0);
    signal dv_1         : std_logic;
    signal dv_2         : std_logic;
    signal dv_3         : std_logic;
    signal dv_4         : std_logic;
    signal dv_5         : std_logic;
    signal dv_6         : std_logic;
begin

    fft_p1: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= INACTIVE;
            else
                case state is
                    when INACTIVE  =>
                        if run = '1' then
                            state <= LOAD;
                        else
                            state <= INACTIVE;
                        end if;
                    when LOAD =>
                        if addr_l_NH_4 = '0' then
                            state <= INCR;
                        else
                            state <= LOAD;
                        end if;
                    when INCR => state <= WAIT_FFT;
                    when WAIT_FFT =>
                        if edone = '1' then
                            state <= UNLOAD;
                        else
                            state <= WAIT_FFT;
                        end if;
                    when UNLOAD =>
                        if dv ='0' and dv_6 = '0' then
                            state <= FINISHED;
                        else
                            state <= UNLOAD;
                        end if;
                    when FINISHED => state <= INACTIVE;
                end case;
            end if;
        end if;
    end process fft_p1;

--------------------------------------------------------------------------
-- FFT FILL aka fft(x(block_cnt:block_cnt+L-1),Nf)
--------------------------------------------------------------------------

    wave_run <= '1' when state = LOAD and addr_l_l = '1' else
                '0';
    wave_run_i <= wave_run and wave_run_2;

    wave_i: entity work.wave
    port map(
        clk        => clk,
        en         => iq,
        rst        => prepare,
        wave_index => wave_index,
        run        => wave_run_i,
        data       => xn_in,
        i          => re,
        q          => im
    );

    block_cnt_impl: process(clk)
    begin
        if rising_edge(clk) then
            if state = INACTIVE and prepare = '1' then
                block_cnt <= (others => '0');
            elsif state = INCR then
                block_cnt <= block_cnt + L;
            end if;
        end if;
    end process;

    addr_cnt_impl: process(clk)
    begin
        if rising_edge(clk) then
            if state /= LOAD then
                addr_cnt <= (others => '0');
                do_fft <= '0';
                do_fft_1 <= '0';
                do_fft_2 <= '0';
            else
                do_fft <= '1';
                do_fft_1 <= do_fft;
                do_fft_2 <= do_fft_1;
                addr_cnt <= addr_cnt + 1;
            end if;
        end if;
    end process addr_cnt_impl;

    -- delay fft start by 1 cycle (start takes 1 cycle + 3 cycle pre
    -- load = 4; + 1 delayed = 5)
    start_fft <= do_fft_1 xor do_fft_2;

    addr <= addr_cnt + block_cnt;
    xn_addr <= addr;

    addr_l_L <= '1' when addr_cnt_1 <= L else
                 '0';
    addr_l_Nx <= '1' when addr_1 < Nx else
                 '0';
    addr_l_NH <= '1' when addr_cnt_1 < NH else
                 '0';
    nzero_pad <= addr_l_L_1 and addr_l_Nx_1;

    addr_dly: process(clk)
    begin
        if rising_edge(clk) then
            addr_1 <= addr;
            wave_run_1 <= wave_run;
            wave_run_2 <= wave_run_1;
            addr_cnt_1 <= addr_cnt;
            addr_l_L_1 <= addr_l_L;
            addr_l_Nx_1 <= addr_l_Nx;
            addr_l_NH_1 <= addr_l_NH;
            addr_l_NH_2 <= addr_l_NH_1;
            addr_l_NH_3 <= addr_l_NH_2;
            addr_l_NH_4 <= addr_l_NH_3;
            nzero_pad_1 <= nzero_pad;
            nzero_pad_2 <= nzero_pad_1;
            nzero_pad_3 <= nzero_pad_2;
            nzero_pad_4 <= nzero_pad_3;
        end if;
    end process addr_dly;

    --zero pad when addr_cnt >= L or addr >=Nx
    xn_re <= re when nzero_pad_4 = '1' else
             (others => '0');
    xn_im <= im when nzero_pad_4 = '1' else
             (others => '0');

--------------------------------------------------------------------------
-- FFT UNLOAD aka scratch = X.*H (bit reversed order - but we don't care
--    since we get the addresses from the fft
--------------------------------------------------------------------------

    H_index <= xk_index;
    -- H 2 read cycles - so delay fft by 2
    xk_dly: process(clk)
    begin
        if rising_edge(clk) then
            xk_re_1 <= xk_re;
            xk_re_2 <= xk_re_1;
            xk_im_1 <= xk_im;
            xk_im_2 <= xk_im_1;
        end if;
    end process xk_dly;
    
    -- this takes 4 cycles
    cmul_i: entity work.cmul
    port map(
        clk          => clk,
        a_re         => xk_re_2,
        a_im         => xk_im_2,
        b_re         => H_re,
        b_im         => H_im,
        c_re         => scratch_re,
        c_im         => scratch_im,
        shift        => scale_cmul,
        sat          => '0',
        ovfl         => ovfl_cmul
    );

    -- delay addr + wr for scratch by 2 read + 4 cmul cycles = 6
    xk_dly_1: process(clk)
    begin
        if rising_edge(clk) then
            xk_index_1 <= xk_index;
            xk_index_2 <= xk_index_1;
            xk_index_3 <= xk_index_2;
            xk_index_4 <= xk_index_3;
            xk_index_5 <= xk_index_4;
            xk_index_6 <= xk_index_5;
            dv_1 <= dv;
            dv_2 <= dv_1;
            dv_3 <= dv_2;
            dv_4 <= dv_3;
            dv_5 <= dv_4;
            dv_6 <= dv_5;
        end if;
    end process xk_dly_1;

    scratch_wr <= dv_6;
    scratch_index <= xk_index_6;

--------------------------------------------------------------------------
-- tell the rest of the world what we're doing
--------------------------------------------------------------------------

    mem_busy <= '1' when state = UNLOAD or state = LOAD else
                '0';
    fft_unload <= '1' when state = UNLOAD else
                  '0';
    done <= '1' when state = FINISHED else
            '0';
    -- if this was our last fft then addr_l_Nx is 0 during finished
    --  -> addr_cnt = 0; block_cnt = n*L (where n*L > Nx)
    --  -> addr = addr_cnt + block_cnt
    was_last_reg: process(clk)
    begin
        if rising_edge(clk) then
            if state = INACTIVE and prepare = '1' then
                was_last <= '0';
            elsif state = FINISHED and addr_l_Nx_1 = '0' then
                was_last <= '1';
            end if;
        end if;
    end process was_last_reg;

end Structural;

