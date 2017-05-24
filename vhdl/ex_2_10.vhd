-- ghdl -a --std=08 ex_2_10.vhd

entity alu is
	port ( a, b : in integer;
	       sel : in bit;
	       y : out integer );
end alu;

architecture behav of alu is
begin
	process (a, b, sel) is
	begin
		if sel = '0' then
			y <= a + b;
		else
			y <= a - b;
		end if;
	end process;
end behav;
