-- ghdl -a --std=08 ex_5_19_tb.vhd
-- ghdl -r --std=08 ex_5_19_tb --wave=ex_5_19.ghw
-- gtkwave ex_5_19.ghw

library ieee;
use ieee.std_logic_1164.all;

entity ex_5_19_tb is
end entity ex_5_19_tb;

architecture testbench of ex_5_19_tb is
	signal a0, a1, a2, a3 : bit := '0';
	signal sel0, sel1 : bit := '0';
	signal y : bit;
begin
	dut : entity work.mux4(behav)
	      port map ( a0 => a0, a1 => a1, a2 => a2, a3 => a3,
	                 sel0 => sel0, sel1 => sel1,
			 y => y );

	process
	begin
		a0 <= '1';
		a1 <= '0';
		wait for 20 ns;
		sel0 <= '1';
		wait for 20 ns;
		wait;
	end process;
end architecture testbench;
