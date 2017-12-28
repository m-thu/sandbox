-- ghdl -a --std=08 events.vhd

library ieee;
use ieee.std_logic_1164.all;

entity events is
	port (
		clk, res, sig, ce : in std_logic;
		evt : out std_logic
	);
end entity;

architecture behav of events is
	signal ff1q, ff2q : std_logic;
begin
	-- D-FF1
	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then
				ff1q <= '0';
			elsif ce = '1' then
				ff1q <= sig;
			end if;
		end if;
	end process;

	-- D-FF2
	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then
				ff2q <= '0';
			else
				ff2q <= ff1q;
			end if;
		end if;
	end process;

	-- EXOR
	evt <= ff1q xor ff2q;
end architecture;
