-- ghdl -a --std=08 ex_5_19.vhd

entity mux4 is
	port ( a0, a1, a2, a3 : in bit;
	       sel0, sel1 : in bit;
	       y : out bit );
	constant T_PD : time := 4.5 ns;
end entity mux4;

/*
architecture behav of mux4 is
begin
	with bit_vector'(sel0, sel1) select
		y <= a0 when "00",
		     a1 when "01",
		     a2 when "10",
		     a3 when "11";
end architecture behav;
*/

architecture behav of mux4 is
	signal sel : bit_vector(0 to 1);
begin
	sel <= (sel0, sel1);

	process (all) is
	begin
		case sel is
			when "00" => y <= a0 after T_PD;
			when "01" => y <= a1 after T_PD;
			when "10" => y <= a2 after T_PD;
			when "11" => y <= a3 after T_PD;
		end case;
	end process;
end architecture behav;
