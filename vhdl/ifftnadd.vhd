library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity ifftnadd is
port(
    clk          : in  std_logic;
    rst          : in  std_logic;

    prepare      : in  std_logic;
    run          : in  std_logic;
    is_last      : in  std_logic;

    L            : in  std_logic_vector(11 downto 0);
    NH           : in  std_logic_vector(15 downto 0);
    Nx           : in  std_logic_vector(15 downto 0);
    circular     : in  std_logic;

    xn_re        : out signed(15 downto 0);
    xn_im        : out signed(15 downto 0);
    xn_index     : in  std_logic_vector(11 downto 0);

    xk_re        : in  signed(15 downto 0);
    xk_im        : in  signed(15 downto 0);
    xk_index     : in  std_logic_vector(11 downto 0);

    scratch_re_in: in  signed(15 downto 0);
    scratch_im_in: in  signed(15 downto 0);
    scratch_re_out:out signed(15 downto 0);
    scratch_im_out:out signed(15 downto 0);
    scratch_wr   : out std_logic;
    scratch_index: out std_logic_vector(11 downto 0);
    scratch_re_outb:out signed(15 downto 0);
    scratch_im_outb:out signed(15 downto 0);
    scratch_wrb   : out std_logic;
    scratch_indexb: out std_logic_vector(11 downto 0);

    y_index      : out std_logic_vector(15 downto 0);
    y_re_in      : in  signed(15 downto 0);
    y_im_in      : in  signed(15 downto 0);
    y_re_out     : out signed(15 downto 0);
    y_im_out     : out signed(15 downto 0);
    y_wr         : out std_logic;

    start_fft    : out std_logic;
    edone        : in  std_logic;
    dv           : in  std_logic;
    rfd          : in  std_logic;

    mem_busy     : out std_logic;
    ifft_unload  : out std_logic;
    done         : out std_logic;
    waiting      : out std_logic;
    next_block   : out std_logic
);
end ifftnadd;

architecture Structural of ifftnadd is
    type fft_fsm_type is (INACTIVE, LOAD_IFFT, WAIT_IFFT, UNLOAD, YADD2SCRATCH, SCRATCH2Y, INCR, FINISHED);

    signal state : fft_fsm_type;
    signal block_cnt    : std_logic_vector(15 downto 0);
    signal addr_cnt     : std_logic_vector(11 downto 0);
    signal addr_cnt_1   : std_logic_vector(11 downto 0);
    signal addr_cnt_2   : std_logic_vector(11 downto 0);
    signal addr_cnt_3   : std_logic_vector(11 downto 0);
    signal xk_re_1      : signed(15 downto 0);
    signal xk_re_2      : signed(15 downto 0);
    signal xk_im_1      : signed(15 downto 0);
    signal xk_im_2      : signed(15 downto 0);
    signal addr_1       : std_logic_vector(15 downto 0);
    signal addr_2       : std_logic_vector(15 downto 0);
    signal addr         : std_logic_vector(15 downto 0);
    signal dv_1         : std_logic;
    signal dv_if        : std_logic;
    signal dv_if_1      : std_logic;
    signal dv_if_2      : std_logic;
    signal dv_2         : std_logic;
    signal dv_3         : std_logic;
    signal do_add       : std_logic;
    signal do_add_1     : std_logic;
    signal do_add_2     : std_logic;
    signal y_re         : signed(15 downto 0);
    signal y_im         : signed(15 downto 0);
    signal y_re_1       : signed(15 downto 0);
    signal y_im_1       : signed(15 downto 0);
    signal lowhi        : std_logic;
    signal circ_cnt     : std_logic_vector(11 downto 0);
    signal circ_cnt_1   : std_logic_vector(11 downto 0);
    signal circ_cnt_2   : std_logic_vector(11 downto 0);
    signal circ_cnt_3   : std_logic_vector(11 downto 0);
    signal y_index_1    : std_logic_vector(15 downto 0);
    signal y_re_in_1    : signed(15 downto 0);
    signal y_im_in_1    : signed(15 downto 0);
    signal scratch_cnt  : std_logic_vector(11 downto 0);
    signal scratch_cnt_1: std_logic_vector(11 downto 0);
    signal scratch_cnt_2: std_logic_vector(11 downto 0);
    signal next_0       : std_logic;
    signal next_1       : std_logic;
    signal next_2       : std_logic;
    signal next_3       : std_logic;

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
                            state <= LOAD_IFFT;
                        else
                            state <= INACTIVE;
                        end if;
                    when LOAD_IFFT =>
                        if rfd = '0' then
                            state <= WAIT_IFFT;
                        else
                            state <= LOAD_IFFT;
                        end if;
                    when WAIT_IFFT =>
                        if edone = '1' then
                            state <= UNLOAD;
                        else
                            state <= WAIT_IFFT;
                        end if;
                    when UNLOAD =>
                        if dv = '0' and dv_3 = '0' then
                            if circular = '1' and is_last = '1' then
                                state <= YADD2SCRATCH;
                            else
                                state <= INCR;
                            end if;
                        else
                            state <= UNLOAD;
                        end if;
                    when YADD2SCRATCH =>
                        if circ_cnt_3 = Nh - L - 1 then
                            state <= SCRATCH2Y;
                        else
                            state <= YADD2SCRATCH;
                        end if;
                    when SCRATCH2Y =>
                        if scratch_cnt = Nh - L - 2 then
                            state <= INCR;
                        else
                            state <= SCRATCH2Y;
                        end if;
                    when INCR => state <= FINISHED;
                    when FINISHED => state <= INACTIVE;
                end case;
            end if;
        end if;
    end process fft_p1;

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


