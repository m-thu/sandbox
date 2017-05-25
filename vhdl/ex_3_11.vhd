-- ghdl -a --std=08 ex_3_11.vhd

entity float_alu is
	port ( x, y : in real;
	       f0, f1 : in bit;
	       z : out real );
end entity float_alu;

architecture behav of float_alu is
begin
	z <= x + y when f1 = '0' and f0 = '0'
	     else x - y when f1 = '0' and f0 = '1'
	     else x * y when f1 = '1' and f0 = '0'
	     else x / y;
end architecture behav;
