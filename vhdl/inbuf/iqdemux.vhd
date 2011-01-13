-----------------------------------------------------------
-- Project			: 
-- File				: iqdemux.vhd
-- Author			: Gernot Vormayr
-- created			: Jan, 7th 2011
-- contents			: iq demux
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library inbuf;
        use inbuf.all;

library misc;
	use misc.procedures.all;

entity iqdemux is
port(
        clk                 : in  std_logic;
        data_in             : in  t_data;
        data_valid          : in  std_logic;
        datai_out           : out t_data;
        dataq_out           : out t_data;
        data_valid_out      : out std_logic
);
end iqdemux;

architecture Structural of iqdemux is
begin

    data_valid_out <= data_valid;
    dataq_out <= data_in;
    datai_out <= (others => '0');

end Structural;


