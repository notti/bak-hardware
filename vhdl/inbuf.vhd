-----------------------------------------------------------
-- Project			: 
-- File				: inbuf.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: Input buffer
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity inbuf is
port(
-- signals for gtx transciever
    refclk              : in  std_logic;
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
    rec_input_select_req : in std_logic;
    rec_stream_valid    : out std_logic;
    sample_clk          : out std_logic;
    pll_locked          : out std_logic;

-- control signals inbuf
    depth               : in  std_logic_vector(15 downto 0);
    depth_req           : in  std_logic;
    width               : in  std_logic_vector(1 downto 0);
    width_req           : in  std_logic;

    arm                 : in  std_logic;
    trigger             : in  std_logic;
    avg_done            : out std_logic;
    frame_clk           : out std_logic;
    rst                 : in  std_logic;
    locked              : out std_logic;

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
    signal rec_polarity_synced : std_logic_vector(2 downto 0);
    signal rec_enable_synced   : std_logic_vector(2 downto 0);
    signal mem_req_synced      : std_logic;
    signal arm_synced          : std_logic;
    signal arm_synced_dly      : std_logic;
    signal arm_toggle           : std_logic;
    signal inbuf_rst           : std_logic;
    signal rst_synced          : std_logic;
    signal rst_synced_dly      : std_logic;
    signal rst_toggle           : std_logic;
    signal select_synced       : std_logic;
    signal select_synced_dly   : std_logic;
    signal select_toggle        : std_logic;
    signal depth_synced       : std_logic;
    signal depth_synced_dly   : std_logic;
    signal depth_toggle        : std_logic;
    signal width_synced       : std_logic;
    signal width_synced_dly   : std_logic;
    signal width_toggle        : std_logic;
    signal select_r            : std_logic_vector(1 downto 0);
    signal width_r             : std_logic_vector(1 downto 0);
    signal depth_1             : std_logic_vector(15 downto 0);
    signal mem_read_cycle      : std_logic_vector(3 downto 0);
    signal mem_write_cycle     : std_logic_vector(4 downto 0);
    signal mem_low_word_r      : std_logic_vector(15 downto 0);
    signal mem_high_word_r     : std_logic_vector(15 downto 0);
    signal inbuf_addr_data     : std_logic_vector(15 downto 0);
    signal inbuf_we            : std_logic;
    signal inbuf_data_out      : std_logic_vector(15 downto 0);
    signal inbuf_data_in       : std_logic_vector(15 downto 0);
begin



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
        flag_in      => arm,
        flag_out     => arm_synced,
        clk          => clk_i
    );
    arm_dly: process(clk_i)
    begin
        if rising_edge(clk_i) then
            arm_synced_dly <= arm_synced;
        end if;
    end process;
    arm_toggle <= arm_synced_dly xor arm_synced;
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst,
        flag_out     => rst_synced,
        clk          => clk_i
    );
    rst_dly: process(clk_i)
    begin
        if rising_edge(clk_i) then
            rst_synced_dly <= rst_synced;
        end if;
    end process;
    rst_toggle <= rst_synced_dly xor rst_synced;
    sync_mem_req_i: entity work.flag
    port map(
        flag_in      => mem_req,
        flag_out     => mem_req_synced,
        clk          => clk_i
    );


    reciever_i: entity work.reciever
    port map(
        refclk              => refclk,
        rst                 => bus2fpga_reset,
        rxn                 => rxn,
        rxp                 => rxp,
        txn                 => txn,
        txp                 => txp,
        pll_locked          => pll_locked,
        clk                 => clk_i,
        rst_out             => rst_out_i,
        data                => rec_data_i,
        polarity            => rec_polarity_synced,
        descramble          => rec_descramble,
        rxeqmix             => rec_rxeqmix,
        data_valid          => rec_data_valid_i,
        enable              => rec_enable_synced
    );

    sync_select_i: entity work.flag
    port map(
        flag_in      => rec_input_select_req,
        flag_out     => select_synced,
        clk          => clk_i
    );
    select_dly: process(clk_i)
    begin
        if rising_edge(clk_i) then
            select_synced_dly <= select_synced;
        end if;
    end process;
    select_toggle <= select_synced_dly xor select_synced;
	select_r_p: process(clk_i, rst, select_toggle, rec_input_select)
    begin
        if rst = '1' then
            select_r <= (others => '0');
		elsif rising_edge(clk_i) then
            if select_toggle = '1' then
                select_r <= rec_input_select;
            end if;
        end if;
    end process;

    rst_i <= or_many(rst_out_i & rst_toggle & select_toggle & depth_toggle & width_toggle);
    inbuf_rst <= or_many(rst_out_i & rst_toggle);

	mux_process: process(clk_i, rec_data_i, select_r, rec_data_valid_i)
	begin
		if rising_edge(clk_i) then
			case select_r is
				when "00" => data_i <= rec_data_i(0); stream_valid_i <= rec_data_valid_i(0);
				when "01" => data_i <= rec_data_i(1); stream_valid_i <= rec_data_valid_i(1);
				when "10" => data_i <= rec_data_i(2); stream_valid_i <= rec_data_valid_i(2);
				when others => data_i <= (others => '0'); stream_valid_i <= '0';
			end case;
		end if;
	end process;

    sync_depth_i: entity work.flag
    port map(
        flag_in      => depth_req,
        flag_out     => depth_synced,
        clk          => clk_i
    );
    depth_dly: process(clk_i)
    begin
        if rising_edge(clk_i) then
            depth_synced_dly <= depth_synced;
        end if;
    end process;
    depth_toggle <= depth_synced_dly xor depth_synced;
    depth_r_p: process(clk_i, rst, depth_toggle, depth)
    begin
        if rst = '1' then
            depth_1 <= (others => '0');
		elsif rising_edge(clk_i) then
            if depth_toggle = '1' then
                depth_1 <= depth - 1;
            end if;
        end if;
    end process;
    sync_width_i: entity work.flag
    port map(
        flag_in      => width_req,
        flag_out     => width_synced,
        clk          => clk_i
    );
    width_dly: process(clk_i)
    begin
        if rising_edge(clk_i) then
            width_synced_dly <= width_synced;
        end if;
    end process;
    width_toggle <= width_synced_dly xor width_synced;
    width_r_p: process(clk_i, rst, width_toggle, width)
    begin
        if rst = '1' then
            width_r <= (others => '0');
		elsif rising_edge(clk_i) then
            if width_toggle = '1' then
                width_r <= width;
            end if;
        end if;
    end process;
	fpga2bus_error <= '0';

    --------------------------------------
    -- cycle 0: read 0
    -- cycle 1: read 1  data 0
    -- cycle 2:         data 1
    mem_read_cycle(0) <= '1' when bus2fpga_cs = "0001" and bus2fpga_rnw = '1' else '0';
	mem_read_cycle_p: process(bus2fpga_clk, bus2fpga_reset, mem_read_cycle, bus2fpga_cs)
	begin
        if bus2fpga_reset = '1' or not (bus2fpga_cs = "0001") then
            mem_read_cycle(3 downto 1) <= (others => '0');
        elsif rising_edge(bus2fpga_clk) then
            mem_read_cycle(3 downto 1) <= mem_read_cycle(2 downto 0);
		end if;
	end process mem_read_cycle_p;

    fpga2bus_rdack <= mem_read_cycle(3) when bus2fpga_cs = "0001" and bus2fpga_rnw = '1' else '0';

    mem_low_word_p: process(bus2fpga_clk, mem_read_cycle, mem_write_cycle, inbuf_data_out)
    begin
        if rising_edge(bus2fpga_clk) then
            if mem_read_cycle = "0011" or mem_write_cycle = "00011" then
                mem_low_word_r <= inbuf_data_out;
            end if;
        end if;
    end process mem_low_word_p;

    inbuf_addr_data(15 downto 1) <= bus2fpga_addr(14 downto 0) when bus2fpga_cs = "0001" else
                                    (others => '0');
	inbuf_addr_data(0) <= '1' when bus2fpga_cs = "0001" and (mem_read_cycle = "0011" or mem_write_cycle = "00011" or mem_write_cycle = "01111") else
					      '0';

    fpga2bus_data_dly: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
	        fpga2bus_data <= inbuf_data_out & mem_low_word_r;
        end if;
    end process;
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
        width                   => width_r,
        depth_1                 => depth_1,
        arm                     => arm_toggle,
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

end Structural;

