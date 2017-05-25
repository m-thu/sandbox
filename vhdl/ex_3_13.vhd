-- ghdl -a --std=08 ex_3_13.vhd

entity counter is
	port ( clk, load : in bit;
	       data : in natural;
	       count : out natural );
end entity counter;

architecture behav of counter is
begin
	process is
		variable c : natural := 15;
	begin
		count <= c;
		loop
			loop
				wait until clk = '1' or load = '1';
				exit when load = '1';

				-- load /= '0'
				c := c - 1 when c /= 0
				     else 15;
				count <= c;
			end loop;

			-- load = '1'
			c := data;
			count <= c;
		end loop;
	end process;
end architecture behav;
