----------------------------------------------------------
-- Project			: 
-- File				: reciever.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- contents			: overlap add
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.all;

entity reciever is
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
end reciever;

architecture Structural of reciever is
begin

end Structural;

