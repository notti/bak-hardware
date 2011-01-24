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
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
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
    inbuf_we                     : out std_logic;
    inbuf_data_out               : in std_logic_vector(15 downto 0);
    inbuf_data_in                : out std_logic_vector(15 downto 0);

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
	signal mem_read_cycle    : std_logic_vector(2 downto 0);
	signal mem_write_cycle   : std_logic_vector(4 downto 0);
	signal mem_low_word_r    : std_logic_vector(15 downto 0);
	signal mem_high_word_r   : std_logic_vector(15 downto 0);
begin
	bus_error <= '0';

    --------------------------------------
    -- cycle 0: read 0
    -- cycle 1: read 1  data 0
    -- cycle 2:         data 1
    mem_read_cycle(0) <= mem_read_enable;
	mem_read_cycle_p: process(bus_clk, bus_reset, mem_read_cycle, mem_select)
	begin
        if bus_reset = '1' or mem_select = "000" then
            mem_read_cycle(2 downto 1) <= (others => '0');
        elsif bus_clk'event and bus_clk = '1' then
            mem_read_cycle(2 downto 1) <= mem_read_cycle(1 downto 0);
		end if;
	end process mem_read_cycle_p;

    mem_read_ack <= mem_read_cycle(2) when mem_select = "100" else
                    '0';

    mem_low_word_p: process(bus_clk)
    begin
        if bus_clk'event and bus_clk = '1' then
            if mem_read_cycle = "011" or mem_write_cycle = "00011" then
                mem_low_word_r <= inbuf_data_out;
            end if;
        end if;
    end process mem_low_word_p;

    inbuf_addr_data(15 downto 1) <= mem_address(14 downto 0) when mem_select = "100" else
                                    (others => '0');
	inbuf_addr_data(0) <= '1' when mem_select = "100" and (mem_read_cycle = "011" or mem_write_cycle = "00011" or mem_write_cycle = "01111") else
					      '0';

	mem_ip2bus_data <= (inbuf_data_out & mem_low_word_r) when mem_select = "100" and mem_read_cycle = "111" else
					   (others => '0');

    ---------------------------------------------------
    -- cycle 0: read 0
    -- cycle 1: read 1 data 0
    -- cycle 2         data 1
    -- cycle 3: wr 1
    -- cycle 4: wr 0
    mem_write_cycle(0) <= (not mem_read_enable) when mem_select = "100" else
                          '0';
	mem_write_cycle_p: process(bus_clk, bus_reset, mem_write_cycle, mem_select)
	begin
        if bus_reset = '1' or mem_select = "000" then
            mem_write_cycle(4 downto 1) <= (others => '0');
        elsif bus_clk'event and bus_clk = '1' then
            mem_write_cycle(4 downto 1) <= mem_write_cycle(3 downto 0);
		end if;
	end process mem_write_cycle_p;
    mem_high_word_p: process(bus_clk)
    begin
        if bus_clk'event and bus_clk = '1' then
            if mem_write_cycle = "00111" then
                mem_high_word_r <= inbuf_data_out;
            end if;
        end if;
    end process mem_high_word_p;

	mem_write_ack <= mem_write_cycle(4) when mem_select = "100" else
					 '0';

	inbuf_we <= mem_write_cycle(3) or mem_write_cycle(4) when mem_select = "100" else
				 '0';
    inbuf_data_in(7 downto 0)  <= mem_bus2ip_data(7 downto 0) when bus_be(0) = '1' and mem_write_cycle = "11111" else
                                  mem_bus2ip_data(23 downto 16) when bus_be(2) = '1' and mem_write_cycle = "01111" else
                                  mem_low_word_r(7 downto 0) when bus_be(0) = '0' and mem_write_cycle = "11111" else
                                  mem_high_word_r(7 downto 0) when bus_be(2) = '0' and mem_write_cycle = "01111" else
                                  (others => '0');
    inbuf_data_in(15 downto 8) <= mem_bus2ip_data(15 downto 8) when bus_be(1) = '1' and mem_write_cycle = "11111" else
                                  mem_bus2ip_data(31 downto 24) when bus_be(3) = '1' and mem_write_cycle = "01111" else
                                  mem_low_word_r(15 downto 8) when bus_be(1) = '0' and mem_write_cycle = "11111" else
                                  mem_high_word_r(15 downto 8) when bus_be(3) = '0' and mem_write_cycle = "01111" else
                                  (others => '0');
	inbuf_clk_data <= bus_clk;

end Structural;

