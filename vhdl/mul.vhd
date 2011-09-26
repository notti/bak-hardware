-----------------------------------------------------------
-- Project			: 
-- File				: mul.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: overlap add
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity mul is
generic(
    INREG : natural := 1;
    MREG : natural := 1;
    PREG : natural := 1
);
port(
    clk     : in std_logic;
    sch     : in std_logic_vector(1 downto 0);
    a       : in std_logic_vector(15 downto 0);
    b       : in std_logic_vector(15 downto 0);
    c       : out std_logic_vector(15 downto 0);
    carry   : out std_ulogic;
    ovfl    : out std_logic
);
end mul;

architecture Structural of mul is
    signal cl : std_logic_vector(47 downto 0);
    signal al : std_logic_vector(29 downto 0);
    signal bl : std_logic_vector(17 downto 0);
    signal signout : std_logic;
    signal point : std_logic_vector(47 downto 0);
begin
    al <= SXT(a, 30);
    bl <= SXT(b, 18);
--                                        98765432109876543210
    point <= "000000000000000000000000000000000111111111111111" when sch = "00" else
             "000000000000000000000000000000000011111111111111" when sch = "01" else
             "000000000000000000000000000000000001111111111111" when sch = "10" else
             "000000000000000000000000000000000000111111111111" when sch = "11" else
             (others => '0');

    c <= cl(31 downto 16) when sch = "00" else
         cl(30 downto 15) when sch = "01" else
         cl(29 downto 14) when sch = "10" else
         cl(28 downto 13) when sch = "11" else
         (others => '0');

    signout <= cl(47);
    ovfl <= (cl(31) xor signout) when sch = "00" else
            (cl(31) xor signout) or (cl(30) xor signout) when sch = "01" else
            (cl(31) xor signout) or (cl(30) xor signout) or (cl(29) xor signout) when sch = "10" else
            (cl(31) xor signout) or (cl(30) xor signout) or (cl(29) xor signout) or (cl(28) xor signout) when sch = "11" else
            '0';

    DSP48E_0: DSP48E
    generic map (
        AREG => INREG,
        ACASCREG => INREG,
        BREG => INREG,
        BCASCREG => INREG,
        CREG => INREG,
        MREG => MREG,
        PREG => PREG,
        USE_MULT => "MULT_S",
        SEL_MASK => "MASK",
        SEL_ROUNDING_MASK => "MODE2",
        USE_PATTERN_DETECT => "PATDET"
    )
    port map (
        A => al,
        B => bl,
        P => cl,
        C => point,
        OPMODE => "0110101",
        ALUMODE => "0000",
        PCIN => (others => '0'),
        PCOUT => open,
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => carry,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => (others => '0'),
        BCIN => (others => '0'),
        CARRYINSEL => "000",
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CEA1 => '1',
        CEA2 => '1',
        CEALUMODE => '1',
        CEB1 => '1',
        CEB2 => '1',
        CEC => '1',
        CECARRYIN => '1',
        CECTRL => '1',
        CEM => '1',
        CEMULTCARRYIN => '1',
        CEP => '1',
        CLK => clk,
        MULTSIGNIN => '0',
        RSTA => '0',
        RSTALLCARRYIN => '0',
        RSTALUMODE => '0',
        RSTB => '0',
        RSTC => '0',
        RSTCTRL => '0',
        RSTM => '0',
        RSTP => '0'
    );

end Structural;
