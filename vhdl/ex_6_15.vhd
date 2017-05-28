-- ghdl -a --std=08 ex_6_15.vhd
-- ghdl -r --std=08 ex_6_15

library ieee;
use ieee.std_logic_1164.all;

entity ex_6_15 is
end entity ex_6_15;

architecture behav of ex_6_15 is
	function weaken(x : in std_ulogic) return std_ulogic is
	begin
		case x is
			when '0'|'L' =>
				return 'L';
			when '1'|'H' =>
				return 'H';
			when 'X'|'W' =>
				return 'W';
			when others =>
				return x;
		end case;
	end function weaken;
begin
	process is
	begin
		report "0: " & to_string(weaken('0'));
		report "L: " & to_string(weaken('L'));
		report "1: " & to_string(weaken('1'));
		report "H: " & to_string(weaken('H'));
		report "X: " & to_string(weaken('X'));
		report "W: " & to_string(weaken('W'));
		report "U: " & to_string(weaken('U'));
		report "Z: " & to_string(weaken('Z'));
		report "-: " & to_string(weaken('-'));
		wait;
	end process;
end architecture behav;
