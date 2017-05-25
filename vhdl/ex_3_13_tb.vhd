-- ghdl -a --std=08 ex_3_13_tb.vhd
-- ghdl -r --std=08 ex_3_13_tb --wave=ex_3_13.ghw
-- gtkwave ex_3_13.ghw

entity ex_3_13_tb is
end entity ex_3_13_tb;

architecture testbench of ex_3_13_tb is
	signal clk, load : bit := '0';
	signal data, count : natural;
begin
	dut : entity work.counter(behav)
	      port map ( clk, load, data, count );

	process
	begin
		for i in 0 to 16 loop
			clk <= '0';
			wait for 20 ns;
			clk <= '1';
			wait for 20 ns;
		end loop;

		data <= 10;
		load <= '1';
		wait for 5 ns;
		load <= '0';

		for i in 0 to 16 loop
			clk <= '0';
			wait for 20 ns;
			clk <= '1';
			wait for 20 ns;
		end loop;

		wait;
	end process;
end architecture testbench;
