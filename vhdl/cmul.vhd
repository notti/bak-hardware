library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity cmul is
generic(
    WIDTH_SHIFT : natural := 2
);
port(
    clk     : in std_logic;
    a_re    : in signed(15 downto 0);
    a_im    : in signed(15 downto 0);
    b_re    : in signed(15 downto 0);
    b_im    : in signed(15 downto 0);
    c_re    : out signed(15 downto 0);
    c_im    : out signed(15 downto 0);
    shift   : in std_logic_vector(WIDTH_SHIFT-1 downto 0);
    ovfl    : out std_logic;
    sat     : in std_logic
);
end cmul;

architecture Structural of cmul is
    signal a_reXb_re      : signed(31 downto 0);
    signal a_imXb_im      : signed(31 downto 0);
    signal a_reXb_im      : signed(31 downto 0);
    signal a_imXb_re      : signed(31 downto 0);
    signal c_re_big       : signed(32 downto 0);
    signal c_im_big       : signed(32 downto 0);
    signal c_re_out       : signed(15 downto 0);
    signal c_im_out       : signed(15 downto 0);
    signal im_ovfl        : std_logic;
    signal re_ovfl        : std_logic;
    signal shift_1        : std_logic_vector(WIDTH_SHIFT-1 downto 0);
    signal shift_2        : std_logic_vector(WIDTH_SHIFT-1 downto 0);
    signal shift_3        : std_logic_vector(WIDTH_SHIFT-1 downto 0);

begin
    -- c_re = a_re*b_re - a_im*b_im 
    -- c_im = a_re*b_im + a_im*b_re

    a_reXb_re_i: entity work.mul
    port map(
        clk => clk,
        a   => a_re,
        b   => b_re,
        c   => a_reXb_re
    );

    a_imXb_im_i: entity work.mul
    port map(
        clk => clk,
        a   => a_im,
        b   => b_im,
        c   => a_imXb_im
    );

    a_reXb_im_i: entity work.mul
    port map(
        clk => clk,
        a   => a_re,
        b   => b_im,
        c   => a_reXb_im
    );

    a_imXb_re_i: entity work.mul
    port map(
        clk => clk,
        a   => a_im,
        b   => b_re,
        c   => a_imXb_re
    );

    c_re_big <= resize(a_reXb_re, 33) - resize(a_imXb_im, 33);
    c_im_big <= resize(a_reXb_im, 33) + resize(a_imXb_re, 33);

    shift_dly: process(clk)
    begin
        if rising_edge(clk) then
            shift_1 <= shift;
            shift_2 <= shift_1;
            shift_3 <= shift_2;
        end if;
    end process shift_dly;

    c_re_round: entity work.convergent
    generic map(
        WIDTH_SHIFT => WIDTH_SHIFT
    )
    port map(
        clk => clk,
        a   => c_re_big,
        c   => c_re_out,
        shift => shift_3,
        ovfl => re_ovfl,
        sat => sat
    );

    c_im_round: entity work.convergent
    generic map(
        WIDTH_SHIFT => WIDTH_SHIFT
    )
    port map(
        clk => clk,
        a   => c_im_big,
        c   => c_im_out,
        shift => shift_3,
        ovfl => im_ovfl,
        sat => sat
    );

    c_re <= c_re_out;
    c_im <= c_im_out;
    ovfl <= im_ovfl or re_ovfl;

end Structural;

