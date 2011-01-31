-----------------------------------------------------------
-- Project			: 
-- File				: flag.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by	    : 
-- last mod. on	    : 
-- contents			: 
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library proc;

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
    attribute ASYNC_REG             : string;
    attribute SHIFT_EXTRACT         : string;
    attribute HBLKNM                : string;

    attribute TIG of flag_in        : signal is "TRUE";
    attribute ASYNC_REG of sreg     : signal is "TRUE";
    attribute SHIFT_EXTRACT of sreg : signal is "NO";
    attribute HBLKNM of sreg(0)        : signal is "sync_reg";
    attribute HBLKNM of sreg(1)        : signal is "sync_reg";
begin

    sync: process(clk)
    begin
        if clk'event and clk='1' then
            flag_out <= sreg(1);
            sreg <= sreg(0) & flag_in;
        end if;
    end process sync;

end Structural;

