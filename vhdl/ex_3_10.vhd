-- ghdl -a --std=08 ex_3_10.vhd

entity limiter is
	port ( data_in, lower, upper : in integer;
	       data_out : out integer;
	       out_of_limits : out bit );
end entity limiter;

architecture behav of limiter is
begin
	process (data_in, lower, upper) is
	begin
		if data_in < lower then
			data_out <= lower;
			out_of_limits <= '1';
		elsif data_in > upper then
			data_out <= upper;
			out_of_limits <= '1';
		else
			data_out <= data_in;
			out_of_limits <= '0';
		end if;
	end process;
end architecture behav;
