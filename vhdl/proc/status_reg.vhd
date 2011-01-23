-----------------------------------------------------------
-- Project			: 
-- File				: status_reg.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by	    : 
-- last mod. on	    : 
-- contents			: 
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library proc;
        use proc.all;

library misc;
	use misc.procedures.all;

entity status_reg is
port(
    inbuf_input_select           : out std_logic_vector(1 downto 0);
    inbuf_polarity               : out std_logic_vector(2 downto 0);
    inbuf_descramble             : out std_logic_vector(2 downto 0);
    inbuf_rxeqmix                : out t_cfg_array(2 downto 0);
    inbuf_enable                 : out std_logic_vector(2 downto 0);
    inbuf_data_valid             : in std_logic_vector(2 downto 0);
	inbuf_stream_valid           : in std_logic;
	inbuf_depth					 : out std_logic_vector(15 downto 0);
    inbuf_width					 : out std_logic_vector(1 downto 0);
    inbuf_arm  					 : out std_logic;
	inbuf_done					 : in std_logic;
	inbuf_locked				 : in std_logic;
    inbuf_read_req               : out std_logic;
    inbuf_read_ack               : in std_logic;
	inbuf_rst					 : out std_logic;
    fpga_clk                     : in std_logic;

    intr                         : out std_logic_vector(31 downto 0);
    reg_ip2bus_data              : out std_logic_vector(31 downto 0);
    reg_bus2ip_data              : in std_logic_vector(31 downto 0);
    reg_rd                       : in std_logic_vector(7 downto 0);
    reg_wr                       : in std_logic_vector(7 downto 0);
    bus_be                       : in std_logic_vector(3 downto 0);
    bus_reset                    : in std_logic;
    bus_clk                      : in std_logic
);
end status_reg;

architecture Structural of status_reg is

        type t_recv_reg is array(integer range <>) of std_logic_vector(4 downto 0);
        signal recv_reg             : t_recv_reg(2 downto 0);

        signal slv_reg0             : std_logic_vector(31 downto 0);
        signal slv_reg1             : std_logic_vector(31 downto 0);

--inbuf
        signal inbuf_data_valid_i   : std_logic_vector(2 downto 0);
begin
    intr <= (others=>'0');   --TODO

--reciever:
--    x  enable      ASYNC    1 0
--    x  polarity    SYNC_GTX 1 1
--    x  descramble  SYNC_GTX 1 2
--    x  rxeqmix[0]  ASYNC    0 3
--    x  rxeqmix[0]  ASYNC    0 4
--    r  data_valid  SYNC_PLB 0 5
--    0  0                    0 6
--    0  0                    0 7
--MUX:
--    x  select[0]   ASYNC    0 0
--    x  select[1]   ASYNC    0 1
--    r  data_valid  SYNC_PLB 0 2
--    0  0                    0 3
--    0  0                    0 4
--    0  0                    0 5
--    0  0                    0 6
--    0  0                    0 7
--MEM:
--    t  arm         SYNC_GTX 0 0
--    r  done        SYNC_PLB 0 1
--    t  rst         SYNC_GTX 0 2
--    r  locked      SYNC_PLB 0 3
--    x  read_req             0 4
--    r  read_ack             0 5
--    0  0                    0 6
--    0  0                    0 7
--    WI,DEPTH       ASYNC
--        <   3  ><   2  ><   1  ><   0  >
--        76543210765432107654321076543210
--  REG0: 00000vSE00vRXdpe00vRXdpe00vRXdpe   GTX
--  REG1: 00aqlrds000000WI<     DEPTH    >   MEM
--  REG2:                                    FFT
--  REG3:                                    OUT
    
-- reciever:
    reciever_gen: for i in 0 to 2 generate
        sync_enable_i: entity proc.flag
        port map(
            flag_in     => recv_reg(i)(0),
            flag_out    => inbuf_enable(i),
            clk         => fpga_clk
                );
        sync_polarity_i: entity proc.flag
        port map(
            flag_in     => recv_reg(i)(1),
            flag_out    => inbuf_polarity(i),
            clk         => fpga_clk
                );
        sync_descramble_i: entity proc.flag
        port map(
            flag_in     => recv_reg(i)(2),
            flag_out    => inbuf_descramble(i),
            clk         => fpga_clk
                );
        inbuf_rxeqmix(i) <= recv_reg(i)(4 downto 3);
        sync_data_valid_i: entity proc.flag
        port map(
            flag_in     => inbuf_data_valid(i),
            flag_out    => inbuf_data_valid_i(i),
            clk         => bus_clk
                );

        recv_write_proc: process(bus_clk) is
        begin
			if bus_clk'event and bus_clk = '1' then
				if bus_reset = '1' then
					recv_reg(i) <= "00111";
				else
					if reg_wr = "10000000" and bus_be(i) = '1' then
						recv_reg(i) <= reg_bus2ip_data((i+1)*8-4 downto i*8);
					end if;
				end if;
            end if;
        end process recv_write_proc;
		slv_reg0((i+1)*8-1 downto i*8) <= "00" & inbuf_data_valid_i(i) & recv_reg(i);
    end generate;

