----------------------------------------------------------
-- Project			: 
-- File				: trigger.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: overlap add
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity trigger is
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    typ         : in  std_logic;
    trigger_ext : in  std_logic;
    trigger_int : in  std_logic;
    frame_trg   : in  std_logic;
    arm         : in  std_logic;
    trig        : out std_logic;
);
end trigger;

architecture Structural of trigger is
    type trigger_state is (RESET, WAIT_TRG, TRIGD, INACTIVE, WAIT_FRM);
    signal trg: std_logic;
    signal state: trigger_state;

begin
    process(clk, rst)
    begin
        if clk'event and clk = '1' then
            if rst = '1' then
                state <= RESET;
            else
                case state is
                    when RESET =>
                        if arm = '1' then
                            state <= WAIT_TRG;
                        else
                            state <= RESET;
                        end if;
                    when WAIT_TRG =>
                        if trg = '1' then
                            state <= TRIGD;
                        else
                            state <= WAIT_TRG;
                        end if;
                    when TRIGD =>
                        state <= INACTIVE;
                    when INACTIVE =>
                        if arm = '1' then
                            state <= WAIT_FRM;
                        else
                            state <= INACTIVE;
                        end if;
                    when WAIT_FRM =>
                        if frame_trg = '1' then
                            state <= TRIGD;
                        else
                            state <= WAIT_FRM;
                        end if;
                end case;
            end if;
        end if;
    end process;

    trg <= trigger_int when typ = '0' else
           trigger_ext;
    trig <= '1' when state = TRIGD else
            '0';

end Structural;

