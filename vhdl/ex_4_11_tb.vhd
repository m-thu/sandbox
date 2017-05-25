-- ghdl -a --std=08 ex_4_11_tb.vhd
-- ghdl -r --std=08 ex_4_11_tb --wave=ex_4_11.ghw
-- gtkwave ex_4_11.ghw

use work.array_type.all;

entity ex_4_11_tb is
end entity ex_4_11_tb;

architecture testbench of ex_4_11_tb is
	--signal din : int_array(0 to -1); -- test assertion
	signal din : int_array(0 to 2);
	signal dout : integer;
begin
	dut : entity work.max(behav)
	      port map ( din, dout );

	process
	begin
		din <= (1, 2, 3);
		wait for 20 ns;
		din <= (5, 4, 3);
		wait for 20 ns;
		din <= (1, 2, 1);
		wait for 20 ns;

		wait;
	end process;
end architecture testbench;
