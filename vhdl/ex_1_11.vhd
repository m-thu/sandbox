-- ghdl -a --std=08 ex_1_10.vhd
-- ghdl -a --std=08 ex_1_11.vhd

entity mux4 is
	port ( a0, a1, a2, a3,
	       b0, b1, b2 ,b3,
	       sel : in bit;
	       z0, z1, z2, z3 : out bit );
end mux4;

architecture struct of mux4 is
begin
	mux0 : entity work.mux(behav)
	       port map ( a0, b0, sel, z0 );
	mux1 : entity work.mux(behav)
	       port map ( a1, b1, sel, z1 );
	mux2 : entity work.mux(behav)
	       port map ( a2, b2, sel, z2 );
	mux3 : entity work.mux(behav)
	       port map ( a3, b3, sel, z3 );
end struct;