-- MUX:
    inbuf_input_select <= slv_reg0(25 downto 24);
	sync_stream_valid_i: entity proc.flag
	port map(
		flag_in     => inbuf_stream_valid,
		flag_out    => slv_reg0(26),
		clk         => bus_clk
			);
	slv_reg0(31 downto 27) <= "00000";
	mux_write_proc: process(bus_clk) is
	begin
		if bus_clk'event and bus_clk = '1' then
			if bus_reset = '1' then
				slv_reg0(25 downto 24) <= "00";
			else
				if reg_wr = "10000000" and bus_be(3) = '1' then
					slv_reg0(25 downto 24) <= reg_bus2ip_data(25 downto 24);
				end if;
			end if;
		end if;
	end process mux_write_proc;
--MEM:
    inbuf_depth <= slv_reg1(15 downto 0);
    inbuf_width <= slv_reg1(17 downto 16);
	sync_arm_i: entity proc.toggle
	port map(
        rst           => bus_reset,
		toggle_in     => slv_reg1(24),
		toggle_out    => inbuf_arm,
		clk_to        => fpga_clk,
		clk_from      => bus_clk
	);
	sync_done_i: entity proc.flag
	port map(
		flag_in     => inbuf_done,
		flag_out    => slv_reg1(25),
		clk         => bus_clk
			);
	sync_rst_i: entity proc.toggle
	port map(
        rst           => bus_reset,
		toggle_in     => slv_reg1(26),
		toggle_out    => inbuf_rst,
        clk_from      => bus_clk,
		clk_to        => fpga_clk
			);
	sync_locked_i: entity proc.flag
	port map(
		flag_in     => inbuf_locked,
		flag_out    => slv_reg1(27),
		clk         => bus_clk
			);
    inbuf_read_req <= slv_reg1(28);
    slv_reg1(29) <= inbuf_read_ack;
	slv_reg1(23 downto 18) <= "000000";
	slv_reg1(31 downto 30) <= "00";
	mem_write_proc: process(bus_clk) is
	begin
		if bus_clk'event and bus_clk = '1' then
			if bus_reset = '1' then
				slv_reg1(24 downto 24) <= (others => '0');
				slv_reg1(26 downto 26) <= (others => '0');
				slv_reg1(28 downto 28) <= (others => '0');
				slv_reg1(17 downto 0) <= (others => '0');
			else
				if reg_wr = "01000000" then
					if bus_be(0) = '1' then
						slv_reg1(7 downto 0) <= reg_bus2ip_data(7 downto 0);
					end if;
					if bus_be(1) = '1' then
						slv_reg1(15 downto 8) <= reg_bus2ip_data(15 downto 8);
					end if;
					if bus_be(2) = '1' then
						slv_reg1(17 downto 16) <= reg_bus2ip_data(17 downto 16);
					end if;
					if bus_be(3) = '1' then
						slv_reg1(24 downto 24) <= reg_bus2ip_data(24 downto 24);
						slv_reg1(26 downto 26) <= reg_bus2ip_data(26 downto 26);
						slv_reg1(28 downto 28) <= reg_bus2ip_data(28 downto 28);
					end if;
				end if;
			end if;
		end if;
	end process mem_write_proc;

  SLAVE_REG_READ_PROC : process(reg_rd, slv_reg0, slv_reg1) is
  begin
    case reg_rd is
      when "10000000" => reg_ip2bus_data <= slv_reg0;
      when "01000000" => reg_ip2bus_data <= slv_reg1;
--      when "00100000" => reg_ip2bus_data <= slv_reg2;
--      when "00010000" => reg_ip2bus_data <= slv_reg3;
--      when "00001000" => reg_ip2bus_data <= slv_reg4;
--      when "00000100" => reg_ip2bus_data <= slv_reg5;
--      when "00000010" => reg_ip2bus_data <= slv_reg6;
--      when "00000001" => reg_ip2bus_data <= slv_reg7;
      when others => reg_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

end Structural;

