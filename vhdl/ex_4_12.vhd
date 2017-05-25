-- ghdl -a --std=08 ex_4_12.vhd

library ieee;
use ieee.std_logic_1164.all;

entity gate is
	port ( a, b : in std_ulogic_vector;
	       y : out std_ulogic );
end entity gate;

architecture behav of gate is
begin
	y <= not (or (a and b));
end architecture behav;
