-----------------------------------------------------------
-- Automatic mode
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity automatic is
    port(
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        single              : in  std_logic;
        run                 : in  std_logic;
        running             : out std_logic;
        
        trig_arm            : out std_logic;
        avg_done            : in  std_logic;
        stream_valid        : in  std_logic;

        core_start          : out std_logic; 
        core_ov             : in  std_logic;
        core_done           : in  std_logic;

        tx_toggle           : out std_logic;
        tx_toggled          : in std_logic
);
end automatic;

architecture Structural of automatic is
    type auto_state_t is (RESET, START_ACQUIRE, WAIT_ACQUIRE, START_CORE, WAIT_CORE, START_TOGGLE, WAIT_TOGGLE);
    signal auto_state : auto_state_t;
begin

    auto_fsm: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or stream_valid = '0' then
                auto_state <= RESET;
            else
                case auto_state is
                    when RESET =>
                        if run = '1' or single = '1' then
                            auto_state <= START_ACQUIRE;
                        end if;
                    when START_ACQUIRE =>
                        auto_state <= WAIT_ACQUIRE;
                    when WAIT_ACQUIRE =>
                        if avg_done = '1' then
                            auto_state <= START_CORE;
                        end if;
                    when START_CORE =>
                        auto_state <= WAIT_CORE;
                    when WAIT_CORE =>
                        if core_done = '1' then
                            if core_ov = '1' then
                                auto_state <= RESET;
                            else
                                auto_state <= START_TOGGLE;
                            end if;
                        end if;
                    when START_TOGGLE =>
                        auto_state <= WAIT_TOGGLE;
                    when WAIT_TOGGLE =>
                        if tx_toggled = '1' then
                            if run = '1' then
                                auto_state <= START_ACQUIRE;
                            else
                                auto_state <= RESET;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process auto_fsm;

    running <= '0' when auto_state = RESET else
               '1';
    trig_arm <= '1' when auto_state = START_ACQUIRE else
                '0';
    core_start <= '1' when auto_state = START_CORE else
                  '0';
    tx_toggle <= '1' when auto_state = START_TOGGLE else
                 '0';

end Structural;

