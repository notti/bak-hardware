library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNIMACRO;
use UNIMACRO.VComponents.all;

library work;
use work.all;

entity ram4x32S is
generic(
    DO_REG         : integer := 0
);
port(
    clka            : in  std_logic;
    addra           : in  std_logic_vector(11 downto 0);
    dina            : in  std_logic_vector(31 downto 0);
    douta           : out std_logic_vector(31 downto 0);
    wea             : in  std_logic
);
end ram4x32S;

architecture Structural of ram4x32S is
    signal wea_many : std_logic_vector(0 downto 0);
begin

    wea_many(0) <= wea;

    ram_gen: for i in 0 to 3 generate
        signal do : std_logic_vector(7 downto 0);
        signal di : std_logic_vector(7 downto 0);
    begin
        douta((i+1)*8-1 downto i*8) <= do;
        di <= dina((i+1)*8-1 downto i*8);
        ram36_i: BRAM_SINGLE_MACRO
        generic map (
            BRAM_SIZE      => "36Kb",
            DEVICE         => "VIRTEX5",
            DO_REG        => DO_REG,
            READ_WIDTH   => 8,
            WRITE_MODE   => "READ_FIRST",
            WRITE_WIDTH  => 8)
        port map (
            DO         => do,
            ADDR       => addra(11 downto 0),
            CLK        => clka,
            DI         => di,
            EN         => '1',
            REGCE      => '1',
            RST        => '0',
            WE         => wea_many
        );
    end generate;

end Structural;

