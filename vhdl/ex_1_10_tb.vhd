-- ghdl -a --std=08 ex_1_10_tb.vhd
-- ghdl -r --std=08 ex_1_10_tb --wave=ex_1_10.ghw
-- gtkwave ex_1_10.ghw

entity ex_1_10_tb is
end ex_1_10_tb;

architecture testbench of ex_1_10_tb is
	signal a, b, sel, z : bit;
begin
	dut : entity work.mux(behav)
	      port map ( a, b, sel, z );

	process
	begin
		a <= '1';
		b <= '0';
		sel <= '0';
		wait for 20 ns;
		sel <= '1';
		wait for 20 ns;
		wait;
	end process;
end testbench;
