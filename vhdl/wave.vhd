library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity wave is
port(
    clk        : in std_logic;
    rst        : in std_logic;
    en         : in std_logic;
    wave_index : in std_logic_vector(3 downto 0);
    run        : in std_logic;
    data       : in std_logic_vector(15 downto 0);
    i          : out std_logic_vector(15 downto 0);
    q          : out std_logic_vector(15 downto 0)
);
end wave;

architecture Structural of wave is
    signal cnt: std_logic_vector(3 downto 0) := X"0";
    type comp is array(natural range <>) of std_logic_vector(15 downto 0);
    signal c: comp(0 to 9) :=
          --(  32767,  -10126,  -26509,   26509,   10126,  -32767,   10126,   26509,  -26509, -10126
            (X"7FFF", X"D872", X"9873", X"678D", X"278E", X"8001", X"278E", X"678D", X"9873", X"D872");
    signal s: comp(0 to 9) :=
          --(      0,   31163,  -19260,  -19260,   31163,       0,  -31163,   19260,   19260,   -31163
            (X"0000", X"79BB", X"B4C4", X"B4C4", X"79BB", X"0000", X"8645", X"4B3C", X"4B3C", X"8645");
    signal i_long : std_logic_vector(31 downto 0);
    signal q_long : std_logic_vector(31 downto 0);
    signal i_long_1 : std_logic_vector(31 downto 0);
    signal q_long_1 : std_logic_vector(31 downto 0);
    signal data_r : std_logic_vector(15 downto 0);
    signal data_r_1 : std_logic_vector(15 downto 0);
    signal data_r_2 : std_logic_vector(15 downto 0);
begin
    cnt_p: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt <= wave_index;
            elsif run = '1' then
                if cnt = X"9" then
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process cnt_p;

    mul_p: process(clk)
    begin
        if rising_edge(clk) then
            data_r <= data;
            i_long_1 <= data_r*c(conv_integer(cnt));
            q_long_1 <= data_r*s(conv_integer(cnt));
            data_r_1 <= data_r;
            i_long <= i_long_1;
            q_long <= q_long_1;
            data_r_2 <= data_r_1;
        end if;
    end process mul_p;


    i <= i_long(31 downto 16) when en = '1' else
         data_r_2;
    q <= q_long(31 downto 16) when en = '1' else
         (others => '0');

end Structural;

