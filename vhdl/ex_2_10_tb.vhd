-- ghdl -a --std=08 ex_2_10_tb.vhd
-- ghdl -r --std=08 ex_2_10_tb --wave=ex_2_10.ghw
-- gtkwave ex_2_10.ghw

entity ex_2_10_tb is
end ex_2_10_tb;

architecture testbench of ex_2_10_tb is
	signal a, b, y : integer := 0;
	signal sel : bit;
begin
	dut : entity work.alu(behav)
	      port map ( a, b, sel, y );

	process
	begin
		a <= 2;
		b <= 1;
		sel <= '0';
		wait for 20 ns;
		sel <= '1';
		wait for 20 ns;
		wait;
	end process;
end testbench;
