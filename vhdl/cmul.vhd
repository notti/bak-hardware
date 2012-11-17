library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity cmul is
port(
    clk     : in std_logic;
    a_re    : in signed(15 downto 0);
    a_im    : in signed(15 downto 0);
    b_re    : in signed(15 downto 0);
    b_im    : in signed(15 downto 0);
    c_re    : out signed(15 downto 0);
    c_im    : out signed(15 downto 0)
);
end cmul;

architecture Structural of cmul is
    signal a_re_30  : std_logic_vector(29 downto 0);
    signal b_re_18  : std_logic_vector(17 downto 0);
    signal PCOUT_0  : std_logic_vector(47 downto 0);
    signal a_im_30  : std_logic_vector(29 downto 0);
    signal b_im_18  : std_logic_vector(17 downto 0);
    signal c_re_48  : std_logic_vector(47 downto 0);
    signal PCOUT_2  : std_logic_vector(47 downto 0);
    signal c_im_48  : std_logic_vector(47 downto 0);
begin

    a_re_30 <= std_logic_vector(resize(a_re, 30));
    b_re_18 <= std_logic_vector(resize(b_re, 18));
    a_im_30 <= std_logic_vector(resize(a_im, 30));
    b_im_18 <= std_logic_vector(resize(b_im, 18));

    c_re <= signed(c_re_48(31 downto 16));
    c_im <= signed(c_im_48(31 downto 16));

    DSP48E_3 : DSP48E
    generic map (
        AREG => 2,
        ACASCREG => 2,
        BREG => 2,
        BCASCREG => 2,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S")
    port map (
        A => a_im_30,
        B => b_re_18,
        P => c_im_48,
        PCOUT => open,
        PCIN => PCOUT_2,
        OPMODE => "0010101",
        ALUMODE => "0000",
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => (others => '0'),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
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
    DSP48E_2 : DSP48E
    generic map (
        AREG => 1,
        ACASCREG => 1,
        BREG => 1,
        BCASCREG => 1,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S")
    port map (
        A => a_re_30,
        B => b_im_18,
        P => open,
        PCOUT => PCOUT_2,
        PCIN => (others => '0'),
        OPMODE => "0000101",
        ALUMODE => "0000",
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => (others => '0'),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
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
    DSP48E_1 : DSP48E
    generic map (
        AREG => 2,
        ACASCREG => 2,
        BREG => 2,
        BCASCREG => 2,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S")
    port map (
        A => a_im_30,
        B => b_im_18,
        P => c_re_48,
        PCOUT => open,
        PCIN => PCOUT_0,
        OPMODE => "0010101",
        ALUMODE => "0011",
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => (others => '0'),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
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
    DSP48E_0 : DSP48E
    generic map (
        AREG => 1,
        ACASCREG => 1,
        BREG => 1,
        BCASCREG => 1,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S")
    port map (
        A => a_re_30,
        B => b_re_18,
        P => open,
        PCOUT => PCOUT_0,
        PCIN => (others => '0'),
        OPMODE => "0000101",
        ALUMODE => "0000",
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => (others => '0'),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
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

