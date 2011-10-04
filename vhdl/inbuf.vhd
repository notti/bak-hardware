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
    frame_index         : out std_logic_vector(15 downto 0);
    rst                 : in  std_logic;
    frame_lock          : out std_logic;
);
end inbuf;

architecture Structural of inbuf is
    signal data_clk               : std_logic;
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
    signal arm_toggle          : std_logic;
    signal inbuf_rst           : std_logic;
    signal rst_synced          : std_logic;
    signal rst_synced_dly      : std_logic;
    signal rst_toggle          : std_logic;
    signal select_synced       : std_logic;
    signal select_synced_dly   : std_logic;
    signal select_toggle       : std_logic;
    signal depth_synced        : std_logic;
    signal depth_synced_dly    : std_logic;
    signal depth_toggle        : std_logic;
    signal width_synced        : std_logic;
    signal width_synced_dly    : std_logic;
    signal width_toggle        : std_logic;
    signal select_r            : std_logic_vector(1 downto 0);
    signal width_r             : std_logic_vector(1 downto 0);
    signal depth_r             : std_logic_vector(15 downto 0);
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
            clk          => data_clk
        );
        sync_polarity_i: entity work.flag
        port map(
            flag_in      => rec_polarity(i),
            flag_out     => rec_polarity_synced(i),
            clk          => data_clk
        );
    end generate;
    sync_arm_i: entity work.flag
    port map(
        flag_in      => arm,
        flag_out     => arm_synced,
        clk          => data_clk
    );
    arm_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            arm_synced_dly <= arm_synced;
        end if;
    end process;
    arm_toggle <= arm_synced_dly xor arm_synced;
    sync_rst_i: entity work.flag
    port map(
        flag_in      => rst,
        flag_out     => rst_synced,
        clk          => data_clk
    );
    rst_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            rst_synced_dly <= rst_synced;
        end if;
    end process;
    rst_toggle <= rst_synced_dly xor rst_synced;
    sync_mem_req_i: entity work.flag
    port map(
        flag_in      => mem_req,
        flag_out     => mem_req_synced,
        clk          => data_clk
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
        clk                 => data_clk,
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
        clk          => data_clk
    );
    select_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            select_synced_dly <= select_synced;
        end if;
    end process;
    select_toggle <= select_synced_dly xor select_synced;
	select_r_p: process(data_clk, rst, select_toggle, rec_input_select)
    begin
        if rst = '1' then
            select_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if select_toggle = '1' then
                select_r <= rec_input_select;
            end if;
        end if;
    end process;

    rst_i <= or_many(rst_out_i & rst_toggle & select_toggle & depth_toggle & width_toggle);
    inbuf_rst <= or_many(rst_out_i & rst_toggle);

	mux_process: process(data_clk, rec_data_i, select_r, rec_data_valid_i)
	begin
		if rising_edge(data_clk) then
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
        clk          => data_clk
    );
    depth_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            depth_synced_dly <= depth_synced;
        end if;
    end process;
    depth_toggle <= depth_synced_dly xor depth_synced;
    depth_r_p: process(data_clk, rst, depth_toggle, depth)
    begin
        if rst = '1' then
            depth_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if depth_toggle = '1' then
                depth_r <= depth;
            end if;
        end if;
    end process;
    sync_width_i: entity work.flag
    port map(
        flag_in      => width_req,
        flag_out     => width_synced,
        clk          => data_clk
    );
    width_dly: process(data_clk)
    begin
        if rising_edge(data_clk) then
            width_synced_dly <= width_synced;
        end if;
    end process;
    width_toggle <= width_synced_dly xor width_synced;
    width_r_p: process(data_clk, rst, width_toggle, width)
    begin
        if rst = '1' then
            width_r <= (others => '0');
		elsif rising_edge(data_clk) then
            if width_toggle = '1' then
                width_r <= width;
            end if;
        end if;
    end process;

    --statemachine overall + auto

    --trigger

    average_mem_i: entity work.average_mem
    port map(
        clk                     => data_clk,
        rst                     => rst_i, -- fixme
        width                   => width_r,
        depth                   => depth_r,
        trig                    => trigger, -- fixme - trigger generator
        done                    => avg_done,
        data                    => data_i,
        memclk                  => --fixme
        ext                     => --fixme
        dina                    => --fixme
        addra                   => --fixme
        wea                     => --fixme
        douta                   => --fixme
        dinb                    => --fixme
        addrb                   => --fixme
        web                     => --fixme
        doutb                   => --fixme
    );

    wallclk_i : entity work.wallclk
    port map(
       clk                      => data_clk,
       rst                      => rst_i, --fixme
       n                        => depth_r,
       wave_index               => --fixme
       frame_clk                => --fixme
       frame_trg                => --fixme
       frame_index              => --fixme
    );

    --fft

    --outbuf

    rec_data_valid <= rec_data_valid_i;
	rec_stream_valid <= stream_valid_i;

end Structural;

