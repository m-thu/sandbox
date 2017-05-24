-- ghdl -a --std=08 ex_2_11_tb.vhd
-- ghdl -r --std=08 ex_2_11_tb --wave=ex_2_11.ghw
-- gtkwave ex_2_11.ghw

entity ex_2_11_tb is
end ex_2_11_tb;

architecture testbench of ex_2_11_tb is
	signal data, sum : real;
	signal clk : bit;
begin
	dut : entity work.integrator(behav)
	      port map ( clk, data, sum );

	process
	begin
		data <= 0.5;
		clk <= '0';
		wait for 20 ns;
		clk <= '1';
		wait for 20 ns;
		clk <= '0';
		wait for 20 ns;
		clk <= '1';
		wait for 20 ns;
		clk <= '0';
		wait for 20 ns;
		clk <= '1';
		wait for 20 ns;
		wait;
	end process;
end testbench;
