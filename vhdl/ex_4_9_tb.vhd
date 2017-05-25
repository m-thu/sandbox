-- ghdl -a --std=08 ex_4_9_tb.vhd
-- ghdl -r --std=08 ex_4_9_tb --wave=ex_4_9.ghw
-- gtkwave ex_4_9.ghw

entity ex_4_9_tb is
end entity ex_4_9_tb;

architecture testbench of ex_4_9_tb is
	signal din, dout : bit_vector(31 downto 0);
	signal read, write : integer range 0 to 15;
	signal wen : bit := '0';
begin
	dut : entity work.reg(behav)
	      port map ( din, read, write, wen, dout );

	process
	begin
		read <= 1;
		wait for 20 ns;
		wen <= '1';
		write <= 1;
		din <= x"ffffffff";
		wait for 20 ns;
		wen <= '0';
		write <= 0;
		wait for 20 ns;

		wait;
	end process;
end architecture testbench;
