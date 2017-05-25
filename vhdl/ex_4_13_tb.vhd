-- ghdl -a --std=08 ex_4_13_tb.vhd
-- ghdl -r --std=08 ex_4_13_tb

entity ex_4_13_tb is
end entity ex_4_13_tb;

architecture testbench of ex_4_13_tb is
	signal a : bit_vector(2 downto 0);
	signal y : bit_vector(7 downto 0);

	type test_stim is record
		stim : bit_vector(2 downto 0);
		delay : time;
		resp : bit_vector(7 downto 0);
	end record test_stim;

	type test_stim_array is array (1 to 3) of test_stim;

	constant test : test_stim_array :=
		((stim => b"000", delay => 20 ns, resp => b"00000001"),
		 (stim => b"001", delay => 20 ns, resp => b"00000010"),
		 (stim => b"111", delay => 20 ns, resp => b"10000000"));
begin
	dut : entity work.decoder(behav)
	      port map ( a, y );

	process
	begin
		for i in test'range loop
			report "Test vector " & to_string(i) & ":";
			a <= test(i).stim;
			wait for test(i).delay;
			assert test(i).resp = y severity failure;
			report "a: " & to_string(a) & ", y: " & to_string(y);
			report "" & LF;
		end loop;

		wait;
	end process;
end architecture testbench;
