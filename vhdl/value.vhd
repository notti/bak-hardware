library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity value is
port(
    value_in  : in  std_logic_vector;
    value_out : out std_logic_vector(value_in'range);
    value_wr  : in  std_logic;
    clk_from  : in  std_logic;
    clk_to    : in  std_logic
);
end value;

architecture Structural of value is
    signal value_wr_r       : std_logic;
    signal value_wr_one     : std_logic;
    signal value_in_reg     : std_logic_vector(value_in'range);
    signal req              : std_logic;
begin

value_wr_r_p: process(clk_from)
begin
    if rising_edge(clk_from) then
        value_wr_r <= value_wr;
    end if;
end process value_wr_r_p;

value_wr_one <= value_wr_r and not value_wr;

value_in_reg_p: process(clk_from)
begin
    if rising_edge(clk_from) then
        if value_wr = '1' then
            value_in_reg <= value_in;
        end if;
    end if;
end process value_in_reg_p;

req_t: entity work.toggle
port map(
    toggle_in   => value_wr_one,
    toggle_out  => req,
    clk_from    => clk_from,
    clk_to      => clk_to
);

value_out_reg_p: process(clk_to)
begin
    if rising_edge(clk_to) then
        if req = '1' then
            value_out <= value_in_reg;
        end if;
    end if;
end process value_in_reg_p;

end Structural;

