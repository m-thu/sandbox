-- ghdl -a --std=08 ex_3_12.vhd

entity counter is
	port ( clk : in bit;
	       count : out natural );
end entity counter;

architecture behav of counter is
begin
	process is
		variable c : natural := 15;
	begin
		count <= c;
		loop
			wait until clk = '1';
			c := c - 1 when c /= 0
			     else 15;
			count <= c;
		end loop;
	end process;
end architecture behav;
