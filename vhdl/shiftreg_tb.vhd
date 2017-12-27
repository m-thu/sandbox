-- ghdl -a --std=93 shiftreg_tb.vhd
-- ghdl -r --std=93 shiftreg_tb --wave=shiftreg_tb.ghw
-- gtkwave shiftreg_tb.ghw

library ieee;
use ieee.std_logic_1164.all;

entity shiftreg_tb is
end entity;

architecture behav of shiftreg_tb is
	signal clk, ser, set, out1, out2, out3, out4 : std_logic := '0';
begin
	dut : entity work.shiftreg
		port map (
			clk => clk, ser => ser, set => set,
			out1 => out1, out2 => out2, out3 => out3, out4 => out4
		);

	process
	begin
		set <= '1';
		wait for 20 ns;
		set <= '0';
		wait for 20 ns;

		for i in 1 to 5 loop
			clk <= '1';
			wait for 20 ns;
			clk <= '0';
			wait for 20 ns;
		end loop;

		ser <= '1';
		wait for 20 ns;

		for i in 1 to 5 loop
			clk <= '1';
			wait for 20 ns;
			clk <= '0';
			wait for 20 ns;
		end loop;

		wait;
	end process;
end architecture;
