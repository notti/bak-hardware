-----------------------------------------------------------
-- Project			: 
-- File				: inbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: Input buffer
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

entity inbuf is
generic(
        CLK_FREQ            : integer := 100000000
);
port(
-- signals for gtx transciever
        refclk              : in  std_logic;
        rst                 : in  std_logic;
        rxn                 : in  std_logic_vector(3 downto 0);
        rxp                 : in  std_logic_vector(3 downto 0);
        txn                 : out std_logic_vector(3 downto 0);
        txp                 : out std_logic_vector(3 downto 0);

-- control signals
        input_select        : in std_logic_vector(1 downto 0);
        polarity            : in std_logic_vector(2 downto 0);
        descramble          : in std_logic_vector(2 downto 0);

        rxeqmix             : in std_logic_vector(5 downto 0);
        enable              : in std_logic_vector(2 downto 0);

-- status signals
        aligned             : out std_logic_vector(2 downto 0)
);
end inbuf;

architecture Structural of inbuf is
        signal clk_i        : std_logic;
        signal data_i       : t_data_array(2 downto 0);
        signal data_valid_i : std_logic_vector(2 downto 0);
        signal rst_i        : std_logic;

-- FIXME!
        signal rst_tmp              : std_logic; -- FIXME!
        signal input_select_tmp       : std_logic_vector(1 downto 0);
        signal polarity_tmp           : std_logic_vector(2 downto 0);
        signal descramble_tmp         : std_logic_vector(2 downto 0);
        signal rxeqmix_tmp            : t_cfg_array(2 downto 0);
        signal enable_tmp             : std_logic_vector(2 downto 0);
begin

reciever_i: entity inbuf.reciever
port map(
        refclk              => refclk,
        rst                 => rst_tmp, -- FIXME!
        rxn                 => rxn,
        rxp                 => rxp,
        txn                 => txn,
        txp                 => txp,
        clk                 => clk_i,
        data                => data_i,
        data_valid          => data_valid_i,
        rst_out             => rst_i,
        polarity            => polarity_tmp,
        descramble          => descramble_tmp,
        rxeqmix             =>  rxeqmix_tmp,
        enable              => enable_tmp
);

end Structural;

