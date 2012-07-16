-----------------------------------------------------------
-- implements memory access
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

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
    mem_doutoa          : in  std_logic_vector(31 downto 0)

-- CPU Interface

    fpga2bus_intr       : out std_logic_vector(31 downto 0);
    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    bus2fpga_wrce       : in  std_logic_vector(3 downto 0);
    bus2fpga_rdce       : in  std_logic_vector(3 downto 0);
    bus2fpga_be         : in  std_logic_vector(3 downto 0);
    bus2fpga_data       : in  std_logic_vector(31 downto 0);
    bus2fpga_reset      : in  std_logic;
    bus2fpga_clk        : in  std_logic
);
end proc_memory;

architecture Structural of proc_memory is

begin
    -- memi  read rmwrite
    --       2    2+1
    -- memh  read write
    --       1    1
    -- memoi read write
    --       2    1 
    -- memoa read
    --       2


    fpga2bus_rdack <= or_many(bus2fpga_rdce);
    fpga2bus_wrack <= or_many(bus2fpga_wrce) and not or_many(busy);
    fpga2bus_error <= '0';

end Structural;

