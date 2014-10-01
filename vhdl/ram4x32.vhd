library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNIMACRO;
use UNIMACRO.VComponents.all;

library work;
use work.all;

entity ram4x32 is
generic(
    DOA_REG         : integer := 0;
    DOB_REG         : integer := 0
);
port(
    clka            : in  std_logic;
    addra           : in  std_logic_vector(11 downto 0);
    dina            : in  std_logic_vector(31 downto 0);
    douta           : out std_logic_vector(31 downto 0);
    wea             : in  std_logic_vector(3 downto 0);

    clkb            : in  std_logic;
    addrb           : in  std_logic_vector(11 downto 0);
    dinb            : in  std_logic_vector(31 downto 0);
    doutb           : out std_logic_vector(31 downto 0);
    web             : in  std_logic_vector(3 downto 0)
);
end ram4x32;

architecture Structural of ram4x32 is
begin

    ram_gen: for i in 0 to 3 generate
        signal doa : std_logic_vector(7 downto 0);
        signal dob : std_logic_vector(7 downto 0);
        signal dia : std_logic_vector(7 downto 0);
        signal dib : std_logic_vector(7 downto 0);
    begin
        douta((i+1)*8-1 downto i*8) <= doa;
        dia <= dina((i+1)*8-1 downto i*8);
        doutb((i+1)*8-1 downto i*8) <= dob;
        dib <= dinb((i+1)*8-1 downto i*8);
        
        ram36_i: BRAM_TDP_MACRO
        generic map (
            BRAM_SIZE      => "36Kb",
            DEVICE         => "VIRTEX5",
            DOA_REG        => DOA_REG,
            DOB_REG        => DOB_REG,
            READ_WIDTH_A   => 8,
            READ_WIDTH_B   => 8,
            WRITE_MODE_A   => "READ_FIRST",
            WRITE_MODE_B   => "READ_FIRST",
            WRITE_WIDTH_A  => 8,
            WRITE_WIDTH_B  => 8)
        port map (
            DOA         => doa,
            DOB         => dob,
            ADDRA       => addra(11 downto 0),
            ADDRB       => addrb(11 downto 0),
            CLKA        => clka,
            CLKB        => clkb,
            DIA         => dia,
            DIB         => dib,
            ENA         => '1',
            ENB         => '1',
            REGCEA      => '1',
            REGCEB      => '1',
            RSTA        => '0',
            RSTB        => '0',
            WEA         => wea(i downto i),
            WEB         => web(i downto i)
        );
    end generate;

end Structural;

