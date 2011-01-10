-----------------------------------------------------------
-- Project			: 
-- File				: status_reg.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: 
-----------------------------------------------------------

-----------------------------------------------------------
-- library includes
-----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package types is
	
	constant register_width : natural := 32;

	subtype t_register is std_logic_vector(reigster_width-1 downto 0);

end package;

package body types is


end types;

