-----------------------------------------------------------
-- Project			: 
-- File				: value.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by	    : 
-- last mod. on	    : 
-- contents			: 
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

entity value is
generic(
    C_WIDTH : integer
       );
port(
    value_in  : in std_logic_vector(C_WIDTH-1 downto 0);
    value_out : out std_logic_vector(C_WIDTH-1 downto 0);
    clk      : in std_logic
);
end value;

architecture Structural of value is
    type sreg_arr   is array(integer range<>) of std_logic_vector(C_WIDTH-1 downto 0);
    signal sreg                     : sreg_arr(1 downto 0);

    attribute TIG                   : string;
    attribute ASYNC_REG             : string;
    attribute SHIFT_EXTRACT         : string;
    attribute HBLKNM                : string;

    attribute TIG of value_in        : signal is "TRUE";
    attribute ASYNC_REG of sreg     : signal is "TRUE";
    attribute SHIFT_EXTRACT of sreg : signal is "NO";
    attribute HBLKNM of sreg        : signal is "sync_reg";
begin

    sync: process(clk)
    begin
        if clk'event and clk='1' then
            value_out <= sreg(1);
            sreg <= sreg(0) & value_in;
        end if;
    end process sync;

end Structural;

