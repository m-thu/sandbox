-- ghdl -a --std=08 ex_4_12_tb.vhd
-- ghdl -r --std=08 ex_4_12_tb --wave=ex_4_12.ghw
-- gtkwave ex_4_12.ghw

library ieee;
use ieee.std_logic_1164.all;

entity ex_4_12_tb is
end entity ex_4_12_tb;

architecture testbench of ex_4_12_tb is
	signal a, b : std_ulogic_vector(1 downto 0);
	signal y : std_ulogic;
begin
	dut : entity work.gate(behav)
	      port map ( a, b, y );

	process
	begin
		a <= b"00";
		b <= b"00";
		wait for 20 ns;
		a <= b"11";
		b <= b"11";
		wait for 20 ns;

		wait;
	end process;
end architecture testbench;
