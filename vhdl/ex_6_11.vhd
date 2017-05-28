-- ghdl -a --std=08 ex_6_11.vhd
-- ghdl -r --std=08 ex_6_11 --wave=ex_6_11.ghw
-- gtkwave ex_6_11.ghw

entity ex_6_11 is
end entity ex_6_11;

architecture behav of ex_6_11 is
	procedure gen_clk(signal reset : in bit;
			  signal clk : out bit) is
	begin
		loop
			clk <= '1', '0' after 1 us;
			wait until reset = '1' for 20 us;
			if reset'event then
				clk <= '0';
				return;
			end if;
		end loop;
	end procedure gen_clk;

	signal syn_clk, rst : bit := '0';
begin
	gen_clk(reset => rst, clk => syn_clk);
	process is
	begin
		wait for 60 us;
		rst <= '1';
		wait for 30 us;
		wait;
	end process;
end architecture behav;
