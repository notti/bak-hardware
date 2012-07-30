library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.all;

entity fft_fsm is
port(
    clk          : in std_logic;
    rst          : in std_logic;

    run          : in std_logic;
    wdone        : in std_logic;
    edone        : in std_logic;
    rdone        : in std_logic;

    start        : out std_logic;
    write        : out std_logic;
    read         : out std_logic;
    busy         : out std_logic;
    done         : out std_logic
);
end fft_fsm;

architecture Structural of fft_fsm is
    type fft_fsm_type is (INACTIVE, START_FFT, FEED_FFT, WAIT_FFT, READ_FFT, DONE_FFT);

    signal state : fft_fsm_type;
begin

    fft_p1: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= INACTIVE;
            else
                case state is
                    when INACTIVE  =>
                        if run = '1' then
                            state <= START_FFT;
                        else
                            state <= INACTIVE;
                        end if;
                    when START_FFT => state <= FEED_FFT;
                    when FEED_FFT  =>
                        if wdone = '1' then
                            state <= WAIT_FFT;
                        else
                            state <= FEED_FFT;
                        end if;
                    when WAIT_FFT  => 
                        if edone = '1' then
                            state <= READ_FFT;
                        else
                            state <= WAIT_FFT;
                        end if;
                    when READ_FFT  =>
                        if rdone = '1' then
                            state <= DONE_FFT;
                        else
                            state <= READ_FFT;
                        end if;
                    when DONE_FFT  => state <= INACTIVE;
                end case;
            end if;
        end if;
    end process fft_p1;

    fft_p2: process(state)
    begin
        case state is
            when INACTIVE  => start <= '0'; write <= '0'; read <= '0'; done <= '0'; busy <= '0';
            when START_FFT => start <= '1'; write <= '0'; read <= '0'; done <= '0'; busy <= '0';
            when FEED_FFT  => start <= '0'; write <= '1'; read <= '0'; done <= '0'; busy <= '0';
            when WAIT_FFT  => start <= '0'; write <= '0'; read <= '0'; done <= '0'; busy <= '1';
            when READ_FFT  => start <= '0'; write <= '0'; read <= '1'; done <= '0'; busy <= '0';
            when DONE_FFT  => start <= '0'; write <= '0'; read <= '0'; done <= '1'; busy <= '0';
        end case;
    end process fft_p2;
end Structural;

