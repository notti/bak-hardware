library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity flag is
generic(
    name    : string
);
port(
    flag_in  : in std_logic;
    flag_out : out std_logic;
    clk      : in std_logic
);
end flag;

architecture Structural of flag is
    signal s                        : std_logic;

    attribute TIG                   : string;
    attribute IOB                   : string;
    attribute ASYNC_REG             : string;
    attribute SHIFT_EXTRACT         : string;
    attribute HBLKNM                : string;

    attribute TIG of flag_in        : signal is "TRUE";
    attribute IOB of flag_in        : signal is "FALSE";
    attribute SHIFT_EXTRACT of s    : signal is "NO";
    attribute ASYNC_REG of fd0      : label is "TRUE";
    attribute HBLKNM of fd0         : label is name;
    attribute ASYNC_REG of fd1      : label is "TRUE";
    attribute HBLKNM of fd1         : label is name;
begin

    fd0: FD
    port map(
        C => clk,
        D => flag_in,
        Q => s
    );

    fd1: FD
    port map(
        C => clk,
        D => s,
        Q => flag_out
    );

end Structural;

