-----------------------------------------------------------
-- Project			: 
-- File				: toggle.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by	    : 
-- last mod. on	    : 
-- contents			: 
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;

library proc;
use proc.all;

entity toggle is
port(
    rst        : in std_logic;
    toggle_in  : in std_logic;
    toggle_out : out std_logic;
    clk_from   : in std_logic;
    clk_to     : in std_logic
);
end toggle;

architecture Structural of toggle is
    type state_in is (LOWIN, TOGIN, WAIT_ACK);
    type state_out is (LOWOUT, TOGOUT);
    signal state_in_r : state_in;
    signal state_out_r : state_out;

    signal ack : std_logic;
    signal ack_crossed : std_logic;
    signal doit : std_logic;
    signal doit_crossed : std_logic;
    signal toggle_out_i : std_logic;
    signal toggle_out_r : std_logic;
    signal toggle_in_r : std_logic;
begin
    toggle_in_r_p: process(clk_from, toggle_in)
    begin
        if rst = '1' then
            toggle_in_r <= '0';
        elsif clk_from'event and clk_from = '1' then
            toggle_in_r <= toggle_in;
        end if;
    end process toggle_in_r_p;
    state_in_p: process(clk_from, toggle_in, toggle_in_r, ack_crossed)
    begin
        if rst = '1' then
            state_in_r <= LOWIN;
            doit <= '0';
        elsif clk_from'event and clk_from = '1' then
            case state_in_r is
                when LOWIN => if toggle_in ='1' and toggle_in_r = '0' then
                               state_in_r <= TOGIN;
                            end if;
                            doit <= '0';
                when TOGIN => if ack_crossed = '1' then
                                   state_in_r <= WAIT_ACK;
                               end if;
                            doit <= '1';
                when WAIT_ACK => if ack_crossed = '0' then
                                    state_in_r <= LOWIN;
                                end if;
                            doit <= '0';
            end case;
        end if;
    end process state_in_p;

    sync_doit_i: entity proc.flag
    port map(
        flag_in     => doit,
        flag_out    => doit_crossed,
        clk         => clk_to
    );
    sync_ack_i: entity proc.flag
    port map(
        flag_in     => ack,
        flag_out    => ack_crossed,
        clk         => clk_from
    );
    

    state_out_p: process(clk_to, doit_crossed)
    begin
        if rst = '1' then
            state_out_r <= LOWOUT;
            ack <= '0';
            toggle_out_i <= '0';
        elsif clk_to'event and clk_to = '1' then
            case state_out_r is
                when LOWOUT => if doit_crossed = '1' then
                               state_out_r <= TOGOUT;
                            end if;
                            ack <= '0';
                            toggle_out_i <= '0';
                when TOGOUT =>  if doit_crossed = '0' then
                                state_out_r <= LOWOUT;
                            end if;
                            toggle_out_i <= '1';
                            ack <= '1';
            end case;
        end if;
    end process state_out_p;
    toggle_out_r_p: process(clk_to, toggle_out_i)
    begin
        if rst = '1' then
            toggle_out_r <= '0';
        elsif clk_to'event and clk_to = '1' then
            toggle_out_r <= toggle_out_i;
        end if;
    end process toggle_out_r_p;
    toggle_out <= toggle_out_i and not toggle_out_r;

end Structural;

