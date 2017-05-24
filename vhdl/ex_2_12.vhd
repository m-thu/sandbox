-- ghdl -a --std=08 ex_2_12.vhd
-- ghdl -r --std=08 ex_2_12 --wave=ex_2_12.ghw
-- gtkwave ex_2_12.ghw

entity ex_2_12 is
end ex_2_12;

architecture behav of ex_2_12 is
	signal clk : bit;
begin
	clock_gen : process is
	begin
		clk <= '1';
		--wait for 10 ns;
		--wait for 1 ns;
		wait for 1 ps;
		clk <= '0';
		--wait for 10 ns;
		--wait for 1 ns;
		wait for 1 ps;
	end process clock_gen;
end behav;
