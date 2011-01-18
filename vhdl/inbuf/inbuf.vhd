-----------------------------------------------------------
-- Project			: 
-- File				: inbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Input buffer
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;

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
		rec_stream_valid    : out std_logic;
        rec_clk_out         : out std_logic;

-- control signals inbuf
        inbuf_depth         : in std_logic_vector(15 downto 0);
        inbuf_width         : in std_logic_vector(1 downto 0);

        inbuf_arm           : in std_logic;
        inbuf_trigger       : in std_logic;
        inbuf_done          : out std_logic;
        inbuf_frame_clk     : out std_logic;
        inbuf_rst           : in std_logic;
        inbuf_locked        : out std_logic;

-- data
        clk_bus             : in std_logic;
        inbuf_read_req      : in std_logic;
        inbuf_read_ack      : out std_logic;
        inbuf_clk_data      : in std_logic;
		inbuf_we 			: in std_logic;
        inbuf_addr_data     : in std_logic_vector(15 downto 0);
        inbuf_data_out     : out std_logic_vector(15 downto 0);
        inbuf_data_in      : in  std_logic_vector(15 downto 0)
);
end inbuf;

architecture Structural of inbuf is
        signal clk_i            : std_logic;
        signal rst_out_i        : std_logic;
        signal rec_data_i       : t_data_array(2 downto 0);
        signal data_i           : t_data;
        signal rec_data_valid_i : std_logic_vector(2 downto 0);
        signal stream_valid_i   : std_logic;
        signal rst_i            : std_logic;
begin

    rst_i <= rst_out_i or inbuf_rst;

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
        data_valid_out      => stream_valid_i,
        which               => rec_input_select
);

average_mem_i: entity inbuf.average_mem
port map(
        clk                     => clk_i,
        width                   => inbuf_width,
        depth                   => inbuf_depth,
        arm                     => inbuf_arm,
        done                    => inbuf_done,
        trigger                 => inbuf_trigger,
        frame_clk               => inbuf_frame_clk,
        locked                  => inbuf_locked,
        rst                     => rst_i,
        data                    => data_i,
        stream_valid            => stream_valid_i,
        clk_bus                 => clk_bus,
        read_req                => inbuf_read_req,
        read_ack                => inbuf_read_ack,
        clk_data                => inbuf_clk_data,
        addr                    => inbuf_addr_data,
		we 						=> inbuf_we,
        dout                    => inbuf_data_out,
		din 				    => inbuf_data_in
);

    rec_data_valid <= rec_data_valid_i;
    rec_clk_out <= clk_i;
	rec_stream_valid <= stream_valid_i;

end Structural;