--------------------------------------------------------------------------
-- FFT FILL aka ifft(scratch,Nf)
--------------------------------------------------------------------------

    start_fft <= '1' when state = INACTIVE and run = '1' else
                 '0';

    scratch_index <= scratch_cnt when state = SCRATCH2Y else
                     circ_cnt_3 when state = YADD2SCRATCH else
                     xn_index when state = LOAD_IFFT else
                     xk_index;
    scratch_indexb <= addr_cnt_3;
    --scratch: 2 read cycles; fft 3 -> delay by one
    xn_dly: process(clk)
    begin
        if rising_edge(clk) then
            xn_re <= scratch_re_in;
            xn_im <= scratch_im_in;
        end if;
    end process;

--------------------------------------------------------------------------
-- SCRATCH FILL with y(block_cnt:block_cnt+NH-L-1)
--------------------------------------------------------------------------
    addr_cnt_impl: process(clk)
    begin
        if rising_edge(clk) then
            if state /= LOAD_IFFT then
                addr_cnt <= (others => '0');
            else
                addr_cnt <= addr_cnt + 1;
            end if;
        end if;
    end process addr_cnt_impl;

    addr_cnt_dly: process(clk)
    begin
        if rising_edge(clk) then
            addr_cnt_1 <= addr_cnt;
            addr_cnt_2 <= addr_cnt_1;
            addr_cnt_3 <= addr_cnt_2;
        end if;
    end process addr_cnt_dly;

    addr <= addr_cnt + block_cnt when state = LOAD_IFFT else
            addr_2;

    y_index_dly: process(clk)
    begin
        if rising_edge(clk) then
            y_index_1 <= addr;
        end if;
    end process y_index_dly;

    y_index <= "0000" & circ_cnt when state = YADD2SCRATCH and lowhi = '0' else
               circ_cnt + Nx when state = YADD2SCRATCH and lowhi = '1' else
               "0000" & scratch_cnt_2 when state = SCRATCH2Y else
               y_index_1;

    scratch_re_out <= y_re_in + y_re_in_1 when state = YADD2SCRATCH else
                      (others => '0') when block_cnt = "0000" else
                      y_re_in;
    scratch_im_out <= y_im_in + y_im_in_1 when state = YADD2SCRATCH else
                      (others => '0') when block_cnt = "0000" else
                      y_im_in;
    scratch_re_outb <= y_re_in;
    scratch_im_outb <= y_im_in;
    scratch_wr <= lowhi when circ_cnt_3 < Nh - L and state = YADD2SCRATCH else
                  '0';
    scratch_wrb <= '1' when addr_cnt > 2 and state = LOAD_IFFT else
                   '0';

