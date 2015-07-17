library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;
use work.procedures.all;

entity convergent is
generic(
    WIDTH_IN    : natural := 33;
    WIDTH_OUT   : natural := 16;
    WIDTH_SHIFT : natural := 2
);
port(
    clk     : in  std_logic;
    a       : in  signed(WIDTH_IN-1 downto 0);
    c       : out signed(WIDTH_OUT-1 downto 0);
    shift   : in  std_logic_vector(WIDTH_SHIFT-1 downto 0);
    ovfl    : out std_logic;
    sat     : in  std_logic
);
end convergent;

architecture Structural of convergent is
    signal round_shifted : signed(WIDTH_IN-1 downto 0);
    signal rounded : signed(WIDTH_IN-1 downto 0);
    signal updown : signed(1 downto 0);
    signal ovfl_i : std_logic_vector(2**WIDTH_SHIFT-1 downto 0);
begin
    check_shift: if WIDTH_SHIFT > 4 generate
        assert false report "WIDTH_SHIFT needs to be 0,1,2,3 or 4!" severity failure;
    end generate;
    shift4_gen: if WIDTH_SHIFT = 4 generate
        with shift(3 downto 0) select
            round_shifted <= a srl WIDTH_IN-WIDTH_OUT-1 when "0000",
                a srl WIDTH_IN-WIDTH_OUT-2 when "0001",
                a srl WIDTH_IN-WIDTH_OUT-3 when "0010",
                a srl WIDTH_IN-WIDTH_OUT-4 when "0011",
                a srl WIDTH_IN-WIDTH_OUT-5 when "0100",
                a srl WIDTH_IN-WIDTH_OUT-6 when "0101",
                a srl WIDTH_IN-WIDTH_OUT-7 when "0110",
                a srl WIDTH_IN-WIDTH_OUT-8 when "0111",
                a srl WIDTH_IN-WIDTH_OUT-9 when "1000",
                a srl WIDTH_IN-WIDTH_OUT-10 when "1001",
                a srl WIDTH_IN-WIDTH_OUT-11 when "1010",
                a srl WIDTH_IN-WIDTH_OUT-12 when "1011",
                a srl WIDTH_IN-WIDTH_OUT-13 when "1100",
                a srl WIDTH_IN-WIDTH_OUT-14 when "1101",
                a srl WIDTH_IN-WIDTH_OUT-15 when "1110",
                a srl WIDTH_IN-WIDTH_OUT-16 when others;
    end generate;
    shift3_gen: if WIDTH_SHIFT = 3 generate
        with shift(2 downto 0) select
            round_shifted <= a srl WIDTH_IN-WIDTH_OUT-1 when "000",
                a srl WIDTH_IN-WIDTH_OUT-2 when "001",
                a srl WIDTH_IN-WIDTH_OUT-3 when "010",
                a srl WIDTH_IN-WIDTH_OUT-4 when "011",
                a srl WIDTH_IN-WIDTH_OUT-5 when "100",
                a srl WIDTH_IN-WIDTH_OUT-6 when "101",
                a srl WIDTH_IN-WIDTH_OUT-7 when "110",
                a srl WIDTH_IN-WIDTH_OUT-8 when others;
    end generate;
    shift2_gen: if WIDTH_SHIFT = 2 generate
        with shift(1 downto 0) select
            round_shifted <= a srl WIDTH_IN-WIDTH_OUT-1 when "00",
                a srl WIDTH_IN-WIDTH_OUT-2 when "01",
                a srl WIDTH_IN-WIDTH_OUT-3 when "10",
                a srl WIDTH_IN-WIDTH_OUT-4 when others;
    end generate;
    shift1_gen: if WIDTH_SHIFT = 1 generate
        with shift(0 downto 0) select
            round_shifted <= a srl WIDTH_IN-WIDTH_OUT-1 when "0",
                a srl WIDTH_IN-WIDTH_OUT-2 when others;
    end generate;
    shift0_gen: if WIDTH_SHIFT = 0 generate
        round_shifted <= a srl WIDTH_IN-WIDTH_OUT-1;
    end generate shift0_gen;

    updown(1) <= '0';
    updown(0) <= a(WIDTH_IN-WIDTH_OUT-to_integer(unsigned(shift))) when or_many(std_logic_vector(a(WIDTH_IN-WIDTH_OUT-2-to_integer(unsigned(shift)) downto 0))) = '0' else
              '1';

    rounded <= round_shifted + updown;
    
    ovfl_i(0) <= '0';
    ovfl_gen: for i in 1 to 2**WIDTH_SHIFT-1 generate
    begin
        ovfl_i(i) <= '0' when std_logic_vector(rounded(WIDTH_OUT+i downto WIDTH_OUT+1)) = (i-1 downto 0 => rounded(WIDTH_OUT)) else
              '1';
    end generate ovfl_gen;

    reg: process(clk)
    begin
        if rising_edge(clk) then
            if sat = '0' or ovfl_i(to_integer(unsigned(shift))) = '0' then
                c <= rounded(WIDTH_OUT downto 1);
            else
                c(WIDTH_OUT-1) <= rounded(WIDTH_OUT+to_integer(unsigned(shift)));
                c(WIDTH_OUT-2 downto 0) <= (others => not rounded(WIDTH_OUT+to_integer(unsigned(shift))));
            end if;
            ovfl <= ovfl_i(to_integer(unsigned(shift)));
        end if;
    end process;

end Structural;
