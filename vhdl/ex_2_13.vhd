-- ghdl -a --std=08 ex_2_13.vhd

library ieee;
use ieee.std_logic_1164.all;

entity tristate is
	port ( din, en : in std_ulogic;
	       dout : out std_ulogic );
end tristate;

architecture behav of tristate is
begin
	process (din, en) is
	begin
		if en = '0' or en = 'L' then
			dout <= 'Z';
		elsif (en = '1' or en = 'H') and (din = '0' or din = 'L') then
			dout <= '0';
		elsif (en = '1' or en = 'H') and (din = '1' or din = 'H') then
			dout <= '1';
		else
			dout <= 'X';
		end if;
	end process;
end behav;
