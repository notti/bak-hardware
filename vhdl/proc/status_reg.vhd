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
        use IEEE.NUMERIC_STD.ALL;

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
    fpga_clk                     : in std_logic;

    proc2fpga_0_intr_pin         : OUT std_logic_vector(0 to 31);
    proc2fpga_0_Reg2Bus_Data_pin : OUT std_logic_vector(0 to 31);
    proc2fpga_0_Bus2Reg_Data_pin : IN std_logic_vector(0 to 31);
    proc2fpga_0_Bus_RegRd_pin    : IN std_logic_vector(0 to 7);
    proc2fpga_0_Bus_RegWr_pin    : IN std_logic_vector(0 to 7);
    proc2fpga_0_Bus_BE_pin       : IN std_logic_vector(0 to 3);
    proc2fpga_0_Bus_Reset_pin    : IN std_logic;
    proc2fpga_0_Bus_Clk_pin      : IN std_logic
);
end status_reg;

architecture Structural of status_reg is

        type t_recv_reg is array(integer range <>) of std_logic_vector(2 to 6);
        signal recv_reg             : t_recv_reg(2 downto 0);

        signal slv_reg0             : std_logic_vector(0 to 31);

--inbuf
        signal inbuf_input_select_i : std_logic_vector(1 downto 0);
        signal inbuf_data_valid_i   : std_logic_vector(2 downto 0);
begin
    proc2fpga_0_intr_pin <= (others=>'0');

    
    sync_gen: for i in 0 to 2 generate
        sync_enable_i: entity flag
        port map(
            flag_in     => recv_reg(i)(6),
            flag_out    => inbuf_enable(i),
            clk         => fpga_clk
                );
        sync_polarity_i: entity flag
        port map(
            flag_in     => recv_reg(i)(5),
            flag_out    => inbuf_polarity(i),
            clk         => fpga_clk
                );
        sync_descramble_i: entity flag
        port map(
            flag_in     => recv_reg(i)(4),
            flag_out    => inbuf_descramble(i),
            clk         => fpga_clk
                );
        inbuf_rxeqmix(i)(0) <= recv_reg(i)(3);
        inbuf_rxeqmix(i)(1) <= recv_reg(i)(2);
        sync_data_valid_i: entity flag
        port map(
            flag_in     => inbuf_data_valid(i),
            flag_out    => inbuf_data_valid_i(i),
            clk         => proc2fpga_0_Bus_Clk_pin 
                );
        recv_write_proc: process(proc2fpga_0_Bus_Clk_pin) is
        begin
            if proc2fpga_0_Bus_Clk_pin'event and proc2fpga_0_Bus_Clk_pin = '1' then
                if proc2fpga_0_Bus_Reset_pin = '1' then
                    recv_reg(i) <= "00111";
                else
                    if proc2fpga_0_Bus_RegWr_pin = "10000000" and
                        proc2fpga_0_Bus_BE_pin(i) = '1' then
                        recv_reg(i) <= proc2fpga_0_Bus2Reg_Data_pin((3-i)*8+2 to (3-i)*8+6);
                    end if;
                end if;
            end if;
        end process recv_write_proc;
    end generate;

    slv_reg0 <= inbuf_data_valid_i(0) & recv_reg(0) & "00" &
                inbuf_data_valid_i(1) & recv_reg(1) & "00" &
                inbuf_data_valid_i(2) & recv_reg(2) & "00" &
                "00000000";


--reciever:
--    r 1 data_valid   SYNC_PLB
--    x 1 enable       ASYNC
--    x 1 polarity     SYNC_GTX
--    x 1 descramble   SYNC_GTX
--    x 2 rxeqmix      ASYNC
--   vepdrr  vepdrr  vepdrr  
--   765432107654321076543210
  -- implement slave model software accessible register(s)
--  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
--  begin
--
--    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
--      if Bus2IP_Reset = '1' then
--        slv_reg0 <= (others => '0');
--        slv_reg1 <= (others => '0');
--        slv_reg2 <= (others => '0');
--        slv_reg3 <= (others => '0');
--        slv_reg4 <= (others => '0');
--        slv_reg5 <= (others => '0');
--        slv_reg6 <= (others => '0');
--        slv_reg7 <= (others => '0');
--      else
--        case slv_reg_write_sel is
--          when "10000000" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "01000000" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00100000" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00010000" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00001000" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg4(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00000100" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg5(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00000010" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg6(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when "00000001" =>
--            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
--              if ( Bus2IP_BE(byte_index) = '1' ) then
--                slv_reg7(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
--              end if;
--            end loop;
--          when others => null;
--        end case;
--      end if;
--    end if;
--
--  end process SLAVE_REG_WRITE_PROC;
--
--  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process(proc2fpga_0_Bus_RegRd_pin, slv_reg0) is
  begin

    case proc2fpga_0_Bus_RegRd_pin is
      when "10000000" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg0;
--      when "01000000" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg1;
--      when "00100000" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg2;
--      when "00010000" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg3;
--      when "00001000" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg4;
--      when "00000100" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg5;
--      when "00000010" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg6;
--      when "00000001" => proc2fpga_0_Reg2Bus_Data_pin <= slv_reg7;
      when others => proc2fpga_0_Reg2Bus_Data_pin <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

end Structural;

