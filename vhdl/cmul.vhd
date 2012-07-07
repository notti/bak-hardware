library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

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
    signal a_re_b_re : std_logic_vector(15 downto 0);
    signal a_re_b_im : std_logic_vector(15 downto 0);
    signal a_im_b_re : std_logic_vector(15 downto 0);
    signal a_im_b_im : std_logic_vector(15 downto 0);
    signal c_re_i : std_logic_vector(15 downto 0);
    signal c_im_i : std_logic_vector(15 downto 0);
    signal carry_a_re_b_re : std_ulogic;
    signal carry_a_re_b_im : std_ulogic;
    signal carry_a_im_b_re : std_ulogic;
    signal carry_a_im_b_im : std_ulogic;
    signal ovfla : std_logic;
    signal ovflb : std_logic;
    signal ovflc : std_logic;
    signal ovfld : std_logic;
    signal ovfl_re : std_logic;
    signal ovfl_im : std_logic;
begin
-- c_re = a_re * b_re - a_im * b_im
-- c_im = a_re * b_im + b_re * a_im
    c_re_i <= a_re_b_re + carry_a_re_b_re - a_im_b_im - carry_a_im_b_im;
    c_im_i <= a_re_b_im + carry_a_re_b_im + a_im_b_re + carry_a_im_b_re;
    ovfl_im <= (a_re_b_im(15) and a_im_b_re(15) and (not c_im_i(15))) or ((not a_re_b_im(15)) and (not a_im_b_re(15)) and c_im_i(15));
    ovfl_re <= (a_re_b_re(15) and (not a_im_b_im(15)) and (not c_re_i(15))) or ((not a_re_b_re(15)) and a_im_b_im(15) and c_re_i(15));
    process(clk)
    begin
        if clk = '1' and clk'event then
            c_re <= c_re_i;
            c_im <= c_im_i;
            ovfl <= ovfl_im or ovfl_re or ovfla or ovflb or ovflc or ovfld;
        end if;
    end process;

    mul_a_re_b_re: entity work.mul
    generic map(
        INREG => 0,
        MREG => 1
    )
    port map(
        clk => clk,
        sch => sch,
        ovfl => ovfla,
        a => a_re,
        b => b_re,
        c => a_re_b_re,
        carry => carry_a_re_b_re
    );
    mul_a_im_b_im: entity work.mul
    generic map(
        INREG => 0,
        MREG => 1
    )
    port map(
        clk => clk,
        sch => sch,
        ovfl => ovflb,
        a => a_im,
        b => b_im,
        c => a_im_b_im,
        carry => carry_a_im_b_im
    );
    mul_a_re_b_im: entity work.mul
    generic map(
        INREG => 0,
        MREG => 1
    )
    port map(
        clk => clk,
        sch => sch,
        ovfl => ovflc,
        a => a_re,
        b => b_im,
        c => a_re_b_im,
        carry => carry_a_re_b_im
    );
    mul_a_im_b_re: entity work.mul
    generic map(
        INREG => 0,
        MREG => 1
    )
    port map(
        clk => clk,
        sch => sch,
        ovfl => ovfld,
        a => a_im,
        b => b_re,
        c => a_im_b_re,
        carry => carry_a_im_b_re
    );

end Structural;

