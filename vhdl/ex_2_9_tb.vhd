-- ghdl -a --std=08 ex_2_9_tb.vhd
-- ghdl -r --std=08 ex_2_9_tb --wave=ex_2_9.ghw
-- gtkwave ex_2_9.ghw

entity ex_2_9_tb is
end ex_2_9_tb;

architecture testbench of ex_2_9_tb is
	signal clk : bit;
	signal q : integer;
begin
	dut : entity work.counter(behav)
	      port map ( clk, q );

	process
	begin
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
