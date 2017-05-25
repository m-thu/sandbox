-- ghdl -a --std=08 ex_3_14.vhd

entity average is
	port ( clk : in bit;
	       din : in real;
	       dout : out real );
end entity average;

architecture behav of average is
	constant N : integer := 4;
begin
	process is
		variable sum : real;
	begin
		loop
			sum := 0.0;
			for i in 0 to N-1 loop
				wait until clk = '1';
				sum := sum + din;
			end loop;

			dout <= sum / real(N);
		end loop;
	end process;
end architecture behav;
