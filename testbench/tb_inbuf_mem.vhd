library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity tb_inbuf_mem is
    end tb_inbuf_mem;

architecture behav of tb_inbuf_mem is
component inbuf_mem
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(18 downto 0);
	addra: IN std_logic_VECTOR(15 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(18 downto 0);
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(18 downto 0);
	addrb: IN std_logic_VECTOR(15 downto 0);
	web: IN std_logic_VECTOR(0 downto 0);
	doutb: OUT std_logic_VECTOR(18 downto 0));
end component;
        signal clka:  std_logic;
        signal dina:  std_logic_VECTOR(18 downto 0);
        signal addra:  std_logic_VECTOR(15 downto 0);
        signal wea:  std_logic_VECTOR(0 downto 0);
        signal douta:  std_logic_VECTOR(18 downto 0);
        signal clkb:  std_logic;
        signal dinb:  std_logic_VECTOR(18 downto 0);
        signal addrb:  std_logic_VECTOR(15 downto 0);
        signal web:  std_logic_VECTOR(0 downto 0);
        signal doutb:  std_logic_VECTOR(18 downto 0);
begin
    inbuf_mem_i: inbuf_mem
    port map(
        clka => clka,
        dina => dina,
        addra => addra,
        wea => wea,
        douta => douta,
        clkb => clkb,
        dinb => dinb,
        addrb => addrb,
        web => web,
        doutb => doutb
    );


    clkb <= '0';
    dinb <= (others => '0');
    web <= "0";
    addrb <= (others => '0');
    dina <= dinb + 2;

    process
        variable l : line;
    begin
        clka <= '0';
        dina <= (others => '0');
        addra <= X"0000";
        wea <= "0";
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait for 10 ns;
        clka <= '1';
        wait for 10 ns;
        clka <= '0';
        wait;
    end process;

end behav;
