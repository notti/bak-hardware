library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toggle is
port(
    toggle_in  : in  std_logic;
    toggle_out : out std_logic;
    clk_from   : in  std_logic;
    clk_to     : in  std_logic
);
end toggle;

architecture Structural of toggle is
    signal toggle_in_r  : std_logic := '0';
    signal in_level     : std_logic := '0';
    signal in_level_s   : std_logic := '0';
    signal in_level_sr  : std_logic := '0';
begin

in_level_p: process(clk_from)
begin
    if rising_edge(clk_from) then
        if toggle_in = '1' and toggle_in_r = '0' then
            in_level <= not in_level;
        end if;
        toggle_in_r <= toggle_in;
    end if;
end process in_level_p;

in_level_i: entity work.flag
port map(
    flag_in     => in_level,
    flag_out    => in_level_s,
    clk         => clk_to
);

in_level_r_p: process(clk_to)
begin
    if rising_edge(clk_to) then
        in_level_sr <= in_level_s;
    end if;
end process in_level_r_p;

toggle_out <= in_level_s xor in_level_sr;

end Structural;

