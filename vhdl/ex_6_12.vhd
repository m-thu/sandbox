-- ghdl -a --std=08 ex_6_12.vhd
-- ghdl -r --std=08 ex_6_12

entity ex_6_12 is
end entity ex_6_12;

architecture behav of ex_6_12 is
	subtype size_type is integer range 1 to 8;

	procedure align_address(addr : out bit_vector;
	                        size : in size_type := 4) is
	begin
		assert size = 1 or size = 2 or size = 4 or size = 8
			severity failure;
		assert addr'ascending = false
			severity failure;

		case size is
			when 1 =>
				null;
			when 2 =>
				addr(addr'right)   := '0';
			when 4 =>
				--addr(addr'right)   := '0';
				--addr(addr'right+1) := '0';
				addr(addr'right+1 downto addr'right) := "00";
			when 8 =>
				--addr(addr'right)   := '0';
				--addr(addr'right+1) := '0';
				--addr(addr'right+2) := '0';
				addr(addr'right+2 downto addr'right) := "000";
			when others =>
				null;
		end case;
	end procedure align_address;
begin
	process is
		variable address : bit_vector(7 downto 0) := (others => '1');
	begin
		align_address(addr => address, size => 1);
		report "address = " & to_string(address) & ", size = 1";
		align_address(address, 2);
		report "address = " & to_string(address) & ", size = 2";
		align_address(address);
		report "address = " & to_string(address) & ", size = 4";
		address := (others => '1');
		align_address(address, 4);
		report "address = " & to_string(address) & ", size = 4";
		address := (others => '1');
		align_address(address, open);
		report "address = " & to_string(address) & ", size = 4";
		align_address(address, 8);
		report "address = " & to_string(address) & ", size = 8";
		wait;
	end process;
end architecture behav;
