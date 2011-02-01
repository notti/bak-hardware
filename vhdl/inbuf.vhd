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

library work;
use work.procedures.all;

entity inbuf is
port(
-- signals for gtx transciever
    refclkn             : in  std_logic;
    refclkp             : in  std_logic;
    rst                 : in  std_logic;
    rxn                 : in  std_logic_vector(3 downto 0);
    rxp                 : in  std_logic_vector(3 downto 0);
    txn                 : out std_logic_vector(3 downto 0);
    txp                 : out std_logic_vector(3 downto 0);

-- control signals reciever
    rec_polarity        : in  std_logic_vector(2 downto 0);
    rec_descramble      : in  std_logic_vector(2 downto 0);
    rec_rxeqmix         : in  t_cfg_array(2 downto 0);
    rec_data_valid      : out std_logic_vector(2 downto 0);
    rec_enable          : in  std_logic_vector(2 downto 0);
    rec_input_select    : in  std_logic_vector(1 downto 0);
    rec_stream_valid    : out std_logic;
    sample_clk          : out std_logic;

-- control signals inbuf
    depth               : in  std_logic_vector(15 downto 0);
    width               : in  std_logic_vector(1 downto 0);

    arm_req             : in  std_logic;
    arm_ack             : out std_logic;
    trigger             : in  std_logic;
    avg_done            : out std_logic;
    frame_clk           : out std_logic;
    rst_req             : in  std_logic;
    rst_ack             : out std_logic;
    locked              : out std_logic;

    clk_data            : out std_logic;

-- data
    mem_req             : in  std_logic;
    mem_ack             : out std_logic;
    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    bus2fpga_rnw        : in  std_logic;
    bus2fpga_cs         : in  std_logic_vector(3 downto 0);
    bus2fpga_be         : in  std_logic_vector(3 downto 0);
    bus2fpga_data       : in  std_logic_vector(31 downto 0);
    bus2fpga_addr       : in  std_logic_vector(15 downto 0);
    bus2fpga_reset      : in  std_logic;
    bus2fpga_clk        : in  std_logic
);
end inbuf;

architecture Structural of inbuf is
    signal clk_i               : std_logic;
    signal rst_out_i           : std_logic;
    signal rec_data_i          : t_data_array(2 downto 0);
    signal data_i              : t_data;
    signal rec_data_valid_i    : std_logic_vector(2 downto 0);
    signal stream_valid_i      : std_logic;
    signal rst_i               : std_logic;
    signal refclk_unbuffered   : std_logic;
    signal refclk              : std_logic;
    signal rec_polarity_synced : std_logic_vector(2 downto 0);
    signal rec_enable_synced   : std_logic_vector(2 downto 0);
    signal mem_req_synced      : std_logic;
    signal arm                 : std_logic;
    signal inbuf_rst           : std_logic;
    signal mem_read_cycle      : std_logic_vector(2 downto 0);
    signal mem_write_cycle     : std_logic_vector(4 downto 0);
    signal mem_low_word_r      : std_logic_vector(15 downto 0);
    signal mem_high_word_r     : std_logic_vector(15 downto 0);
    signal inbuf_addr_data     : std_logic_vector(15 downto 0);
    signal inbuf_we            : std_logic;
    signal inbuf_data_out      : std_logic_vector(15 downto 0);
    signal inbuf_data_in       : std_logic_vector(15 downto 0);
