library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_SIGNED.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.conv_integer;
        use IEEE.STD_LOGIC_ARITH.ALL;
library std;
        use std.textio.all;
library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.all;

entity tb_overlap_add is
end tb_overlap_add;

architecture behav of tb_overlap_add is
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';

    signal start        : std_logic := '0';
    signal nfft         : std_logic_vector(4 downto 0) := "00110";
    signal scale_sch    : std_logic_vector(11 downto 0) := "011010101010";
    signal L            : std_logic_vector(11 downto 0) := X"023"; -- 35
    signal n            : std_logic_vector(15 downto 0) := X"0190"; -- 400
    signal iq           : std_logic := '0';

    signal wave_index   : std_logic_vector(3 downto 0) := X"0";
    signal x_in         : std_logic_vector(15 downto 0);
    signal x_index      : std_logic_vector(15 downto 0);

    signal y_re_in      : std_logic_vector(15 downto 0);
    signal y_im_in      : std_logic_vector(15 downto 0);
    signal y_re_out     : std_logic_vector(15 downto 0);
    signal y_im_out     : std_logic_vector(15 downto 0);
    signal y_index      : std_logic_vector(15 downto 0);
    signal y_we         : std_logic;

    signal h_re_in      : std_logic_vector(15 downto 0);
    signal h_im_in      : std_logic_vector(15 downto 0);
    signal h_index      : std_logic_vector(11 downto 0);

    signal ovfl        : std_logic;
    signal busy         : std_logic;
    signal done         : std_logic;
    type field is array(natural range <>) of integer;
    constant x : field:=
    (2057,4107,6140,8149,10126,12062,13952,15786,17557,19260,20886,22431,23886,25247,26509,27666,28714,29648,30466,31163,31738,32187,32509,32702,32767,32702,32509,32187,31738,31163,30466,29648,28714,27666,26509,25247,23886,22431,20886,19260,17557,15786,13952,12062,10126,8149,6140,4107,2057,0,0,0,0,0,0,0,0,0,0,-19260,-20886,-22431,-23886,-25247,-26509,-27666,-28714,-29648,-30466,-31163,-31738,-32187,-32509,-32702,-32767,-32702,-32509,-32187,-31738,-31163,-30466,-29648,-28714,-27666,-26509,-25247,-23886,-22431,-20886,-19260,-17557,-15786,-13952,-12062,-10126,-8149,-6140,-4107,-2057,0,2057,4107,6140,8149,10126,12062,13952,15786,17557,19260,20886,22431,23886,25247,26509,27666,28714,29648,30466,31163,31738,32187,32509,32702,32767,32702,32509,32187,31738,31163,30466,29648,28714,27666,26509,25247,23886,22431,20886,19260,17557,15786,13952,12062,10126,8149,6140,4107,2057,0,-2057,-4107,-6140,-8149,-10126,-12062,-13952,-15786,-17557,-19260,-20886,-22431,-23886,-25247,-26509,-27666,-28714,-29648,-30466,-31163,-31738,-32187,-32509,-32702,-32767,-32702,-32509,-32187,-31738,-31163,-30466,-29648,-28714,-27666,-26509,-25247,-23886,-22431,-20886,-19260,-17557,-15786,-13952,-12062,-10126,-8149,-6140,-4107,-2057,0,2057,4107,6140,8149,10126,12062,13952,15786,17557,19260,20886,22431,23886,25247,26509,27666,28714,29648,30466,31163,31738,32187,32509,32702,32767,32702,32509,32187,31738,31163,30466,29648,28714,27666,26509,25247,23886,22431,20886,19260,17557,15786,13952,12062,10126,8149,6140,4107,2057,0,-2057,-4107,-6140,-8149,-10126,-12062,-13952,-15786,-17557,-19260,-20886,-22431,-23886,-25247,-26509,-27666,-28714,-29648,-30466,-31163,-31738,-32187,-32509,-32702,-32767,-32702,-32509,-32187,-31738,-31163,-30466,-29648,-28714,-27666,-26509,-25247,-23886,-22431,-20886,-19260,-17557,-15786,-13952,-12062,-10126,-8149,-6140,-4107,-2057,0,2057,4107,6140,8149,10126,12062,13952,15786,17557,19260,20886,22431,23886,25247,26509,27666,28714,29648,30466,31163,31738,32187,32509,32702,32767,32702,32509,32187,31738,31163,30466,29648,28714,27666,26509,25247,23886,22431,20886,19260,17557,15786,13952,12062,10126,8149,6140,4107,2057,0,-2057,-4107,-6140,-8149,-10126,-12062,-13952,-15786,-17557,-19260,-20886,-22431,-23886,-25247,-26509,-27666,-28714,-29648,-30466,-31163,-31738,-32187,-32509,-32702,-32767,-32702,-32509,-32187,-31738,-31163,-30466,-29648,-28714,-27666,-26509,-25247,-23886,-22431,-20886,-19260,-17557,-15786,-13952,-12062,-10126,-8149,-6140,-4107,-2057,0,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345,12345);
    constant H_re : field:=
    (28420,3794,-16825,-2410,-2179,-1389,-1598,-2256,-680,-3081,-77,-3407,-54,-3133,-618,-2351,-1571,-1331,-2557,-456,-3254,-17,-3404,-170,-2961,-855,-2097,-1850,-1080,-2779,-297,-3350,0,-3350,-297,-2779,-1080,-1850,-2097,-855,-2961,-170,-3404,-17,-3254,-456,-2557,-1331,-1571,-2351,-618,-3133,-54,-3407,-77,-3081,-680,-2256,-1598,-1389,-2179,-2410,-16825,3794);
    constant H_im : field:=
    (0,-25577,-5104,5096,-1456,1533,-1947,1352,-1643,772,-779,-167,271,-1121,1155,-1744,1571,-1795,1367,-1276,647,-340,-335,678,-1227,1427,-1721,1677,-1617,1314,-979,497,0,-497,979,-1314,1617,-1677,1721,-1427,1227,-678,335,340,-647,1276,-1367,1795,-1571,1744,-1155,1121,-271,167,779,-772,1643,-1352,1947,-1533,1456,-5096,5104,25577);
    signal x_in_dly : std_logic_vector(15 downto 0);
    signal h_re_in_dly : std_logic_vector(15 downto 0);
    signal h_im_in_dly : std_logic_vector(15 downto 0);
    signal y_re : field(65535 downto 0);
    signal y_im : field(65535 downto 0);
    signal y_re_dly : std_logic_vector(15 downto 0);
    signal y_im_dly : std_logic_vector(15 downto 0);
