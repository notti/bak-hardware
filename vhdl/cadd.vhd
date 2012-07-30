library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity cadd is
port(
    clk     : in std_logic;
    a_re    : in std_logic_vector(15 downto 0);
    a_im    : in std_logic_vector(15 downto 0);
    b_re    : in std_logic_vector(15 downto 0);
    b_im    : in std_logic_vector(15 downto 0);
    c_re    : out std_logic_vector(15 downto 0);
    c_im    : out std_logic_vector(15 downto 0);
    ovfl    : out std_logic
);
end cadd;

architecture Structural of cadd is
    signal c_re_i : std_logic_vector(15 downto 0);
    signal c_im_i : std_logic_vector(15 downto 0);
    signal ovfl_re : std_logic;
    signal ovfl_im : std_logic;
begin

    c_re_i <= a_re + b_re;
    c_im_i <= a_im + b_im;
    ovfl_re <= (a_re(15) and b_re(15) and (not c_re_i(15))) or ((not a_re(15)) and (not b_re(15)) and c_re_i(15));
    ovfl_im <= (a_im(15) and b_im(15) and (not c_im_i(15))) or ((not a_im(15)) and (not b_im(15)) and c_im_i(15));
    add_p: process(clk)
    begin
        if rising_edge(clk) then
            ovfl <= ovfl_re or ovfl_im;
            c_re <= c_re_i;
            c_im <= c_im_i;
        end if;
    end process add_p;

end Structural;

