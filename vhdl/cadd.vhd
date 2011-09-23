----------------------------------------------------------
-- Project			: 
-- File				: cadd.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: overlap add
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity cadd is
port(
    clk     : in std_logic;
    a_re    : in std_logic_vector(15 downto 0);
    a_im    : in std_logic_vector(15 downto 0);
    b_re    : in std_logic_vector(15 downto 0);
    b_im    : in std_logic_vector(15 downto 0);
    c_re    : out std_logic_vector(15 downto 0);
    c_im    : out std_logic_vector(15 downto 0);
    ovfl    : out std_logic
);
end cadd;

architecture Structural of cadd is
begin

    add_p: process(clk)
    begin
        if clk = '1' and clk'event then
            c_re <= a_re + b_re;
            c_im <= a_im + b_im;
        end if;
    end process add_p;
    ovfl <= '0';

end Structural;
