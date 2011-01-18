-----------------------------------------------------------
-- Project			: 
-- File				: inbuf_ctrl.vhd
-- Author			: Gernot Vormayr
-- created			: Jan, 7th 2011
-- contents			: ctrl
-----------------------------------------------------------
library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
        use UNISIM.VComponents.all;

library inbuf;
        use inbuf.all;

entity inbuf_arb is
port(
        clk                 : in std_logic;
        rst                 : in std_logic;

        read_req            : in std_logic;
        read_ack            : out std_logic;
        active              : in std_logic
);
end inbuf_arb;

architecture Structural of inbuf_arb is
        type inbuf_state is (RESET, AVG, READ);
        signal state         : inbuf_state;
        signal next_state    : inbuf_state;
begin

state_process: process(clk, rst)
begin
    if rst = '1' then
        state <= RESET;
    elsif clk'event and clk = '1' then
		state <= next_state;
    end if;
end process state_process;

next_state_process: process(clk, state, active, read_req)
begin
	next_state <= state;
	case state is
		when RESET => next_state <= AVG;
		when AVG   => if active = '0' and read_req = '1' then
					      next_state <= READ;
					  end if;
		when READ  => if read_req = '0' then
                          next_state <= AVG;
                      end if;
	end case;
end process next_state_process;

output_function_process: process(state)
begin
    case state is
		when RESET => read_ack <= '0';
		when AVG   => read_ack <= '0';
		when READ  => read_ack <= '1';
    end case;
end process output_function_process;

end Structural;


