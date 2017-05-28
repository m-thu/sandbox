-- ghdl -a --std=08 ex_6_18.vhd
-- ghdl -r --std=08 ex_6_18

entity ex_6_18 is
end entity ex_6_18;

architecture behav of ex_6_18 is
	function "and" (left, right : integer) return boolean is
		variable l, r : boolean;
	begin
		l := false when left = 0 else true when left /= 0;
		r := false when right = 0 else true when right /= 0;
		return l and r;
	end function "and";

	function "or" (left, right : integer) return boolean is
		variable l, r : boolean;
	begin
		l := false when left = 0 else true when left /= 0;
		r := false when right = 0 else true when right /= 0;
		return l or r;
	end function "or";
begin
	process is
	begin
		report "0 and 1 = " & to_string(0 and 1);
		report "1 and 1 = " & to_string(1 and 1);
		report "0 or  0 = " & to_string(0 or  0);
		report "0 or  1 = " & to_string(0 or  1);
		wait;
	end process;
end architecture behav;
