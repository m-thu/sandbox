-- ghdl -a --std=08 ex_3_15.vhd
-- ghdl -r --std=08 ex_3_15

entity ex_3_15 is
end entity ex_3_15;

architecture behav of ex_3_15 is
begin
	assert false report "note" severity note;
	assert false report "warning" severity warning;
	assert false report "error" severity error;
	assert false report "failure" severity failure;
end architecture behav;
