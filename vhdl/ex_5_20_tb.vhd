-- ghdl -a --std=08 ex_5_20_tb.vhd
-- ghdl -r --std=08 ex_5_20_tb --wave=ex_5_20.ghw
-- gtkwave ex_5_20.ghw

library ieee;
use ieee.std_logic_1164.all;

entity ex_5_20_tb is
end entity ex_5_20_tb;

architecture testbench of ex_5_20_tb is
	signal clk_n : std_ulogic := '1';
	signal load_en : std_ulogic := '0';
	signal d, q : std_ulogic_vector(3 downto 0);
begin
	dut : entity work.counter(behav)
	      port map ( clk_n => clk_n, load_en => load_en,
	                 d => d, q => q );

	process
	begin
		d <= "1111";
		load_en <= '1', '0' after 10 ns;

		for i in 0 to 15 loop
			clk_n <= '0';
			wait for 10 ns;
			clk_n <= '1';
			wait for 10 ns;
		end loop;

		wait;
	end process;
end architecture testbench;
