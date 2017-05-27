-- ghdl -a --std=08 ex_5_20.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	port ( clk_n, load_en : in std_ulogic;
	       d : in std_ulogic_vector(3 downto 0);
	       q : out std_ulogic_vector(3 downto 0) );
end entity counter;

architecture behav of counter is
		signal cnt : unsigned(3 downto 0) := (others => '0');
begin
	process (clk_n, load_en) is
	begin
		if load_en = '1' then
			cnt <= unsigned(d);
		elsif falling_edge(clk_n) then
			cnt <= cnt + 1;
		end if;
	end process;

	q <= std_ulogic_vector(cnt);
end architecture behav;
