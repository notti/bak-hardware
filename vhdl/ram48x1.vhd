library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNIMACRO;
use UNIMACRO.VComponents.all;

library work;
use work.all;

entity ram48x1 is
generic(
    DOA_REG         : integer := 0;
    DOB_REG         : integer := 0
);
port(
    clka            : in  std_logic;
    addra           : in  std_logic_vector(15 downto 0);
    dina            : in  std_logic;
    douta           : out std_logic;
    wea             : in  std_logic;

    clkb            : in  std_logic;
    addrb           : in  std_logic_vector(15 downto 0);
    dinb            : in  std_logic;
    doutb           : out std_logic;
    web             : in  std_logic
);
end ram48x1;

architecture Structural of ram48x1 is
    signal en36a    : std_logic;
    signal en18a    : std_logic;
    signal en36b    : std_logic;
    signal en18b    : std_logic;

    signal doa36    : std_logic_vector(0 downto 0);
    signal doa18    : std_logic_vector(0 downto 0);
    signal dob36    : std_logic_vector(0 downto 0);
    signal dob18    : std_logic_vector(0 downto 0);

    signal dia      : std_logic_vector(0 downto 0);
    signal dib      : std_logic_vector(0 downto 0);

    signal we36a_many : std_logic_vector(0 downto 0);
    signal we36b_many : std_logic_vector(0 downto 0);
    signal we18a_many : std_logic_vector(0 downto 0);
    signal we18b_many : std_logic_vector(0 downto 0);

begin
    en36a <= addra(15);
    en18a <= not addra(15);
    en36b <= addrb(15);
    en18b <= not addrb(15);

    dia(0) <= dina;
    dib(0) <= dinb;
    we36a_many(0) <= wea and addra(15);
    we18a_many(0) <= wea and not addra(15);
    we36b_many(0) <= web and addra(15);
    we18b_many(0) <= web and not addra(15);

    ram36_i: BRAM_TDP_MACRO
    generic map (
        BRAM_SIZE      => "36Kb",
        DEVICE         => "VIRTEX5",
        DOA_REG        => DOA_REG,
        DOB_REG        => DOB_REG,
        READ_WIDTH_A   => 1,
        READ_WIDTH_B   => 1,
        WRITE_MODE_A   => "READ_FIRST",
        WRITE_MODE_B   => "READ_FIRST",
        WRITE_WIDTH_A  => 1,
        WRITE_WIDTH_B  => 1)
    port map (
        DOA         => doa36,
        DOB         => dob36,
        ADDRA          => addra(14 downto 0),
        ADDRB          => addrb(14 downto 0),
        CLKA           => clka,
        CLKB           => clkb,
        DIA         => dia,
        DIB         => dib,
        ENA            => en36a,
        ENB            => en36b,
        REGCEA         => en36a,
        REGCEB         => en36b,
        RSTA           => '0',
        RSTB           => '0',
        WEA         => we36a_many,
        WEB         => we36b_many
    );

    ram18_i: BRAM_TDP_MACRO
    generic map (
        BRAM_SIZE      => "18Kb",
        DEVICE         => "VIRTEX5",
        DOA_REG        => DOA_REG,
        DOB_REG        => DOA_REG,
        READ_WIDTH_A   => 1,
        READ_WIDTH_B   => 1,
        WRITE_MODE_A   => "READ_FIRST",
        WRITE_MODE_B   => "READ_FIRST",
        WRITE_WIDTH_A  => 1,
        WRITE_WIDTH_B  => 1)
    port map (
        DOA         => doa18,
        DOB         => dob18,
        ADDRA          => addra(13 downto 0),
        ADDRB          => addrb(13 downto 0),
        CLKA           => clka,
        CLKB           => clkb,
        DIA         => dia,
        DIB         => dib,
        ENA            => en18a,
        ENB            => en18b,
        REGCEA         => en18a,
        REGCEB         => en18b,
        RSTA           => '0',
        RSTB           => '0',
        WEA         => we18a_many,
        WEB         => we18b_many
    );

    douta <= doa36(0) when en36a = '1' else
             doa18(0);
    doutb <= dob36(0) when en36b = '1' else
             dob18(0);

end Structural;

