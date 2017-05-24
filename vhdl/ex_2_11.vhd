-- ghdl -a --std=08 ex_2_11.vhd

entity integrator is
	port ( clk : in bit;
	       data : in real;
	       sum : out real );
end integrator;

architecture behav of integrator is
	signal s : real := 0.0;
begin
	process (clk) is
	begin
		if rising_edge(clk) then
			s <= s + data;
		end if;
	end process;

	sum <= s;
end behav;
