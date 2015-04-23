library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity value is
port(
    value_in  : in  std_logic_vector;
    value_out : out std_logic_vector;
    value_wr  : in  std_logic;
    clk_from  : in  std_logic;
    clk_to    : in  std_logic
);
end value;

architecture Structural of value is
    signal req              : std_logic;
begin

req_t: entity work.toggle
port map(
    toggle_in   => value_wr,
    toggle_out  => req,
    clk_from    => clk_from,
    clk_to      => clk_to
);

value_out_reg: process(clk_to)
begin
    if rising_edge(clk_to) then
        if req = '1' then
            value_out <= value_in;
        end if;
    end if;
end process value_out_reg;

end Structural;

