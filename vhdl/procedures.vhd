library IEEE;
use IEEE.std_logic_1164.all;

package procedures is

	subtype t_data is std_logic_vector(15 downto 0);
        
	type t_data_array is array(integer range <>) of t_data;
	type t_cfg_array is array(integer range <>) of std_logic_vector(1 downto 0);

	function and_many(input : std_logic_vector) return std_logic;
	function or_many(input : std_logic_vector) return std_logic;

end package;

package body procedures is

	function and_many(input : std_logic_vector) return std_logic is
		variable result : std_logic;
		variable i : integer;
	begin
		result := '1';
		for i in input'low to input'high
		loop
			result := result and input(i);
		end loop;
		return result;
	end;

	function or_many(input : std_logic_vector) return std_logic is
		variable result : std_logic;
		variable i : integer;
	begin
		result := '0';
		for i in input'low to input'high
		loop
			result := result or input(i);
		end loop;
		return result;
	end;

end procedures;
