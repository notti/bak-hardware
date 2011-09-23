-----------------------------------------------------------
-- Project			: 
-- File				: cmul.vhd
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

entity cmul is
port(
    clk     : in std_logic;
    sch     : in std_logic_vector(1 downto 0);
    a_re    : in std_logic_vector(15 downto 0);
    a_im    : in std_logic_vector(15 downto 0);
    b_re    : in std_logic_vector(15 downto 0);
    b_im    : in std_logic_vector(15 downto 0);
    c_re    : out std_logic_vector(15 downto 0);
    c_im    : out std_logic_vector(15 downto 0);
    ovfl    : out std_logic
);
end cmul;

architecture Structural of cmul is
    signal PCOUT_0: std_logic_vector(47 downto 0);
    signal PCOUT_2: std_logic_vector(47 downto 0);
    signal c_re_i: std_logic_vector(47 downto 0);
    signal c_im_i: std_logic_vector(47 downto 0);
    signal a_im_i: std_logic_vector(29 downto 0);
    signal a_re_i: std_logic_vector(29 downto 0);
    signal b_im_i: std_logic_vector(17 downto 0);
    signal b_re_i: std_logic_vector(17 downto 0);

begin
    a_im_i <= SXT(a_im, 30);
    a_re_i <= SXT(a_re, 30);
    b_im_i <= SXT(b_im, 18);
    b_re_i <= SXT(b_re, 18);
-- c_re = a_re * b_re - a_im * b+im
-- c_im = a_re * b_im + b_re * a_im
-- DSP48E_0       DSP48E_1       DSP48E_2       DSP48E_3       
-- OPMODE 0000101 OPMODE 0010101 OPMODE 0000101 OPMODE 0010101 
-- ALUMODE   0000 ALUMODE   0011 ALUMODE   0000 ALUMODE   0000 
-- Z+(X+Y+CARRY)  Z-(X+Y+CARRY)  Z+(X+Y+CARRY)  Z+(X+Y+CARRY)  
    DSP48E_3: DSP48E
    generic map (
        AREG => 1,
        BREG => 1,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S"
    )
    port map (
        A => a_im_i,
        B => b_re_i,
        P => c_im_i,
        OPMODE => "0010101",
        ALUMODE => "0000",
        PCIN => PCOUT_2,
        PCOUT => open,
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => "000000000000000000000000000000",
        BCIN => "000000000000000000",
        C => "000000000000000000000000000000000000000000000000",
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
    DSP48E_2: DSP48E
    generic map (
        AREG => 0,
        ACASCREG => 0,
        BREG => 0,
        BCASCREG => 0,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S"
    )
    port map (
        A => a_re_i,
        B => b_im_i,
        P => open,
        OPMODE => "0000101",
        ALUMODE => "0000",
        PCIN => "000000000000000000000000000000000000000000000000",
        PCOUT => PCOUT_2,
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => "000000000000000000000000000000",
        BCIN => "000000000000000000",
        C => "000000000000000000000000000000000000000000000000",
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
    DSP48E_1: DSP48E
    generic map (
        AREG => 1,
        BREG => 1,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S"
    )
    port map (
        A => a_im_i,
        B => b_im_i,
        P => c_re_i,
        OPMODE => "0010101",
        ALUMODE => "0011",
        PCIN => PCOUT_0,
        PCOUT => open,
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => "000000000000000000000000000000",
        BCIN => "000000000000000000",
        C => "000000000000000000000000000000000000000000000000",
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
    DSP48E_0: DSP48E
    generic map (
        AREG => 0,
        ACASCREG => 0,
        BREG => 0,
        BCASCREG => 0,
        MREG => 1,
        PREG => 1,
        USE_MULT => "MULT_S"
    )
    port map (
        A => a_re_i,
        B => b_re_i,
        P => open,
        OPMODE => "0000101",
        ALUMODE => "0000",
        PCIN => "000000000000000000000000000000000000000000000000",
        PCOUT => PCOUT_0,
        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        UNDERFLOW => open,
        ACIN => "000000000000000000000000000000",
        BCIN => "000000000000000000",
        C => "000000000000000000000000000000000000000000000000",
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

    ovfl <= '0';
    c_re <= c_re_i(31 downto 16) when sch = "00" else
            c_re_i(30 downto 14) when sch = "01" else
            c_re_i(29 downto 13) when sch = "10" else
            c_re_i(28 downto 12) when sch = "11";
    c_im <= c_im_i(31 downto 16) when sch = "00" else
            c_im_i(30 downto 14) when sch = "01" else
            c_im_i(29 downto 13) when sch = "10" else
            c_im_i(28 downto 12) when sch = "11";

end Structural;
