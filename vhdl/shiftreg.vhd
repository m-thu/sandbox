-- ghdl -a --std=93 shiftreg.vhd

library ieee;
use ieee.std_logic_1164.all;

entity shiftreg is
	port (
		clk, ser, set : in std_logic;
		out1, out2, out3, out4 : out std_logic
	);
end entity;

architecture behav of shiftreg is
	signal reg : std_logic_vector (1 to 4);
begin
	process (clk, set)
	begin
		if set = '1' then
			reg <= (others => '1');
		elsif rising_edge(clk) then
			reg <= ser & reg (1 to 3);
		end if;
	end process;

	out1 <= reg(1);
	out2 <= reg(2);
	out3 <= reg(3);
	out4 <= reg(4);
end architecture;
