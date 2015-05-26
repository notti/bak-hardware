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
        stream_valid        : in  std_logic;

        sys_enable          : out std_logic;
        sample_enable       : out std_logic;
        do_arm              : out std_logic;
        avg_done            : out std_logic;
        active              : out std_logic;

        avg_clk             : out std_logic
);
end prepare;

architecture Structural of prepare is
    type prepare_state_t is (RESET, WAIT_ARM, DISABLE, SWITCH2SAMPLE, SWITCH2SAMPLE1, SWITCH2SAMPLE2, SWITCH2SAMPLE3,
        ENABLE_MEM, ARM_TRIGGER, WAIT_DONE, DISABLE_MEM, SWITCH2SYS, SWITCH2SYS1, SWITCH2SYS2, SWITCH2SYS3, ENABLE);
    signal prepare_state : prepare_state_t;

    signal avg_finished_synced : std_logic;
    signal clk_is_sys      : std_logic;
    signal clk_is_sys_n    : std_logic;
    signal sample_enable_unsynced : std_logic;
    signal sample_enable_ack : std_logic;
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
                            prepare_state <= DISABLE;
                            avg_done <= '0';
                        end if;
                    when DISABLE =>
                        prepare_state <= SWITCH2SAMPLE;
                    when SWITCH2SAMPLE =>
                        prepare_state <= SWITCH2SAMPLE1;
                    when SWITCH2SAMPLE1 =>
                        prepare_state <= SWITCH2SAMPLE2;
                    when SWITCH2SAMPLE2 =>
                        prepare_state <= SWITCH2SAMPLE3;
                    when SWITCH2SAMPLE3 =>
                        prepare_state <= ENABLE_MEM;
                    when ENABLE_MEM =>
                        if sample_enable_ack = '1' then
                            prepare_state <= ARM_TRIGGER;
                        end if;
                    when ARM_TRIGGER =>
                        prepare_state <= WAIT_DONE;
                    when WAIT_DONE =>
                        if avg_finished_synced = '1' then
                            prepare_state <= DISABLE_MEM;
                        end if;
                    when DISABLE_MEM =>
                        if sample_enable_ack = '0' then
                            prepare_state <= SWITCH2SYS;
                        end if;
                    when SWITCH2SYS =>
                        prepare_state <= SWITCH2SYS1;
                    when SWITCH2SYS1 =>
                        prepare_state <= SWITCH2SYS2;
                    when SWITCH2SYS2 =>
                        prepare_state <= SWITCH2SYS3;
                    when SWITCH2SYS3 =>
                        prepare_state <= ENABLE;
                    when ENABLE =>
                        prepare_state <= WAIT_ARM;
                        avg_done <= '1';
                end case;
            end if;
        end if;
    end process prepare_fsm;

    prepare_out: process(prepare_state)
    begin
        clk_is_sys <= '1';
        sys_enable <= '1';
        sample_enable_unsynced <= '0';
        do_arm <= '0';
        active <= '0';

        case prepare_state is
            when RESET =>
            when WAIT_ARM =>
            when DISABLE =>
                sys_enable <= '0';
                active <= '1';
            when SWITCH2SAMPLE =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                active <= '1';
            when SWITCH2SAMPLE1 =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                active <= '1';
            when SWITCH2SAMPLE2 =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                active <= '1';
            when SWITCH2SAMPLE3 =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                active <= '1';
            when ENABLE_MEM =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                sample_enable_unsynced <= '1';
                active <= '1';
            when ARM_TRIGGER =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                sample_enable_unsynced <= '1';
                do_arm <= '1';
                active <= '1';
            when WAIT_DONE =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                sample_enable_unsynced <= '1';
                active <= '1';
            when DISABLE_MEM =>
                sys_enable <= '0';
                clk_is_sys <= '0';
                sample_enable_unsynced <= '0';
                active <= '1';
            when SWITCH2SYS =>
                sys_enable <= '0';
                clk_is_sys <= '1';
                active <= '1';
            when SWITCH2SYS1 =>
                sys_enable <= '0';
                clk_is_sys <= '1';
                active <= '1';
            when SWITCH2SYS2 =>
                sys_enable <= '0';
                clk_is_sys <= '1';
                active <= '1';
            when SWITCH2SYS3 =>
                sys_enable <= '0';
                clk_is_sys <= '1';
                active <= '1';
            when ENABLE =>
                sys_enable <= '1';
                active <= '0';
        end case;
    end process;

    sync_sample_enable: entity work.flag
    port map(
        flag_in     => sample_enable_unsynced,
        flag_out    => sample_enable_i,
        clk         => sample_clk
    );

    sync_sample_enable_back: entity work.flag
    port map(
        flag_in     => sample_enable_i,
        flag_out    => sample_enable_ack,
        clk         => sys_clk 
    );
    
    sample_enable <= sample_enable_i;

    clk_is_sys_n <= not clk_is_sys;

    mem_clk_mux : BUFGCTRL
    generic map(
        PRESELECT_I1 => TRUE
    )
    port map (
        O                       => avg_clk,
        I0                      => sample_clk,
        I1                      => sys_clk,
        CE0                     => '1',
        CE1                     => '1',
        S0                      => clk_is_sys_n,
        S1                      => clk_is_sys,
        IGNORE0                 => '0',
        IGNORE1                 => not stream_valid

    );

end Structural;