begin

    print_p: process
        variable txt: LINE;
        variable i: natural:=0;
    begin
        wait for 55 us;
        for i in 0 to 500 loop
            WRITE(txt, i, RIGHT, 3);
            --WRITE(txt, ": ");
            WRITE(txt, y_re(i), RIGHT, 15);
            --WRITE(txt, ", ");
            WRITE(txt, y_im(i), RIGHT, 15);
            WRITELINE(OUTPUT, txt);
        end loop;
        wait;
    end process print_p;
    
    clk_p: process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process clk_p;

    process
    begin
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        start <= '1', '0' after 10 ns;
        wait;
    end process;

    process
    begin
        wait until done = '1';
        wait for 100 ns;
        assert true report "stop" severity error;
        wait;
    end process;
    
    x_mem: process(clk)
    begin
        if clk = '1' and clk'event then
            if x_index >= X"01AE" then
                x_in_dly <= (others => '0');
            else
                x_in_dly <= CONV_STD_LOGIC_VECTOR(x(IEEE.STD_LOGIC_UNSIGNED.conv_integer(x_index)),16);
            end if;
            x_in <= x_in_dly;
        end if;
    end process;

    h_re_in_dly <= (others => '0') when h_index >= X"040" else
                    CONV_STD_LOGIC_VECTOR(H_re(IEEE.STD_LOGIC_UNSIGNED.conv_integer(h_index)),16);
    h_im_in_dly <= (others => '0') when h_index >= X"040" else
                    CONV_STD_LOGIC_VECTOR(H_im(IEEE.STD_LOGIC_UNSIGNED.conv_integer(h_index)),16);

    h_mem: process(clk)
    begin
        if clk = '1' and clk'event then
            h_re_in <= h_re_in_dly;
            h_im_in <= h_im_in_dly;
        end if;
    end process;

    y_mem: process(clk)
    begin
        if clk = '1' and clk'event then
            y_re_dly <= CONV_STD_LOGIC_VECTOR(y_re(IEEE.STD_LOGIC_UNSIGNED.conv_integer(y_index)),16);
            y_im_dly <= CONV_STD_LOGIC_VECTOR(y_im(IEEE.STD_LOGIC_UNSIGNED.conv_integer(y_index)),16);
            if y_we = '1' then
                y_re(IEEE.STD_LOGIC_UNSIGNED.conv_integer(y_index)) <= IEEE.STD_LOGIC_SIGNED.conv_integer(y_re_out);
                y_im(IEEE.STD_LOGIC_UNSIGNED.conv_integer(y_index)) <= IEEE.STD_LOGIC_SIGNED.conv_integer(y_im_out);
            end if;
            y_re_in <= y_re_dly;
            y_im_in <= y_im_dly;
        end if;
    end process;

    
    overlap_add_i: entity work.overlap_add
      port map(
    clk          => clk,
    rst          => rst,

    start        => start,
    nfft         => nfft,
    scale_sch    => scale_sch,
    L            => L,
    n            => n,
    iq           => iq,

    wave_index   => wave_index,
    x_in         => x_in,
    x_index      => x_index,

    y_re_in      => y_re_in,
    y_im_in      => y_im_in,
    y_re_out     => y_re_out,
    y_im_out     => y_im_out,
    y_index      => y_index,
    y_we         => y_we,

    h_re_in      => h_re_in,
    h_im_in      => h_im_in,
    h_index      => h_index,

    ovfl        => ovfl,
    busy         => busy,
    done         => done
            );
end behav;
