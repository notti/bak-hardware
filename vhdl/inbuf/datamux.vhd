-----------------------------------------------------------
-- Project			: 
-- File				: datamux.vhd
-- Author			: Gernot Vormayr
-- created			: Jan, 7th 2011
-- contents			: Datamux for input buffer
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

entity datamux is
port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        data_in             : in  t_data_array(2 downto 0);
        data_valid_in       : in  std_logic_vector(2 downto 0);
        data_out            : out t_data;
        data_valid_out      : out std_logic;
        which               : in  std_logic_vector(1 downto 0)
);
end datamux;

architecture Structural of datamux is
        signal which_dly          : std_logic_vector(1 downto 0);
        signal which_r            : std_logic_vector(1 downto 0);
        signal rst_r            : std_logic;
        signal data_valid_out_i : std_logic;
begin

rst_r_p: process(clk, rst)
begin
    if clk'event and clk='1' then
        rst_r <= rst;
    end if;
end process rst_r_p;

which_r_p: process(clk, which, rst, rst_r)
begin
    if clk'event and clk='1' then
        if rst = '1' and rst_r = '0' then
            which_r <= which;
        end if;
    end if;
end process which_r_p;

which_dly_p: process(clk, which_r)
begin
    if clk'event and clk='1' then
        which_dly <= which_r;
    end if;
end process which_dly_p;

data_valid_p: process(which, data_valid_in)
begin
    case which is
        when "00" => data_valid_out_i <= data_valid_in(0);
        when "01" => data_valid_out_i <= data_valid_in(1);
        when "10" => data_valid_out_i <= data_valid_in(2);
        when others => data_valid_out_i <= '0';
    end case;
end process;

data_valid_out <= data_valid_out_i and not or_many(which_dly xor which_r);

data_out_p: process(which, data_in)
begin
    case which is
        when "00" => data_out <= data_in(0);
        when "01" => data_out <= data_in(1);
        when "10" => data_out <= data_in(2);
        when others => data_out <= (others => '0');
    end case;
end process;

end Structural;


