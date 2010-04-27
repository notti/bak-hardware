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
port(
-- signals for gtx transciever
        refclk              : in  std_logic;
        rst                 : in  std_logic;
        rxn                 : in  std_logic_vector(3 downto 0);
        rxp                 : in  std_logic_vector(3 downto 0);
        txn                 : out std_logic_vector(3 downto 0);
        txp                 : out std_logic_vector(3 downto 0);

-- control signals reciever
        polarity            : in std_logic_vector(2 downto 0);
        descramble          : in std_logic_vector(2 downto 0);
        rxeqmix             : in t_cfg_array(2 downto 0);
        data_valid          : out std_logic_vector(2 downto 0);
        enable              : in std_logic_vector(2 downto 0);

-- control signals inbuf
--        start_recv          : in std_logic;
--        start_conv          : in std_logic;
--        size                : in std_logic_vector(15 downto 0);
        input_select        : in std_logic_vector(1 downto 0);

--        cpu_req             : in std_logic;
--        cpu_ack             : out std_logic;
--        cpu_addr            : in std_logic_vector(15 downto 0);
--        cpu_data2mem        : in std_logic_vector(31 downto 0);
--        cpu_mem2data        : out std_logic_vector(31 downto 0);
--        cpu_we              : in std_logic;
--        cpu_re              : in std_logic;
--		cpu_clk				: in std_logic;

		data_clk		    : out std_logic
);
end inbuf;

architecture Structural of inbuf is
        signal clk_i        : std_logic;
        signal data_i       : t_data_array(2 downto 0);
begin

reciever_i: entity inbuf.reciever
port map(
        refclk              => refclk,
        rst                 => rst,
        rxn                 => rxn,
        rxp                 => rxp,
        txn                 => txn,
        txp                 => txp,
        clk                 => clk_i,
        data                => data_i,
        polarity            => polarity,
        descramble          => descramble,
        rxeqmix             => rxeqmix,
        data_valid          => data_valid,
        enable              => enable
);

data_clk <= clk_i;

end Structural;

