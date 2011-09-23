-----------------------------------------------------------
-- Project          : 
-- File             : inputram.vhd
-- Author           : Gernot Vormayr
-- contents         : 
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity inputram is
generic(
    DOA_REG      : integer := 0;
    DOB_REG      : integer := 0;
    WRITE_MODE_A : string  := "WRITE_FIRST";
    WRITE_MODE_B : string  := "WRITE_FIRST";
    DOA_REGMUX   : integer := 0;
    DOB_REGMUX   : integer := 0
);
port(
    CLKA  : in  std_logic;
    CLKB  : in  std_logic;
    DOA   : out std_logic_vector(18 downto 0);
    DOB   : out std_logic_vector(18 downto 0);
    DIA   : in  std_logic_vector(18 downto 0);
    DIB   : in  std_logic_vector(18 downto 0);
    ADDRA : in  std_logic_vector(15 downto 0);
    ADDRB : in  std_logic_vector(15 downto 0);
    ENA   : in  std_logic;
    ENB   : in  std_logic;
    WEA   : in  std_logic;
    WEB   : in  std_logic
);
end inputram;
-- width | addrpins | base | high |
-- 9     | 12       | 0000 | 0FFF | 2x36 1x18?
-- 4     | 13       | 1000 | 33FF | 5x36
-- 1     | 15       | 3400 | C3FF | 19x36
architecture Structural of inputram is
    signal cea : std_logic_vector(2 downto 0);
    signal ceb : std_logic_vector(2 downto 0);
    signal addra9 : std_logic_vector(11 downto 0);
    signal addra4l : std_logic_vector(13 downto 0);
    signal addra4 : std_logic_vector(12 downto 0);
    signal addra1 : std_logic_vector(14 downto 0);
    signal addrb9 : std_logic_vector(11 downto 0);
    signal addrb4l : std_logic_vector(13 downto 0);
    signal addrb4 : std_logic_vector(12 downto 0);
    signal addrb1 : std_logic_vector(14 downto 0);
    signal doa9 : std_logic_vector(26 downto 0);
    signal dob9 : std_logic_vector(26 downto 0);
    signal dia9 : std_logic_vector(26 downto 0);
    signal dib9 : std_logic_vector(26 downto 0);
    signal doa4 : std_logic_vector(19 downto 0);
    signal dob4 : std_logic_vector(19 downto 0);
    signal dia4 : std_logic_vector(19 downto 0);
    signal dib4 : std_logic_vector(19 downto 0);
    signal doa1 : std_logic_vector(18 downto 0);
    signal dob1 : std_logic_vector(18 downto 0);
    signal dia1 : std_logic_vector(18 downto 0);
    signal dib1 : std_logic_vector(18 downto 0);
    signal doa_mux : std_logic_vector(18 downto 0);
    signal dob_mux : std_logic_vector(18 downto 0);
