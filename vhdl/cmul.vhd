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
    c_im    : out signed(15 downto 0);
    shift   : in std_logic;
    ovfl    : out std_logic
);
end cmul;

architecture Structural of cmul is
    signal a_reXb_re      : signed(31 downto 0);
    signal a_imXb_im      : signed(31 downto 0);
    signal a_reXb_im      : signed(31 downto 0);
    signal a_imXb_re      : signed(31 downto 0);
    signal c_re_big       : signed(31 downto 0);
    signal c_im_big       : signed(31 downto 0);
    signal c_re_big_shift : signed(31 downto 0);
    signal c_im_big_shift : signed(31 downto 0);
    signal c_re_out       : signed(15 downto 0);
    signal c_im_out       : signed(15 downto 0);

    signal c_re_sign_dly  : std_logic_vector(1 downto 0);
    signal c_im_sign_dly  : std_logic_vector(1 downto 0);
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

    sign_dly: process(clk)
    begin
        if rising_edge(clk) then
           c_re_sign_dly <= a_reXb_re(30) & a_imXb_im(30);
           c_im_sign_dly <= a_reXb_im(30) & a_imXb_re(30);
       end if;
    end process;

    c_re_big_shift <= c_re_big(30 downto 0) & "0" when shift = '1' else
                      c_re_big;
    c_im_big_shift <= c_im_big(30 downto 0) & "0" when shift = '1' else
                      c_im_big;

    c_re_round: entity work.convergent
    port map(
        clk => clk,
        a   => c_re_big_shift,
        c   => c_re_out
    );

    c_im_round: entity work.convergent
    port map(
        clk => clk,
        a   => c_im_big_shift,
        c   => c_im_out
    );

    ovfl <= '0' when shift = '0' else
            '1' when (c_im_sign_dly = "11" and c_im_out(15) = '0') or
                     (c_im_sign_dly = "00" and c_im_out(15) = '1') or
                     (c_re_sign_dly = "10" and c_re_out(15) = '0') or
                     (c_re_sign_dly = "01" and c_re_out(15) = '1') else
            '0';
    c_re <= c_re_out;
    c_im <= c_im_out;

end Structural;

