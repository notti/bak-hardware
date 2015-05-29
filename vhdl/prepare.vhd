-----------------------------------------------------------
-- Prepare Inbuf for loading
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity prepare is
    port(
        sample_clk          : in  std_logic;
        sys_clk             : in  std_logic;
        rst                 : in  std_logic;

        arm                 : in  std_logic;
        avg_finished        : in  std_logic;

        sample_enable       : out std_logic;
        do_arm              : out std_logic;
        avg_done            : out std_logic;
        active              : out std_logic;

        avg_clk             : out std_logic
);
end prepare;

architecture Structural of prepare is
    type prepare_state_t is (RESET, WAIT_ARM, SWITCH2SAMPLE, SWITCH2SAMPLE1, SWITCH2SAMPLE2, SWITCH2SAMPLE3, ARM_TRIGGER,
        WAIT_DONE, SWITCH2SYS, SWITCH2SYS1, SWITCH2SYS2, SWITCH2SYS3);
    signal prepare_state : prepare_state_t;

    signal avg_finished_synced : std_logic;
    signal avg_finished_synced_1 : std_logic;
    signal avg_finished_rise : std_logic;
    signal sample_enable_i : std_logic;
begin
    -- on arm:
    --          set en to 0
    --          switch clockmux
    --          enable internal mem mode
    --          really arm
    --          avg_active_i falling edge
    --          disable internal mem mode
    --          switch clockmux
    --          reset en
    --    done,err & idle

    avg_finished_syncer: entity work.flag
    port map(
        flag_in => avg_finished,
        flag_out => avg_finished_synced,
        clk => sys_clk
    );

    process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            avg_finished_synced_1 <= avg_finished_synced;
        end if;
    end process;

    avg_finished_rise <= avg_finished_synced and not avg_finished_synced_1;

    prepare_fsm: process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if rst = '1' then
                prepare_state <= RESET;
                avg_done <= '0';
            else
                case prepare_state is
                    when RESET =>
                        prepare_state <= WAIT_ARM;
                    when WAIT_ARM =>
                        if arm = '1' then
                            prepare_state <= SWITCH2SAMPLE;
                            avg_done <= '0';
                        end if;
                    when SWITCH2SAMPLE =>
                        prepare_state <= SWITCH2SAMPLE1;
                    when SWITCH2SAMPLE1 =>
                        prepare_state <= SWITCH2SAMPLE2;
                    when SWITCH2SAMPLE2 =>
                        prepare_state <= SWITCH2SAMPLE3;
                    when SWITCH2SAMPLE3 =>
                        prepare_state <= ARM_TRIGGER;
                    when ARM_TRIGGER =>
                        prepare_state <= WAIT_DONE;
                    when WAIT_DONE =>
                        if avg_finished_rise = '1' then
                            prepare_state <= SWITCH2SYS ;
                        end if;
                    when SWITCH2SYS =>
                        prepare_state <= SWITCH2SYS1;
                    when SWITCH2SYS1 =>
                        prepare_state <= SWITCH2SYS2;
                    when SWITCH2SYS2 =>
                        prepare_state <= SWITCH2SYS3;
                    when SWITCH2SYS3 =>
                        prepare_state <= WAIT_ARM;
                        avg_done <= '1';
                end case;
            end if;
        end if;
    end process prepare_fsm;

    prepare_out: process(prepare_state)
    begin
        sample_enable_i <= '0';
        do_arm <= '0';
        active <= '0';

        case prepare_state is
            when RESET =>
            when WAIT_ARM =>
            when SWITCH2SAMPLE =>
                sample_enable_i <= '1';
                active <= '1';
            when SWITCH2SAMPLE1 =>
                sample_enable_i <= '1';
                active <= '1';
            when SWITCH2SAMPLE2 =>
                sample_enable_i <= '1';
                active <= '1';
            when SWITCH2SAMPLE3 =>
                sample_enable_i <= '1';
                active <= '1';
            when ARM_TRIGGER =>
                sample_enable_i <= '1';
                do_arm <= '1';
                active <= '1';
            when WAIT_DONE =>
                sample_enable_i <= '1';
                active <= '1';
            when SWITCH2SYS =>
                active <= '1';
            when SWITCH2SYS1 =>
                active <= '1';
            when SWITCH2SYS2 =>
                active <= '1';
            when SWITCH2SYS3 =>
                active <= '1';
        end case;
    end process;

    mem_clk_mux : BUFGMUX_CTRL
    port map (
        O                       => avg_clk,
        I0                      => sample_clk,
        I1                      => sys_clk,
        S                       => not sample_enable_i
    );

    sample_enable <= sample_enable_i;

end Structural;
