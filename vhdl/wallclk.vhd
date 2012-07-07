library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity wallclk is
port(
    clk        : in std_logic;
    rst        : in std_logic;
    n          : in std_logic_vector(15 downto 0);
    wave_index : out std_logic_vector(3 downto 0);
    frame_clk  : out std_logic;
    frame_trg  : out std_logic;    
    frame_index : out std_logic_vector(15 downto 0);
);
end wallclk;

architecture Structural of wallclk is
    signal cnt_wave: std_logic_vector(3 downto 0) := X"0";
    signal cnt_frame: std_logic_vector(15 downto 0) := X"0000";
    signal n_i : std_logic_vector(15 downto 0);
begin
    wave_index <= cnt_wave;
    frame_index <= cnt_frame;
    frame_trg <= '1' when cnt_frame = n_i else
                 '0';
    frame_clk <= '1' when cnt_frame = X"0000" else
                 '0';

    cnt_p: process(clk, rst)
    begin
        if clk = '1' and clk'event then
            if rst = '1' then
                cnt_wave <= X"0";
                cnt_frame <= X"0000";
                n_i <= n - 1;
            else
                if cnt_wave = X"9" then
                    cnt_wave <= (others => '0');
                else
                    cnt_wave <= cnt_wave + 1;
                end if;
                if cnt_frame = n_i then
                    cnt_frame <= (others => '0');
                else
                    cnt_frame <= cnt_frame + 1;
                end if;
            end if;
        end if;
    end process cnt_p;

end Structural;

