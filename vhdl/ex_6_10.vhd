-- ghdl -a --std=08 ex_6_10.vhd
-- ghdl -r --std=08 ex_6_10

entity ex_6_10 is
end entity ex_6_10;

architecture behav of ex_6_10 is
begin
	process is
		type real_array is array(natural range <>) of real;
		constant deviations : real_array := (1.0, 2.0, 3.0);
		variable sum_of_squares : real;

		procedure calc_sos (dev : in real_array; sos : out real) is
			variable tmp : real := 0.0;
		begin
			for i in dev'range loop
				tmp := tmp + dev(i)**2;
			end loop;

			sos := tmp;
		end procedure calc_sos;
	begin
		calc_sos(deviations, sum_of_squares);
		report "Sum of squares: " & to_string(sum_of_squares);
		wait;
	end process;
end architecture behav;
