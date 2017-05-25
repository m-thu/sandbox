-- ghdl -a --std=08 ex_4_13.vhd

entity decoder is
	port ( a : in bit_vector(2 downto 0);
	       y : out bit_vector(7 downto 0) );
end entity decoder;

architecture behav of decoder is
begin
	with a select
		y <= b"00000001" when b"000",
		     b"00000010" when b"001",
		     b"00000100" when b"010",
		     b"00001000" when b"011",
		     b"00010000" when b"100",
		     b"00100000" when b"101",
		     b"01000000" when b"110",
		     b"10000000" when b"111";
end architecture behav;
