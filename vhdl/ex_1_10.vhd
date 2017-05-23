-- ghdl -a --std=08 ex_1_10.vhd

entity mux is
	port ( a, b, sel : in bit;
	       z : out bit );
end mux;

architecture behav of mux is
begin
	with sel select z <=
		a when '0',
		b when '1';
end behav;
