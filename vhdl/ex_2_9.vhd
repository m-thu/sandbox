-- ghdl -a --std=08 ex_2_9.vhd

entity counter is
	port ( clk : in bit;
	       q : out integer );
end counter;

architecture behav of counter is
begin
	process (clk) is
		variable count : integer := 0;
	begin
		if rising_edge(clk) then	
			count := count + 1;
			q <= count;
		end if;
	end process;
end behav;
