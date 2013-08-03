library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity convergent is
generic(
    WIDTH_IN    : integer := 33;
    WIDTH_OUT   : integer := 16
);
port(
    clk     : in  std_logic;
    a       : in  signed(WIDTH_IN-1 downto 0);
    c       : out signed(WIDTH_OUT-1 downto 0);
    shift   : in  std_logic_vector(1 downto 0);
    ovfl    : out std_logic;
    sat     : in  std_logic
);
end convergent;

architecture Structural of convergent is
    type a_round_arr is array(3 downto 0) of signed(WIDTH_OUT-1 downto 0);
    signal a_round : a_round_arr;
    signal c_ovfl : std_logic_vector(3 downto 0);
    signal neg : std_logic_vector(3 downto 0);
begin
    c_ovfl(0) <= '0';
    round_gen: for i in 0 to 3 generate
        signal updown : signed(1 downto 0);
        signal a_round_big : signed(WIDTH_OUT+i downto 0);
    begin
        updown(1) <= '0';
        updown(0) <= a(WIDTH_IN-WIDTH_OUT-i) when std_logic_vector(a(WIDTH_IN-WIDTH_OUT-2-i downto 0)) = (WIDTH_IN-WIDTH_OUT-2-i downto 0 => '0') else
                     '1';
        a_round_big <= a(WIDTH_IN-1 downto WIDTH_IN-WIDTH_OUT-1-i) + updown;
        neg(i) <= a_round_big(WIDTH_OUT+i);
        a_round(i) <= a_round_big(WIDTH_OUT downto 1);
        ov: if i > 0 generate
        begin
            c_ovfl(i) <= '0' when std_logic_vector(a_round_big(WIDTH_OUT+i downto WIDTH_OUT+1)) = (i-1 downto 0 => a_round_big(WIDTH_OUT)) else
                         '1';
        end generate ov;
    end generate round_gen;

    reg: process(clk)
    begin
        if rising_edge(clk) then
            if sat = '0' or c_ovfl(to_integer(unsigned(shift))) = '0' then
                c <= a_round(to_integer(unsigned(shift)));
            else
                c(WIDTH_OUT-1) <= neg(to_integer(unsigned(shift)));
                c(WIDTH_OUT-2 downto 0) <= (others => not neg(to_integer(unsigned(shift))));
            end if;
            ovfl <= c_ovfl(to_integer(unsigned(shift)));
        end if;
    end process;

end Structural;

