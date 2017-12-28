-- Testbench for events.vhd

-- ghdl -a --std=08 events_tb.vhd
-- ghdl -r --std=08 events_tb --wave=events_tb.ghw
-- gtkwave events_tb.ghw

library ieee;
use ieee.std_logic_1164.all;

entity events_tb is
end entity;

architecture behav of events_tb is
	constant T : time := 20 ns; -- 50 MHz
	signal clk, res, sig, ce, evt : std_logic := '0';
begin
	-- Unit under test
	uut : entity work.events
		port map (clk => clk, res => res, sig => sig,
			  ce => ce, evt => evt);

	-- Clock generator
	process
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process;

	-- Stimuli
	process
	begin
		res <= '1';
		wait for 2*T;
		res <= '0';

		wait for 2*T;
		sig <= '1';
		wait for T;
		sig <= '0';
		wait for T;

		ce <= '1';
		sig <= '1';
		wait for 3*T;
		sig <= '0';
		wait for 3*T;
		sig <= '1';
		wait for T;

		res <= '1';
		wait for 2*T;

		assert false report "Testbench finished!"
			severity failure;
	end process;
end architecture;
