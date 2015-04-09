-----------------------------------------------------------
-- implements memory access
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.procedures.all;

entity proc_memory is
port(
    mem_dinia           : out std_logic_vector(15 downto 0);
    mem_addria          : out std_logic_vector(15 downto 0);
    mem_weaia           : out std_logic_vector(1 downto 0);
    mem_doutia          : in  std_logic_vector(15 downto 0);
    mem_enia            : out std_logic;
    mem_dinib           : out std_logic_vector(15 downto 0);
    mem_addrib          : out std_logic_vector(15 downto 0);
    mem_weaib           : out std_logic_vector(1 downto 0);
    mem_doutib          : in  std_logic_vector(15 downto 0);
    mem_enib            : out std_logic;
    mem_dinh            : out std_logic_vector(31 downto 0);
    mem_addrh           : out std_logic_vector(15 downto 0);
    mem_weh             : out std_logic_vector(3 downto 0);
    mem_douth           : in  std_logic_vector(31 downto 0);
    mem_enh             : out std_logic;
    mem_dinoi           : out std_logic_vector(31 downto 0);
    mem_addroi          : out std_logic_vector(15 downto 0);
    mem_weoi            : out std_logic_vector(3 downto 0);
    mem_doutoi          : in  std_logic_vector(31 downto 0);
    mem_enoi            : out std_logic;
    mem_addroa          : out std_logic_vector(15 downto 0);
    mem_doutoa          : in  std_logic_vector(31 downto 0);
    mem_enoa            : out std_logic;

-- CPU Interface

    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    fpga2bus_addrack    : out std_logic;
    bus2fpga_wrreq      : in  std_logic;
    bus2fpga_rdreq      : in  std_logic;
    bus2fpga_burst      : in  std_logic;
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
    signal wrack            : std_logic;
    signal single_wrreq     : std_logic;

    signal wrreq            : std_logic;

    signal rnw              : std_logic_vector(1 downto 0);
begin
    -- memi  read rmwrite
    --       2    1
    -- memh  read write
    --       2    1
    -- memoi read write
    --       2    1 
    -- memoa read
    --       2

    rnw_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_rnw)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                rnw <= (others => '0');
            else
                rnw <= rnw(0) & bus2fpga_rnw;
            end if;
        end if;
    end process rnw_proc;

    single_wr: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_burst, bus2fpga_wrreq, wrack)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' or wrack = '1' or bus2fpga_burst = '1' then
                single_wrreq <= '0';
            else
                if bus2fpga_wrreq = '1' and bus2fpga_burst = '0' and or_many(bus2fpga_cs) = '1' then
                    single_wrreq <= '1';
                end if;
            end if;
        end if;
    end process single_wr;

    wrreq <= single_wrreq or bus2fpga_wrreq;

-- addresses

    mem_addria  <= bus2fpga_addr(14 downto 0) & '1'; -- low
    mem_addrib  <= bus2fpga_addr(14 downto 0) & '0'; -- high
    mem_addrh   <= bus2fpga_addr;
    mem_addroi  <= bus2fpga_addr;
    mem_addroa  <= bus2fpga_addr;

-- enables

    mem_enia  <= '1' when bus2fpga_cs = "1000" else
                 '0';
    mem_enib  <= '1' when bus2fpga_cs = "1000" else
                 '0';
    mem_enh   <= '1' when bus2fpga_cs = "0100" else
                 '0';
    mem_enoi  <= '1' when bus2fpga_cs = "0010" else
                 '0';
    mem_enoa  <= '1' when bus2fpga_cs = "0001" else
                 '0';

-- read

    fpga2bus_data <= mem_doutib & mem_doutia when bus2fpga_rnw = '1' and bus2fpga_cs = "1000" else
                     mem_douth               when bus2fpga_rnw = '1' and bus2fpga_cs = "0100" else
                     mem_doutoi              when bus2fpga_rnw = '1' and bus2fpga_cs = "0010" else
                     mem_doutoa              when bus2fpga_rnw = '1' and bus2fpga_cs = "0001" else
                     (others => '0');

-- write

    mem_dinh    <= bus2fpga_data;
    mem_weh     <= bus2fpga_be when bus2fpga_cs = "0100" and wrreq = '1' else
                   (others => '0');
    mem_dinoi   <= bus2fpga_data;
    mem_weoi    <= bus2fpga_be when bus2fpga_cs = "0010" and wrreq = '1' else
                   (others => '0');

    mem_dinia <= bus2fpga_data(15 downto 0);
    mem_weaia <= bus2fpga_be(1 downto 0) when bus2fpga_cs = "1000" and wrreq = '1' else
                 (others => '0');
    mem_dinib <= bus2fpga_data(31 downto 16);
    mem_weaib <= bus2fpga_be(3 downto 2) when bus2fpga_cs = "1000" and wrreq = '1' else 
                 (others => '0');

-- ack

    fpga2bus_addrack <= bus2fpga_rdreq or wrreq when or_many(bus2fpga_cs) = '1' else
                        '0';
    fpga2bus_rdack <= rnw(1) when bus2fpga_rnw = '1' and or_many(bus2fpga_cs) = '1' else
                      '0';
    wrack          <= '1' when wrreq = '1' and or_many(bus2fpga_cs) = '1' else
                      '0';
    fpga2bus_wrack <= wrack;
    fpga2bus_error <= '0';

end Structural;

