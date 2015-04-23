library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity core is
port(
    clk             : in  std_logic;
    rst             : in  std_logic;

    core_start      : in  std_logic;
    core_n          : in  std_logic_vector(4 downto 0);
    core_scale_sch  : in  std_logic_vector(11 downto 0);
    core_scale_schi : in  std_logic_vector(11 downto 0);
    core_scale_cmul : in  std_logic_vector(1 downto 0);
    core_L          : in  std_logic_vector(11 downto 0);
    core_depth      : in  std_logic_vector(15 downto 0);
    core_iq         : in  std_logic;
    core_circular   : in std_logic;

    core_ov_fft     : out std_logic;
    core_ov_ifft    : out std_logic;
    core_ov_cmul    : out std_logic;

    core_busy       : out std_logic;
    core_done       : out std_logic;

    wave_index      : in  std_logic_vector(3 downto 0);

    mem_dinx        : in  std_logic_vector(15 downto 0);
    mem_addrx       : out std_logic_vector(15 downto 0);

    mem_diny        : in  std_logic_vector(31 downto 0);
    mem_addry       : out std_logic_vector(15 downto 0);
    mem_douty       : out std_logic_vector(31 downto 0);
    mem_wey         : out std_logic;

    mem_dinh        : in  std_logic_vector(31 downto 0);
    mem_addrh       : in  std_logic_vector(15 downto 0);
    mem_weh         : in  std_logic_vector(3 downto 0);
    mem_douth       : out std_logic_vector(31 downto 0);
    mem_enh         : in  std_logic
);
end core;

architecture Structural of core is
    signal addra    : std_logic_vector(11 downto 0);
    signal douta    : std_logic_vector(31 downto 0);
    signal y_re_out : signed(15 downto 0);
    signal y_im_out : signed(15 downto 0);
    signal core_busy_i : std_logic;
begin

    mem_douty(15 downto 0) <= std_logic_vector(y_re_out);
    mem_douty(31 downto 16) <= std_logic_vector(y_im_out);

    overlap_add_inst: entity work.overlap_add
    port map(
        clk          => clk,
        rst          => rst,

        start        => core_start,
        nfft         => core_n,
        scale_sch    => core_scale_sch,
        scale_schi   => core_scale_schi,
        scale_cmul   => core_scale_cmul,
        L            => core_L,
        Nx           => core_depth,
        iq           => core_iq,
        circular     => core_circular,

        wave_index   => wave_index,
        x_in         => signed(mem_dinx),
        x_index      => mem_addrx,

        y_re_in      => signed(mem_diny(15 downto 0)),
        y_im_in      => signed(mem_diny(31 downto 16)),
        y_re_out     => y_re_out,
        y_im_out     => y_im_out,
        y_index      => mem_addry,
        y_we         => mem_wey,

        h_re_in      => signed(douta(15 downto 0)),
        h_im_in      => signed(douta(31 downto 16)),
        h_index      => addra,

        ovfl_fft     => core_ov_fft,
        ovfl_ifft    => core_ov_ifft,
        ovfl_cmul    => core_ov_cmul,

        busy         => core_busy_i,
        done         => core_done
    );

    core_busy <= core_busy_i;
    
    h_inst: entity work.ram4x32
    generic map(
        DOA_REG             => 1,
        DOB_REG             => 1)
    port map (
        clka       => clk,
        dina       => (others => '0'),
        addra      => addra,
        wea        => (others => '0'),
        douta      => douta,
        ena        => core_busy_i,
        clkb       => clk,
        dinb       => mem_dinh,
        addrb      => mem_addrh(11 downto 0),
        web        => mem_weh,
        doutb      => mem_douth,
        enb        => mem_enh
    );
end Structural;

