-- ghdl -a --std=08 ex_2_13_tb.vhd
-- ghdl -r --std=08 ex_2_13_tb --wave=ex_2_13.ghw
-- gtkwave ex_2_13.ghw

library ieee;
use ieee.std_logic_1164.all;

entity ex_2_13_tb is
end ex_2_13_tb;

architecture testbench of ex_2_13_tb is
	signal din, en, dout : std_ulogic;
begin
	dut : entity work.tristate(behav)
	      port map ( din, en, dout );

	process
	begin
		wait for 20 ns;
		en <= '0';
		wait for 20 ns;
		en <= '1';
		din <= '0';
		wait for 20 ns;
		din <= '1';
		wait for 20 ns;
		wait;
	end process;
end testbench;
