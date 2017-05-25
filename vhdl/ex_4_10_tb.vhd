-- ghdl -a --std=08 ex_4_10_tb.vhd
-- ghdl -r --std=08 ex_4_10_tb --wave=ex_4_10.ghw
-- gtkwave ex_4_10.ghw

entity ex_4_10_tb is
end entity ex_4_10_tb;

architecture testbench of ex_4_10_tb is
	signal din : bit_vector(15 downto 0);
	signal index : natural;
	signal one : bit;
begin
	dut : entity work.priority(behav)
	      port map ( din, index, one );

	process
	begin
		din <= x"0000";
		wait for 20 ns;
		din <= ('1', others => '0');
		wait for 20 ns;
		din <= x"0001";
		wait for 20 ns;

		wait;
	end process;
end architecture testbench;
