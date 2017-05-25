-- ghdl -a --std=08 ex_4_10.vhd

entity priority is
	port ( din : in bit_vector(15 downto 0);
	       index : out natural;
	       one : out bit );
end entity priority;

architecture behav of priority is
begin
	process (din) is
	begin
		for i in din'range loop
			if din(i) = '1' then
				index <= i;
				exit;
			end if;
		end loop;
	end process;

	one <= or din;
end architecture behav;
