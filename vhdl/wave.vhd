library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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
    data       : in signed(15 downto 0);
    i          : out signed(15 downto 0);
    q          : out signed(15 downto 0)
);
end wave;

architecture Structural of wave is
    signal cnt: std_logic_vector(3 downto 0) := X"0";
    type comp is array(natural range <>) of signed(15 downto 0);
    signal c: comp(0 to 9) :=
          --(  32767,  -10126,  -26509,   26509,   10126,  -32767,   10126,   26509,  -26509, -10126
            (X"7FFF", X"D872", X"9873", X"678D", X"278E", X"8001", X"278E", X"678D", X"9873", X"D872");
    signal s: comp(0 to 9) :=
          --(      0,   31163,  -19260,  -19260,   31163,       0,  -31163,   19260,   19260,   -31163
            (X"0000", X"79BB", X"B4C4", X"B4C4", X"79BB", X"0000", X"8645", X"4B3C", X"4B3C", X"8645");
    signal data_r : signed(15 downto 0);
    signal data_r_1 : signed(15 downto 0);
    signal data_r_2 : signed(15 downto 0);
    signal data_r_3 : signed(15 downto 0);
    signal a_i    : signed(15 downto 0);
    signal b_i    : signed(15 downto 0);
    signal a_q    : signed(15 downto 0);
    signal b_q    : signed(15 downto 0);
    signal c_i    : signed(31 downto 0);
    signal c_q    : signed(31 downto 0);
    signal pipe_i_1 : signed(31 downto 0);
    signal pipe_i_2 : signed(31 downto 0);
    signal pipe_i_3 : signed(31 downto 0);
    signal pipe_q_1 : signed(31 downto 0);
    signal pipe_q_2 : signed(31 downto 0);
    signal pipe_q_3 : signed(31 downto 0);
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

    c_i <= a_i * b_i;

    mul_i_p: process(clk)
    begin
        if rising_edge(clk) then
            a_i <= data;
            b_i <= c(conv_integer(cnt));
            pipe_i_1 <= c_i;
            pipe_i_2 <= pipe_i_1;
            pipe_i_3 <= pipe_i_2;
        end if;
    end process;
            
    c_q <= a_q * b_q;

    mul_q_p: process(clk)
    begin
        if rising_edge(clk) then
            a_q <= data;
            b_q <= c(conv_integer(cnt));
            pipe_q_1 <= c_q;
            pipe_q_2 <= pipe_q_1;
            pipe_q_3 <= pipe_q_2;
        end if;
    end process;

    dly_p: process(clk)
    begin
        if rising_edge(clk) then
            data_r <= data;
            data_r_1 <= data_r;
            data_r_2 <= data_r_1;
            data_r_3 <= data_r_2;
        end if;
    end process dly_p;


    i <= pipe_i_3(31 downto 16) when en = '1' else
         data_r_3;
    q <= pipe_q_3(31 downto 16) when en = '1' else
         (others => '0');

end Structural;

