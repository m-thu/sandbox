-- ghdl -a --std=08 ex_3_10_tb.vhd
-- ghdl -r --std=08 ex_3_10_tb --wave=ex_3_10.ghw
-- gtkwave ex_3_10.ghw

entity ex_3_10_tb is
end entity ex_3_10_tb;

architecture testbench of ex_3_10_tb is
	signal data_in, data_out, upper, lower : integer;
	signal out_of_limits : bit;
begin
	dut : entity work.limiter(behav)
	      port map ( data_in, lower, upper, data_out, out_of_limits );

	process
	begin
		lower <= 5;
		upper <= 10;
		data_in <= 6;
		wait for 20 ns;
		data_in <= 1;
		wait for 20 ns;
		data_in <= 15;
		wait for 20 ns;
		wait;
	end process;
end architecture testbench;
