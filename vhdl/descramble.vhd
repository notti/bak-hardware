-----------------------------------------------------------
-- Project			: 
-- File				: descramble.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: descrambler for adc LTC2271
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity descramble is
Port(
	clk                 : in  std_logic;
	data_in             : in  std_logic_vector(15 downto 0);
	data_out            : out std_logic_vector(15 downto 0)
);
end descramble;

architecture Structural of descramble is
	signal data_in_r    : std_logic_vector(14 downto 0);
begin

	data_in_r_process: process(clk, data_in)
	begin
		if rising_edge(clk) then
			data_in_r <= data_in(14 downto 0);
		end if;
	end process;

	xnors: for i in 0 to 15 generate
		bit0: if i = 0 generate
			data_out(i) <= data_in(i) xnor (data_in(15) xnor data_in(14));
		end generate bit0;
		
		bit1: if i = 1 generate
			data_out(i) <= data_in(i) xnor (data_in(15) xnor data_in_r(i-1));
		end generate bit1;
		
		bitn: if i>1 generate
			data_out(i) <= data_in(i) xnor (data_in_r(i-1) xnor data_in_r(i-2));
		end generate bitn;
	end generate xnors;

end Structural;

