-----------------------------------------------------------
-- implements memory access
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.procedures.all;

entity proc_memory is
port(
    mem_dinia           : out std_logic_vector(15 downto 0);
    mem_addria          : out std_logic_vector(15 downto 0);
    mem_weaia           : out std_logic;
    mem_doutia          : in  std_logic_vector(15 downto 0);
    mem_dinib           : out std_logic_vector(15 downto 0);
    mem_addrib          : out std_logic_vector(15 downto 0);
    mem_weaib           : out std_logic;
    mem_doutib          : in  std_logic_vector(15 downto 0);
    mem_dinh            : out std_logic_vector(31 downto 0);
    mem_addrh           : out std_logic_vector(15 downto 0);
    mem_weh             : out std_logic_vector(3 downto 0);
    mem_douth           : in  std_logic_vector(31 downto 0);
    mem_dinoi           : out std_logic_vector(31 downto 0);
    mem_addroi          : out std_logic_vector(15 downto 0);
    mem_weoi            : out std_logic_vector(3 downto 0);
    mem_doutoi          : in  std_logic_vector(31 downto 0);
    mem_addroa          : out std_logic_vector(15 downto 0);
    mem_doutoa          : in  std_logic_vector(31 downto 0);

-- CPU Interface

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
end proc_memory;

architecture Structural of proc_memory is
    signal cycle            : std_logic_vector(2 downto 0); -- make one shorter?

    signal mem_douti_low    : std_logic_vector(15 downto 0);
    signal mem_douti_high   : std_logic_vector(15 downto 0);
begin
    -- memi  read rmwrite
    --       2    2+1
    -- memh  read write
    --       1    1
    -- memoi read write
    --       2    1 
    -- memoa read
    --       2

    cycle_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_cs)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' or or_many(bus2fpga_cs) = '0' then
                cycle <= "000";
            else
                cycle <= cycle(1 downto 0) & or_many(bus2fpga_cs);
            end if;
        end if;
    end process cycle_proc;

-- addresses

    mem_addria  <= bus2fpga_addr(14 downto 0) & '0'; -- low
    mem_addrib  <= bus2fpga_addr(14 downto 0) & '1'; -- high
    mem_addrh   <= bus2fpga_addr;
    mem_addroi  <= bus2fpga_addr;
    mem_addroa  <= bus2fpga_addr;

-- read

    fpga2bus_data <= mem_doutib & mem_doutia when bus2fpga_rnw = '1' and bus2fpga_cs = "1000" else
                     mem_douth               when bus2fpga_rnw = '1' and bus2fpga_cs = "0100" else
                     mem_doutoi              when bus2fpga_rnw = '1' and bus2fpga_cs = "0010" else
                     mem_doutoa              when bus2fpga_rnw = '1' and bus2fpga_cs = "0001" else
                     (others => '0');

-- write
    
    mem_dinh    <= bus2fpga_data;
    mem_weh     <= bus2fpga_be when bus2fpga_cs = "0100" and bus2fpga_rnw = '0' else
                   (others => '0');
    mem_dinoi   <= bus2fpga_data;
    mem_weoi    <= bus2fpga_be when bus2fpga_cs = "0010" and bus2fpga_rnw = '0' else
                   (others => '0');

    mem_douti_low  <= mem_doutia;
    mem_douti_high <= mem_doutib;

    mem_dinia <= bus2fpga_data(15 downto 0)                             when bus2fpga_be(1 downto 0) = "11" else
                 mem_douti_low(15 downto 8) & bus2fpga_data(7 downto 0) when bus2fpga_be(1 downto 0) = "01" else
                 bus2fpga_data(15 downto 8) & mem_douti_low(7 downto 0) when bus2fpga_be(1 downto 0) = "10" else
                 (others => '0');
    mem_weaia <= '1' when bus2fpga_cs = "1000" and bus2fpga_rnw = '0' and
                    ((bus2fpga_be(1 downto 0) = "11" and cycle = "000") or 
                    ((bus2fpga_be(0) = '1' or bus2fpga_be(1) = '1') and cycle = "011")) else
                 '0';
    mem_dinib <= bus2fpga_data(31 downto 16)                               when bus2fpga_be(3 downto 2) = "11" else
                 mem_douti_high(15 downto 8) & bus2fpga_data(23 downto 16) when bus2fpga_be(3 downto 2) = "01" else
                 bus2fpga_data(31 downto 24) & mem_douti_high(7 downto 0)  when bus2fpga_be(3 downto 2) = "10" else
                 (others => '0');
    mem_weaib <= '1' when bus2fpga_cs = "1000" and bus2fpga_rnw = '0' and
                    ((bus2fpga_be(3 downto 2) = "11" and cycle = "000") or 
                    ((bus2fpga_be(3) = '1' or bus2fpga_be(2) = '1') and cycle = "011")) else
                 '0';

-- ack

    fpga2bus_rdack <= '1' when bus2fpga_rnw = '1' and (bus2fpga_cs = "1000" or bus2fpga_cs = "0010" or bus2fpga_cs = "0001") and cycle = "011" else
                      '1' when bus2fpga_rnw = '1' and bus2fpga_cs = "0100" and cycle = "001" else
                      '0';
    fpga2bus_wrack <= '1' when bus2fpga_rnw = '0' and (bus2fpga_cs = "0100" or bus2fpga_cs = "0010" or bus2fpga_cs = "0001") and cycle = "000" else
                      '1' when bus2fpga_rnw = '0' and bus2fpga_cs = "1000" and (bus2fpga_be(3 downto 2) = "11" or bus2fpga_be(1 downto 0) = "11") and cycle = "000" else
                      '1' when bus2fpga_rnw = '0' and bus2fpga_cs = "1000" and cycle = "011" else
                      '0';
    fpga2bus_error <= '0';

end Structural;

