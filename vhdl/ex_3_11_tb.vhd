-- ghdl -a --std=08 ex_3_11_tb.vhd
-- ghdl -r --std=08 ex_3_11_tb --wave=ex_3_11.ghw
-- gtkwave ex_3_11.ghw

entity ex_3_11_tb is
end entity ex_3_11_tb;

architecture testbench of ex_3_11_tb is
	signal x, y, z : real;
	signal f0, f1 : bit;
begin
	dut : entity work.float_alu(behav)
	      port map ( x, y, f0, f1, z );

	process
	begin
		x <= 1.0;
		y <= 2.0;

		-- addition
		f1 <= '0';
		f0 <= '0';
		wait for 20 ns;

		-- subtraction
		f1 <= '0';
		f0 <= '1';
		wait for 20 ns;

		-- multiplication
		f1 <= '1';
		f0 <= '0';
		wait for 20 ns;

		-- division
		f1 <= '1';
		f0 <= '1';
		wait for 20 ns;

		wait;
	end process;
end architecture testbench;
