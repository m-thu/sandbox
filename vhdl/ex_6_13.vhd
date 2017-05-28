-- ghdl -a --std=08 ex_6_13.vhd
-- ghdl -r --std=08 ex_6_13 --wave=ex_6_13.ghw
-- gtkwave ex_6_13.ghw

library ieee;
use ieee.std_logic_1164.all;

entity ex_6_13 is
end entity ex_6_13;

architecture behav of ex_6_13 is
	signal clk_last_edge : time := 0 ns;

	procedure check_hold(signal clock, data : in std_ulogic;
	                     t_hold : in delay_length;
	                     signal last_edge : inout time) is
	begin
		if rising_edge(clock) then
			last_edge <= now;
		end if;

		if data'event then
			assert now - last_edge >= t_hold
				report "Hold time violation!"
				severity warning;
		end if;
	end procedure check_hold;

	signal clk, d : std_ulogic := '0';
	constant HOLD_TIME : delay_length := 10 ns;
begin
	check_hold(clock => clk, data => d, t_hold => HOLD_TIME,
	           last_edge => clk_last_edge);

	process is
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		d <= '1';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
		wait;
	end process;
end architecture behav;
