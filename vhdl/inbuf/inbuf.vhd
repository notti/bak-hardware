-----------------------------------------------------------
-- Project			: 
-- File				: inbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
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
        rec_polarity        : in std_logic_vector(2 downto 0);
        rec_descramble      : in std_logic_vector(2 downto 0);
        rec_rxeqmix         : in t_cfg_array(2 downto 0);
        rec_data_valid      : out std_logic_vector(2 downto 0);
        rec_enable          : in std_logic_vector(2 downto 0);
        rec_input_select    : in std_logic_vector(1 downto 0);
        rec_clk_out         : out std_logic;

-- control signals inbuf
        inbuf_depth         : in std_logic_vector(15 downto 0);
        inbuf_width         : in std_logic_vector(1 downto 0);

        inbuf_start         : in std_logic;
        inbuf_done          : out std_logic;

-- data
        inbuf_clk_data      : in std_logic;
        inbuf_addr_data     : in std_logic_vector(15 downto 0);
        inbuf_datai         : out std_logic_vector(15 downto 0);
        inbuf_dataq         : out std_logic_vector(15 downto 0)
);
end inbuf;

architecture Structural of inbuf is
	COMPONENT dcm_inbuf
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLK0_OUT : OUT std_logic;
		CLK2X_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;

        signal clk_i            : std_logic;
        signal rst_out_i        : std_logic;
        signal rec_data_i       : t_data_array(2 downto 0);
        signal data_i           : t_data;
        signal datai_i          : std_logic_vector(15 downto 0);
        signal dataq_i          : std_logic_vector(15 downto 0);
        signal locked_i         : std_logic;
        signal clk2x_i          : std_logic;
        signal rec_data_valid_i : std_logic_vector(2 downto 0);
        signal data_valid_i     : std_logic;
        signal iqdata_valid_i   : std_logic;
        signal iqdata_valid_locked_i : std_logic;
        signal pos_i            : std_logic_vector(15 downto 0);
        signal sample_i         : std_logic;
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
        rst_out             => rst_out_i,
        data                => rec_data_i,
        polarity            => rec_polarity,
        descramble          => rec_descramble,
        rxeqmix             => rec_rxeqmix,
        data_valid          => rec_data_valid_i,
        enable              => rec_enable
);

datamux_i: entity inbuf.datamux
port map(
        clk                 => clk_i,
        data_in             => rec_data_i,
        data_valid_in       => rec_data_valid_i,
        data_out            => data_i,
        data_valid_out      => data_valid_i,
        which               => rec_input_select
);

iqdemux_i: entity inbuf.iqdemux
port map(
        clk                 => clk_i,
        data_in             => data_i,
        data_valid          => data_valid_i,
        datai_out           => datai_i,
        dataq_out           => dataq_i,
        data_valid_out      => iqdata_valid_i
);

ctrl_i: entity inbuf.ctrl
port map(
        clk                 => clk_i,
        rst                 => rst,
        depth               => inbuf_depth,
        width               => inbuf_width,
        data_valid          => iqdata_valid_locked_i,
        start               => inbuf_start,
        sample              => sample_i,
        pos                 => pos_i,
        done                => inbuf_done
);

Inst_dcm: dcm_inbuf PORT MAP(
    CLKIN_IN => clk_i,
    RST_IN => rst_out_i,
    CLK0_OUT => open,
    CLK2X_OUT => clk2x_i,
    LOCKED_OUT => locked_i
);

    iqdata_valid_locked_i <= locked_i and iqdata_valid_i;

average_mem_i: entity inbuf.average_mem
port map(
        clk                     => clk_i,
        clk2x                   => clk2x_i,
        pos                     => pos_i,
        width                   => inbuf_width,
        sample                  => sample_i,
        datai                   => datai_i,
        dataq                   => dataq_i,
        clk_data                => inbuf_clk_data,
        addr                    => inbuf_addr_data,
        douti                   => inbuf_datai,
        doutq                   => inbuf_dataq
);

    rec_data_valid <= rec_data_valid_i;
    rec_clk_out <= clk_i;

end Structural;

