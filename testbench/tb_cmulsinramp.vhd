library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library work;
use work.all;

entity tb_cmulsinramp is
end tb_cmulsinramp;

architecture behav of tb_cmulsinramp is
    signal clk     : std_logic := '0';
    signal a_re    : signed(15 downto 0) := "0000000000000000";
    signal a_im    : signed(15 downto 0) := "0000000000000000";
    signal b_re    : signed(15 downto 0) := X"7FFF";
    signal b_im    : signed(15 downto 0) := X"0000";
    signal c_re    : signed(15 downto 0) := "0000000000000000";
    signal c_im    : signed(15 downto 0) := "0000000000000000";

    signal ovfl    : std_logic           := '0';
    signal shift   : std_logic_vector(1 downto 0) := "10";
    signal sat     : std_logic           := '1';

begin
    
    process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process;

    process
        file values : text;
        variable f_status: FILE_OPEN_STATUS;
        variable buf_in: line;
        variable val: integer;
        variable o: character;
    begin
        wait for 50 ns;
        file_open(f_status, values, "sinramp.csv", read_mode);
        loop
            readline(values, buf_in);
            read(buf_in, val);
            a_re <= to_signed(val, 16);
            read(buf_in, o);
            read(buf_in, val);
            a_im <= to_signed(val, 16);
            wait for 10 ns;
            exit when endfile(values);
        end loop;

        wait for 100 ns;
        assert false report "done" severity failure;
        wait;
    end process;

    cmul_i: entity work.cmul
    port map(
        clk  => clk,
        a_re => a_re,
        a_im => a_im,
        b_re => b_re,
        b_im => b_im,
        c_re => c_re,
        c_im => c_im,
        shift => shift,
        ovfl  => ovfl,
        sat   => sat
    );

    
end behav;
