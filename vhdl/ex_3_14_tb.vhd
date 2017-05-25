-- ghdl -a --std=08 ex_3_14_tb.vhd
-- ghdl -r --std=08 ex_3_14_tb --wave=ex_3_14.ghw
-- gtkwave ex_3_14.ghw

entity ex_3_14_tb is
end entity ex_3_14_tb;

architecture testbench of ex_3_14_tb is
	signal clk : bit;
	signal din, dout : real;
begin
	dut : entity work.average(behav)
	      port map ( clk, din, dout );

	process
	begin
		for i in 0 to 3 loop
			din <= real(i);
			clk <= '0';
			wait for 20 ns;
			clk <= '1';
			wait for 20 ns;
		end loop;

		for i in 4 to 7 loop
			din <= real(i);
			clk <= '0';
			wait for 20 ns;
			clk <= '1';
			wait for 20 ns;
		end loop;

		wait;
	end process;
end architecture testbench;
