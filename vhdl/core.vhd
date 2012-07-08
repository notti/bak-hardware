library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity core is
port(
    clk            : in  std_logic;
    rst            : in  std_logic;

    fft_start      : in  std_logic;
    fft_n          : in  std_logic_vector(4 downto 0);
    fft_scale_sch  : in  std_logic_vector(11 downto 0);
    fft_scale_schi : in  std_logic_vector(11 downto 0);
    fft_cmul_sch   : in  std_logic_vector(1 downto 0);
    fft_L          : in  std_logic_vector(11 downto 0);
    fft_depth      : in  std_logic_vector(15 downto 0);
    fft_iq         : in  std_logic;

    fft_ov_fft     : out std_logic;
    fft_ov_ifft    : out std_logic;
    fft_ov_cmul    : out std_logic;

    fft_busy       : out std_logic;
    fft_done       : out std_logic

    wave_index     : in  std_logic_vector(3 downto 0);

    mem_dinx       : in  std_logic_vector(15 downto 0);
    mem_addrx      : out std_logic_vector(15 downto 0);

    mem_diny       : in  std_logic_vector(31 downto 0);
    mem_addry      : out std_logic_vector(15 downto 0);
    mem_douty      : out std_logic_vector(31 downto 0);
    mem_wey        : out std_logic;

    mem_clkh       : in  std_logic;
    mem_dinh       : in  std_logic_vector(31 downto 0);
    mem_addrh      : in  std_logic_vector(15 downto 0);
    mem_weh        : in  std_logic_vector(3 downto 0);
    mem_douth      : out std_logic_vector(31 downto 0);
);
end core;

architecture Structural of core is
component h
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(11 downto 0);
	wea: IN std_logic_VECTOR(3 downto 0);
	douta: OUT std_logic_VECTOR(31 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(31 downto 0);
	addrb: IN std_logic_VECTOR(11 downto 0);
	web: IN std_logic_VECTOR(3 downto 0);
	doutb: OUT std_logic_VECTOR(31 downto 0));
end component;

attribute syn_black_box : boolean;
attribute syn_black_box of h: component is true;

signal addra    : std_logic_vector(15 downto 0);
signal douta    : std_logic_vector(31 downto 0);
begin

    overlap_add_inst: entity work.overlap_add
    port map(
        clk          => clk,
        rst          => rst,

        start        => fft_start,
        nfft         => fft_n,
        scale_sch    => fft_scale_sch,
        scale_schi   => fft_scale_schi,
        cmul_sch     => fft_cmul_sch,
        L            => fft_L,
        n            => fft_depth,
        iq           => fft_iq,

        wave_index   => wave_index,
        x_in         => mem_dinx,
        x_index      => mem_addrx,

        y_re_in      => mem_diny(15 downto 0),
        y_im_in      => mem_diny(31 downto 16),
        y_re_out     => mem_douty(15 downto 0),
        y_im_out     => mem_douty(31 downto 16),
        y_index      => mem_addry,
        y_we         => mem_wey,

        h_re_in      => douta(15 downto 0),
        h_im_in      => douta(31 downto 16),
        h_index      => addra,

        ovfl_fft     => fft_ov_fft,
        ovfl_ifft    => fft_ov_ifft,
        ovfl_cmul    => fft_ov_cmul,

        busy         => fft_busy,
        done         => fft_done,
    );

    
    h_inst: h
    port map (
        clka       => clk,
        dina       => (others => '0'),
        addra      => addra,
        wea        => (others => '0'),
        douta      => douta,
        clkb       => mem_clkh,
        dinb       => mem_dinh,
        addrb      => mem_addrh,
        web        => mem_weh,
        doutb      => mem_douth
    );

end Structural;

