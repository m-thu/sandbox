-- ghdl -a --std=08 ex_3_12_tb.vhd
-- ghdl -r --std=08 ex_3_12_tb --wave=ex_3_12.ghw
-- gtkwave ex_3_12.ghw

entity ex_3_12_tb is
end entity ex_3_12_tb;

architecture testbench of ex_3_12_tb is
	signal clk : bit;
	signal count : natural;
begin
	dut : entity work.counter(behav)
	      port map ( clk, count );

	process
	begin
		for i in 0 to 16 loop
			clk <= '0';
			wait for 20 ns;
			clk <= '1';
			wait for 20 ns;
		end loop;

		wait;
	end process;
end architecture testbench;
