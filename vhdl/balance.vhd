library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity balance is
port(
	clk                 : in  std_logic;
	rst                 : in  std_logic;
	en                  : in  std_logic;
	unbalanced          : in  std_logic_vector(5 downto 0);
	balanced            : out std_logic_vector(6 downto 0)
);
end balance;

architecture Structural of balance is
    signal bal             : SIGNED(3 downto 0);
    signal overall_balance : SIGNED(3 downto 0);
    signal inv             : std_logic;
begin
    -- generated with balance_table.py
    bal <= TO_SIGNED(-6,4) when unbalanced = "000000" else
           TO_SIGNED(-4,4) when unbalanced = "000001" else
           TO_SIGNED(-4,4) when unbalanced = "000010" else
           TO_SIGNED(-2,4) when unbalanced = "000011" else
           TO_SIGNED(-4,4) when unbalanced = "000100" else
           TO_SIGNED(-2,4) when unbalanced = "000101" else
           TO_SIGNED(-2,4) when unbalanced = "000110" else
           TO_SIGNED( 0,4) when unbalanced = "000111" else
           TO_SIGNED(-4,4) when unbalanced = "001000" else
           TO_SIGNED(-2,4) when unbalanced = "001001" else
           TO_SIGNED(-2,4) when unbalanced = "001010" else
           TO_SIGNED( 0,4) when unbalanced = "001011" else
           TO_SIGNED(-2,4) when unbalanced = "001100" else
           TO_SIGNED( 0,4) when unbalanced = "001101" else
           TO_SIGNED( 0,4) when unbalanced = "001110" else
           TO_SIGNED( 2,4) when unbalanced = "001111" else
           TO_SIGNED(-4,4) when unbalanced = "010000" else
           TO_SIGNED(-2,4) when unbalanced = "010001" else
           TO_SIGNED(-2,4) when unbalanced = "010010" else
           TO_SIGNED( 0,4) when unbalanced = "010011" else
           TO_SIGNED(-2,4) when unbalanced = "010100" else
           TO_SIGNED( 0,4) when unbalanced = "010101" else
           TO_SIGNED( 0,4) when unbalanced = "010110" else
           TO_SIGNED( 2,4) when unbalanced = "010111" else
           TO_SIGNED(-2,4) when unbalanced = "011000" else
           TO_SIGNED( 0,4) when unbalanced = "011001" else
           TO_SIGNED( 0,4) when unbalanced = "011010" else
           TO_SIGNED( 2,4) when unbalanced = "011011" else
           TO_SIGNED( 0,4) when unbalanced = "011100" else
           TO_SIGNED( 2,4) when unbalanced = "011101" else
           TO_SIGNED( 2,4) when unbalanced = "011110" else
           TO_SIGNED( 4,4) when unbalanced = "011111" else
           TO_SIGNED(-4,4) when unbalanced = "100000" else
           TO_SIGNED(-2,4) when unbalanced = "100001" else
           TO_SIGNED(-2,4) when unbalanced = "100010" else
           TO_SIGNED( 0,4) when unbalanced = "100011" else
           TO_SIGNED(-2,4) when unbalanced = "100100" else
           TO_SIGNED( 0,4) when unbalanced = "100101" else
           TO_SIGNED( 0,4) when unbalanced = "100110" else
           TO_SIGNED( 2,4) when unbalanced = "100111" else
           TO_SIGNED(-2,4) when unbalanced = "101000" else
           TO_SIGNED( 0,4) when unbalanced = "101001" else
           TO_SIGNED( 0,4) when unbalanced = "101010" else
           TO_SIGNED( 2,4) when unbalanced = "101011" else
           TO_SIGNED( 0,4) when unbalanced = "101100" else
           TO_SIGNED( 2,4) when unbalanced = "101101" else
           TO_SIGNED( 2,4) when unbalanced = "101110" else
           TO_SIGNED( 4,4) when unbalanced = "101111" else
           TO_SIGNED(-2,4) when unbalanced = "110000" else
           TO_SIGNED( 0,4) when unbalanced = "110001" else
           TO_SIGNED( 0,4) when unbalanced = "110010" else
           TO_SIGNED( 2,4) when unbalanced = "110011" else
           TO_SIGNED( 0,4) when unbalanced = "110100" else
           TO_SIGNED( 2,4) when unbalanced = "110101" else
           TO_SIGNED( 2,4) when unbalanced = "110110" else
           TO_SIGNED( 4,4) when unbalanced = "110111" else
           TO_SIGNED( 0,4) when unbalanced = "111000" else
           TO_SIGNED( 2,4) when unbalanced = "111001" else
           TO_SIGNED( 2,4) when unbalanced = "111010" else
           TO_SIGNED( 4,4) when unbalanced = "111011" else
           TO_SIGNED( 2,4) when unbalanced = "111100" else
           TO_SIGNED( 4,4) when unbalanced = "111101" else
           TO_SIGNED( 4,4) when unbalanced = "111110" else
           TO_SIGNED( 6,4) when unbalanced = "111111" else
           TO_SIGNED( 0,4);
    -- overall pos:  bal pos : inv
    --               bal <=0: norm
    -- overall neg:  bal pos : norm
    --               bal <=0: inv
    -- overall zero: inv
    -- inv: overall += 1 - cur
    -- norm: overall += cur - 1
    dcb_p: process(clk, bal, overall_balance)
    begin
        if overall_balance > 0 then
            if bal > 0 then
                inv <= '1';
            else
                inv <= '0';
            end if;
        elsif overall_balance < 0 then
            if bal > 0 then
                inv <= '0';
            else
                inv <= '1';
            end if;
        else
            inv <= '1';
        end if;
        if rising_edge(clk) and en = '1' then
            if rst = '1' then
                overall_balance <= (others => '0');
            else
                if inv = '1' then
                    overall_balance <= overall_balance + 1 - bal;
                else
                    overall_balance <= overall_balance + bal - 1;
                end if;
            end if;
        end if;
    end process;
    balanced <= unbalanced & "0" when inv = '0' else
                not (unbalanced & "0");
end Structural;
