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

library proc;
    use proc.all;

entity value is
generic(
    C_WIDTH : integer
);
port(
    value_in  : in std_logic_vector(C_WIDTH-1 downto 0);
    value_out : out std_logic_vector(C_WIDTH-1 downto 0);
    clk       : in std_logic
);
end value;

architecture Structural of value is
begin
    flags: for i in 0 to C_WIDTH-1 generate
    begin
        sync_i: entity flag
        port map(
            flag_in  => value_in(i),
            flag_out => value_out(i),
            clk      => clk
        );
    end generate flags;

end Structural;