--------------------------------------------------------------------------
-- UNLOAD aka y=scratch(0:Nf-L-1) + ifft()
--------------------------------------------------------------------------
    do_add <= '1' when xk_index < NH - L else
              '0';
    -- scratch 2 read cycles
    xk_dly: process(clk)
    begin
        if rising_edge(clk) then
            xk_re_1 <= xk_re;
            xk_re_2 <= xk_re_1;
            xk_im_1 <= xk_im;
            xk_im_2 <= xk_im_1;
            do_add_1 <= do_add;
            do_add_2 <= do_add_1;
        end if;
    end process xk_dly;

    y_re <= xk_re_2 + scratch_re_in when do_add_2 = '1' else
            xk_re_2;
    y_im <= xk_im_2 + scratch_im_in when do_add_2 = '1' else
            xk_im_2;

    y_re_out <= scratch_re_in when state = SCRATCH2Y else
                y_re_1;
    y_im_out <= scratch_im_in when state = SCRATCH2Y else
                y_im_1;

    y_re_dly: process(clk)
    begin
        if rising_edge(clk) then
            y_re_1 <= y_re;
            y_im_1 <= y_im;
        end if;
    end process;
    
    --y addr delay by 3 (2 cycle scratch + 1 cycle add)
    addr_dly: process(clk)
    begin
        if rising_edge(clk) then
            addr_1 <= block_cnt + xk_index;
            addr_2 <= addr_1;
        end if;
    end process addr_dly;

    --don't write values > Nx
    dv_if <= dv_1 when addr_1 < Nx and circular = '0' else
             dv_1 when addr_1 < Nx + Nh - L - 1 and circular = '1' else
             '0';

    dv_dly: process(clK)
    begin
        if rising_edge(clk) then
            dv_1 <= dv;
            dv_2 <= dv_1;
            dv_if_1 <= dv_if;
            dv_3 <= dv_2;
            dv_if_2 <= dv_if_1;
        end if;
    end process dv_dly;

    y_wr <= '1' when state = SCRATCH2Y else
            dv_if_2 when state = UNLOAD else
            '0';

--------------------------------------------------------------------------
-- YADD2SCRATCH scratch(0:Nh-L-1) <= y(0:Nh-L-1) + y(Nx:Nx+Nh-L-1)
--------------------------------------------------------------------------

    lowhi_p: process(clk)
    begin
        if rising_edge(clk) then
            if state /= YADD2SCRATCH then
                lowhi <= '0';
            else
                lowhi <= not lowhi;
            end if;
        end if;
    end process lowhi_p;

    circ_cnt_p: process(clk)
    begin
        if rising_edge(clk) then
            if state /= YADD2SCRATCH then
                circ_cnt <= (others => '0');
            elsif lowhi = '1' then
                circ_cnt <= circ_cnt + 1;
            end if;
        end if;
    end process circ_cnt_p;

    -- delay by 3 cycles (2 cycles y read + 1 cycle 2nd value)
    circ_cnt_dly: process(clk)
    begin
        if rising_edge(clk) then
            circ_cnt_1 <= circ_cnt;
            circ_cnt_2 <= circ_cnt_1;
            circ_cnt_3 <= circ_cnt_2;
        end if;
    end process circ_cnt_dly;

    y_in_dly: process(clk)
    begin
        if rising_edge(clk) then
            y_re_in_1 <= y_re_in;
            y_im_in_1 <= y_im_in;
        end if;
    end process y_in_dly;

--------------------------------------------------------------------------
-- SCRATCH2Y y(0:Nh-L-1) <= scratch(0:Nh-L-1)
--------------------------------------------------------------------------
    scratch_cnt_p: process(clk)
    begin
        if rising_edge(clk) then
            if state /= SCRATCH2Y then
                scratch_cnt <= (others => '0');
            else
                scratch_cnt <= scratch_cnt + 1;
            end if;
        end if;
    end process scratch_cnt_p;

    scratch_cnt_dly: process(clk)
    begin
        if rising_edge(clk) then
            scratch_cnt_1 <= scratch_cnt;
            scratch_cnt_2 <= scratch_cnt_1;
        end if;
    end process scratch_cnt_dly;

--------------------------------------------------------------------------
-- tell the rest of the world what we're doing
--------------------------------------------------------------------------

    mem_busy <= '1' when state = UNLOAD or state = LOAD_IFFT else
                '0';
    ifft_unload <= '1' when state = UNLOAD else
                   '0';
    done <= '1' when state = FINISHED else
            '0';
    waiting <= '1' when state = WAIT_IFFT else
               '0';
    next_0 <= '1' when state = WAIT_IFFT else
              '0';

    next_dly: process(clk)
    begin
        if rising_edge(clk) then
            next_1 <= next_0;
            next_2 <= next_1;
            next_3 <= next_2;
        end if;
    end process;

    next_block <= '1' when next_3 = '0' and next_2 = '1' else
                  '0';

end Structural;