begin

    inbuf_refclkbufds_i : IBUFDS
    port map
    (
        O                   => refclk_unbuffered,
        I                   => refclkn,
        IB                  => refclkp
    );
    refclk_bufg_i : BUFG
    port map
    (
        I                   =>      refclk_unbuffered,
        O                   =>      refclk
    );

    rst_i <= rst_out_i or inbuf_rst;

    sync_gen: for i in 0 to 2 generate
        sync_enable_i: entity work.flag
        port map(
            flag_in      => rec_enable(i),
            flag_out     => rec_enable_synced(i),
            clk          => clk_i
        );
        sync_polarity_i: entity work.flag
        port map(
            flag_in      => rec_polarity(i),
            flag_out     => rec_polarity_synced(i),
            clk          => clk_i
        );
    end generate;
    sync_arm_i: entity work.flag
    port map(
        flag_in      => arm_req,
        flag_out     => arm,
        clk          => clk_i
    );
    arm_p: process(clk_i)
    begin
        if rising_edge(clk_i) then
            arm_ack <= arm;
        end if;
    end process;
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst_req,
        flag_out     => inbuf_rst,
        clk          => clk_i
    );
    rst_p: process(clk_i)
    begin
        if rising_edge(clk_i) then
            rst_ack <= inbuf_rst;
        end if;
    end process;
    sync_mem_req_i: entity work.flag
    port map(
        flag_in      => mem_req,
        flag_out     => mem_req_synced,
        clk          => clk_i
    );


    reciever_i: entity work.reciever
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

    datamux_i: entity work.datamux
    port map(
        clk                 => clk_i,
        rst                 => inbuf_rst,
        data_in             => rec_data_i,
        data_valid_in       => rec_data_valid_i,
        data_out            => data_i,
        data_valid_out      => stream_valid_i,
        which               => rec_input_select
    );

	fpga2bus_error <= '0';

    --------------------------------------
    -- cycle 0: read 0
    -- cycle 1: read 1  data 0
    -- cycle 2:         data 1
    mem_read_cycle(0) <= '1' when bus2fpga_cs = "0001" and bus2fpga_rnw = '1' else '0';
	mem_read_cycle_p: process(bus2fpga_clk, bus2fpga_reset, mem_read_cycle, bus2fpga_cs)
	begin
        if bus2fpga_reset = '1' or not (bus2fpga_cs = "0001") then
            mem_read_cycle(2 downto 1) <= (others => '0');
        elsif rising_edge(bus2fpga_clk) then
            mem_read_cycle(2 downto 1) <= mem_read_cycle(1 downto 0);
		end if;
	end process mem_read_cycle_p;

    fpga2bus_rdack <= mem_read_cycle(2) when bus2fpga_cs = "0001" and bus2fpga_rnw = '1' else '0';

    mem_low_word_p: process(bus2fpga_clk, mem_read_cycle, mem_write_cycle, inbuf_data_out)
    begin
        if rising_edge(bus2fpga_clk) then
            if mem_read_cycle = "011" or mem_write_cycle = "00011" then
                mem_low_word_r <= inbuf_data_out;
            end if;
        end if;
    end process mem_low_word_p;

    inbuf_addr_data(15 downto 1) <= bus2fpga_addr(14 downto 0) when bus2fpga_cs = "0001" else
                                    (others => '0');
	inbuf_addr_data(0) <= '1' when bus2fpga_cs = "0001" and (mem_read_cycle = "011" or mem_write_cycle = "00011" or mem_write_cycle = "01111") else
					      '0';

	fpga2bus_data <= (inbuf_data_out & mem_low_word_r) when bus2fpga_cs = "0001" and mem_read_cycle = "111" else
					 (others => '0');

    ---------------------------------------------------
    -- cycle 0: read 0
    -- cycle 1: read 1 data 0
    -- cycle 2         data 1
    -- cycle 3: wr 1
    -- cycle 4: wr 0
    mem_write_cycle(0) <= '1' when bus2fpga_cs = "0001" and bus2fpga_rnw = '0' else '0';
	mem_write_cycle_p: process(bus2fpga_clk, bus2fpga_reset, mem_write_cycle, bus2fpga_cs)
	begin
        if bus2fpga_reset = '1' or not (bus2fpga_cs = "0001") then
            mem_write_cycle(4 downto 1) <= (others => '0');
        elsif rising_edge(bus2fpga_clk) then
            mem_write_cycle(4 downto 1) <= mem_write_cycle(3 downto 0);
		end if;
	end process mem_write_cycle_p;
    mem_high_word_p: process(bus2fpga_clk, mem_write_cycle, inbuf_data_out)
    begin
        if rising_edge(bus2fpga_clk) then
            if mem_write_cycle = "00111" then
                mem_high_word_r <= inbuf_data_out;
            end if;
        end if;
    end process mem_high_word_p;

	fpga2bus_wrack <= mem_write_cycle(4) when bus2fpga_cs = "0001" else '0';

    inbuf_we <= mem_write_cycle(3) or mem_write_cycle(4) when bus2fpga_cs = "0001" else '0';
    inbuf_data_in(7 downto 0)  <= bus2fpga_data(7 downto 0) when bus2fpga_be(0) = '1' and mem_write_cycle = "11111" else
                                  bus2fpga_data(23 downto 16) when bus2fpga_be(2) = '1' and mem_write_cycle = "01111" else
                                  mem_low_word_r(7 downto 0) when bus2fpga_be(0) = '0' and mem_write_cycle = "11111" else
                                  mem_high_word_r(7 downto 0) when bus2fpga_be(2) = '0' and mem_write_cycle = "01111" else
                                  (others => '0');
    inbuf_data_in(15 downto 8) <= bus2fpga_data(15 downto 8) when bus2fpga_be(1) = '1' and mem_write_cycle = "11111" else
                                  bus2fpga_data(31 downto 24) when bus2fpga_be(3) = '1' and mem_write_cycle = "01111" else
                                  mem_low_word_r(15 downto 8) when bus2fpga_be(1) = '0' and mem_write_cycle = "11111" else
                                  mem_high_word_r(15 downto 8) when bus2fpga_be(3) = '0' and mem_write_cycle = "01111" else
                                  (others => '0');

    average_mem_i: entity work.average_mem
    port map(
        clk                     => clk_i,
        width                   => width,
        depth                   => depth,
        arm                     => arm,
        done                    => avg_done,
        trigger                 => trigger,
        frame_clk               => frame_clk,
        locked                  => locked,
        rst                     => rst_i,
        data                    => data_i,
        stream_valid            => stream_valid_i,
        rst_arb                 => inbuf_rst,
        read_req                => mem_req_synced,
        read_ack                => mem_ack,
        clk_data                => bus2fpga_clk,
        addr                    => inbuf_addr_data,
		we 						=> inbuf_we,
        dout                    => inbuf_data_out,
		din 				    => inbuf_data_in
    );

    rec_data_valid <= rec_data_valid_i;
    sample_clk <= clk_i;
	rec_stream_valid <= stream_valid_i;
    clk_data <= refclk;

end Structural;

