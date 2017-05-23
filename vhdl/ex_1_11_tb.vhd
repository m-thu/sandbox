-- ghdl -a --std=08 ex_1_11_tb.vhd
-- ghdl -r --std=08 ex_1_11_tb --wave=ex_1_11.ghw
-- gtkwave ex_1_11.ghw

entity ex_1_11_tb is
end ex_1_11_tb;

architecture testbench of ex_1_11_tb is
	signal a0, a1, a2, a3,
	       b0, b1, b2, b3,
	       sel,
	       z0, z1, z2, z3 : bit;
begin
	dut : entity work.mux4(struct)
	      port map ( a0, a1, a2, a3,
	                 b0, b1, b2, b3,
			 sel,
			 z0, z1, z2, z3 );

	process
	begin
		a0 <= '0';
		a1 <= '0';
		a2 <= '0';
		a3 <= '0';
		b0 <= '1';
		b1 <= '1';
		b2 <= '1';
		b3 <= '1';
		sel <= '0';
		wait for 20 ns;
		sel <= '1';
		wait for 20 ns;
		wait;
	end process;
end testbench;