begin
    cea <= "001" when ADDRA < X"1000" else
            "010" when ADDRA < X"3400" else
            "100";
    ceb <= "001" when ADDRB < X"1000" else
            "010" when ADDRB < X"3400" else
            "100";
    addra9  <= ADDRA(11 downto 0);
    addrb9  <= ADDRA(11 downto 0);
    addra4l <= ADDRA(13 downto 0) - X"1000";
    addra4  <= addra4l(12 downto 0);
    addrb4l <= ADDRB(13 downto 0) - X"1000";
    addrb4  <= addrb4l(12 downto 0);
    addra1  <= ADDRA - X"3400";
    addrb1  <= ADDRB - X"3400";

    ram9: for i in 0 to 2 generate
        signal ena9 : std_logic;
        signal enb9 : std_logic;
        signal wea9 : std_logic;
        signal web9 : std_logic;
    begin
        ena9 <= ena when cea = "001" else
                '0';
        enb9 <= enb when ceb = "001" else
                '0';
        wea9 <= wea when cea = "001" else
                '0';
        web9 <= web when ceb = "001" else
                '0';
        ram9_inst: entity work.blockram
        generic map(
            DOA_REG      => DOA_REG,
            DOB_REG      => DOB_REG,
            WRITE_MODE_A => WRITE_MODE_A,
            WRITE_MODE_B => WRITE_MODE_B,
            WIDTH        => 9
        )
        port map(
            CLKA         => CLKA,
            CLKB         => CLKB,
            DOA          => doa9(9*(i+1)-1 downto 9*i),
            DOB          => dob9(9*(i+1)-1 downto 9*i),
            DIA          => dia9(9*(i+1)-1 downto 9*i),
            DIB          => dib9(9*(i+1)-1 downto 9*i),
            ADDRA        => addra9,
            ADDRB        => addrb9,
            WEA          => wea9,
            WEB          => web9,
            ENA          => ena9,
            ENB          => enb9
        );
    end generate;

    ram4: for i in 0 to 4 generate
        signal ena4 : std_logic;
        signal enb4 : std_logic;
        signal wea4 : std_logic;
        signal web4 : std_logic;
    begin
        ena4 <= ena when cea = "010" else
                '0';
        enb4 <= enb when ceb = "010" else
                '0';
        wea4 <= wea when cea = "010" else
                '0';
        web4 <= web when ceb = "010" else
                '0';
        ram4_inst: entity work.blockram
        generic map(
            DOA_REG      => DOA_REG,
            DOB_REG      => DOB_REG,
            WRITE_MODE_A => WRITE_MODE_A,
            WRITE_MODE_B => WRITE_MODE_B,
            WIDTH        => 4
        )
        port map(
            CLKA         => CLKA,
            CLKB         => CLKB,
            DOA          => doa4(4*(i+1)-1 downto 4*i),
            DOB          => dob4(4*(i+1)-1 downto 4*i),
            DIA          => dia4(4*(i+1)-1 downto 4*i),
            DIB          => dib4(4*(i+1)-1 downto 4*i),
            ADDRA        => addra4,
            ADDRB        => addrb4,
            WEA          => wea4,
            WEB          => web4,
            ENA          => ena4,
            ENB          => enb4
        );
    end generate;

    ram1: for i in 0 to 18 generate
        signal ena1 : std_logic;
        signal enb1 : std_logic;
        signal wea1 : std_logic;
        signal web1 : std_logic;
    begin
        ena1 <= ena when cea = "100" else
                '0';
        enb1 <= enb when ceb = "100" else
                '0';
        wea1 <= wea when cea = "100" else
                '0';
        web1 <= web when ceb = "100" else
                '0';
        ram1_inst: entity work.blockram
        generic map(
            DOA_REG      => DOA_REG,
            DOB_REG      => DOB_REG,
            WRITE_MODE_A => WRITE_MODE_A,
            WRITE_MODE_B => WRITE_MODE_B,
            WIDTH        => 1
        )
        port map(
            CLKA         => CLKA,
            CLKB         => CLKB,
            DOA          => doa1(i downto i),
            DOB          => dob1(i downto i),
            DIA          => dia1(i downto i),
            DIB          => dib1(i downto i),
            ADDRA        => addra1,
            ADDRB        => addrb1,
            WEA          => wea1,
            WEB          => web1,
            ENA          => ena1,
            ENB          => enb1
        );
    end generate;

    dia9 <= "11111111" & dia;
    dib9 <= "11111111" & dib;
    dia4 <= "1" & dia;
    dib4 <= "1" & dib;
    dia1 <= dia;
    dib1 <= dib;

    doa_mux <= doa9(18 downto 0) when cea = "001" else
               doa4(18 downto 0) when cea = "010" else
               doa1(18 downto 0);
    dob_mux <= dob9(18 downto 0) when ceb = "001" else
               dob4(18 downto 0) when ceb = "010" else
               dob1(18 downto 0);

    out_rega: if DOA_REGMUX = 1 generate
        process(CLKA, doa_mux)
        begin
            if rising_edge(CLKA) then
                DOA <= doa_mux;
            end if;
        end process;
    end generate;
    noout_rega: if DOA_REGMUX = 0 generate
        DOA <= doa_mux;
    end generate;

    out_regb: if DOB_REGMUX = 1 generate
        process(CLKB, dob_mux)
        begin
            if rising_edge(CLKB) then
                DOB <= dob_mux;
            end if;
        end process;
    end generate;
    noout_regb: if DOB_REGMUX = 0 generate
        DOB <= dob_mux;
    end generate;

end Structural;

