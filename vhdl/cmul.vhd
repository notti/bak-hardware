library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity cmul is
port(
    clk     : in std_logic;
    a_re    : in signed(15 downto 0);
    a_im    : in signed(15 downto 0);
    b_re    : in signed(15 downto 0);
    b_im    : in signed(15 downto 0);
    c_re    : out signed(15 downto 0);
    c_im    : out signed(15 downto 0)
);
end cmul;

architecture Structural of cmul is
    signal a_reXb_re : signed(31 downto 0);
    signal a_imXb_im : signed(31 downto 0);
    signal a_reXb_im : signed(31 downto 0);
    signal a_imXb_re : signed(31 downto 0);
    signal c_re_big  : signed(31 downto 0);
    signal c_im_big  : signed(31 downto 0);
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

    c_re_big <= a_reXb_re - a_imXb_im;
    c_im_big <= a_reXb_im + a_imXb_re;

    c_re_round: entity work.convergent
    port map(
        clk => clk,
        a   => c_re_big,
        c   => c_re
    );

    c_im_round: entity work.convergent
    port map(
        clk => clk,
        a   => c_im_big,
        c   => c_im
    );

end Structural;

