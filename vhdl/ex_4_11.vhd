-- ghdl -a --std=08 ex_4_11.vhd

package array_type is
	type int_array is array (natural range <>) of integer;
end package array_type;

use work.array_type.all;

entity max is
	port ( din : in int_array;
	       dout : out integer );
end entity max;

architecture behav of max is
begin
	process (din) is
		variable max : integer;
	begin
		assert din'length /= 0
			report "Array has length zero!"
			severity failure;

		max := din'left;
		for i in din'range loop
			if din(i) > max then
				max := din(i);
			end if;
			dout <= max;
		end loop;
	end process;
end architecture behav;
