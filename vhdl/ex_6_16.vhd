-- ghdl -a --std=08 ex_6_16.vhd
-- ghdl -r --std=08 ex_6_16

library ieee;
use ieee.std_logic_1164.all;

entity ex_6_16 is
end entity ex_6_16;

architecture behav of ex_6_16 is
	function valid_edge(signal x : in std_ulogic) return boolean is
	begin
		if (x'last_value = '0' or x'last_value = 'L')
		   and (x = '1' or x = 'H') then
			return true;
		elsif (x'last_value = '1' or x'last_value = 'H')
		      and (x = '0' or x = 'L') then
			return true;
		else
			return false;
		end if;
	end function valid_edge;

	signal x : std_ulogic := 'U';
begin
	process is
	begin
		x <= '1';
		wait until x = '1';
		report "U -> 1: " & to_string(valid_edge(x));
		x <= '0';
		wait until x = '0';
		report "1 -> 0: " & to_string(valid_edge(x));
		x <= 'L';
		wait until x = 'L';
		report "0 -> L: " & to_string(valid_edge(x));
		x <= 'H';
		wait until x = 'H';
		report "L -> H: " & to_string(valid_edge(x));
		wait;
	end process;
end architecture behav;
