-----------------------------------------------------------
-- Project			: 
-- File				: cpumem.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by	    : 
-- last mod. on	    : 
-- contents			: 
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library proc;
        use proc.all;

library misc;
	use misc.procedures.all;

entity cpumem is
port(
    inbuf_clk_data               : out std_logic;
    inbuf_addr_data              : out std_logic_vector(15 downto 0);
    inbuf_web                    : out std_logic;
    inbuf_datai_out              : in std_logic_vector(15 downto 0);
    inbuf_dataq_out              : in std_logic_vector(15 downto 0);
    inbuf_datai_in               : out std_logic_vector(15 downto 0);
    inbuf_dataq_in               : out std_logic_vector(15 downto 0);

    ----- proc interface
    bus_error                    : out std_logic;
    bus_be                       : in std_logic_vector(3 downto 0);
    bus_reset                    : in std_logic;
    bus_clk                      : in std_logic;
    mem_bus2ip_data              : in std_logic_vector(31 downto 0);
    mem_ip2bus_data              : out std_logic_vector(31 downto 0);
    mem_address                  : in std_logic_vector(15 downto 0);
    mem_write_ack                : out std_logic;
    mem_read_ack                 : out std_logic;
    mem_read_enable              : in std_logic;
    mem_select                   : in std_logic_vector(2 downto 0)
);
end cpumem;

architecture Structural of cpumem is
	signal mem_read_ack_dly_i : std_logic;
begin
	bus_error <= '0';

	inbuf_addr_data <= mem_address when mem_select = "001" else
					   (others => '0');
	inbuf_web <= not mem_read_enable when mem_select = "001" else
				 '0';
	inbuf_clk_data <= bus_clk;
	inbuf_datai_in <= mem_bus2ip_data(15 downto 0);
	inbuf_dataq_in <= mem_bus2ip_data(31 downto 16);

	mem_ip2bus_data <= (inbuf_dataq_out & inbuf_datai_out) when mem_select = "001" and mem_read_enable = '0' else
					   (others => '0');

	mem_read_ack <= mem_read_ack_dly_i;
	mem_write_ack <= '1' when mem_select = "001" and mem_read_enable = '1' else
					 '0';
	mem_read_ack_dly_p: process(bus_clk)
	begin
		if bus_clk'event and bus_clk = '1' then
			if bus_reset = '1' then
				mem_read_ack_dly_i <= '0';
			else
				mem_read_ack_dly_i <= mem_read_enable;
			end if;
		end if;
	end process mem_read_ack_dly_p;

end Structural;

