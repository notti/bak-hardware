library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity ram48xi is
generic(
    WIDTH           : integer := 32;
    DOA_REG         : integer := 0;
    DOB_REG         : integer := 0
);
port(
    clka            : in  std_logic;
    addra           : in  std_logic_vector(15 downto 0);
    dina            : in  std_logic_vector(WIDTH-1 downto 0);
    douta           : out std_logic_vector(WIDTH-1 downto 0);
    wea             : in  std_logic_vector(WIDTH-1 downto 0);
    ena             : in  std_logic_vector(WIDTH-1 downto 0);

    clkb            : in  std_logic;
    addrb           : in  std_logic_vector(15 downto 0);
    dinb            : in  std_logic_vector(WIDTH-1 downto 0);
    doutb           : out std_logic_vector(WIDTH-1 downto 0);
    web             : in  std_logic_vector(WIDTH-1 downto 0);
    enb             : in  std_logic_vector(WIDTH-1 downto 0)
);
end ram48xi;

architecture Structural of ram48xi is
begin

    ram_generate: for i in 0 to WIDTH-1 generate
    begin
        ram48x1_i: entity work.ram48x1
        generic map(
            DOA_REG        => DOA_REG,
            DOB_REG        => DOB_REG)
        port map(
            clka           => clka,
            addra          => addra,
            dina           => dina(i),
            douta          => douta(i),
            wea            => wea(i),
            ena            => ena(i),

            clkb           => clkb,
            addrb          => addrb,
            dinb           => dinb(i),
            doutb          => doutb(i),
            web            => web(i),
            enb            => enb(i)
        );
    end generate;

end Structural;


