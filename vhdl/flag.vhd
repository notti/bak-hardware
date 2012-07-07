library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flag is
port(
    flag_in  : in std_logic;
    flag_out : out std_logic;
    clk      : in std_logic
);
end flag;

architecture Structural of flag is
    signal sreg                     : std_logic_vector(1 downto 0);

    attribute TIG                   : string;
    attribute IOB                   : string;
    attribute ASYNC_REG             : string;
    attribute SHIFT_EXTRACT         : string;
--    attribute HBLKNM                : string;

    attribute TIG of flag_in        : signal is "TRUE";
    attribute IOB of flag_in        : signal is "FALSE";
    attribute ASYNC_REG of sreg     : signal is "TRUE";
    attribute SHIFT_EXTRACT of sreg : signal is "NO";
--    attribute HBLKNM of sreg        : signal is "sync_reg";
begin

sync: process(clk)
begin
    if rising_edge(clk) then
        sreg <= sreg(0) & flag_in;
    end if;
end process sync;

flag_out <= sreg(1);

end Structural;

