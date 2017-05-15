library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bincnt is
	port (clk : in std_logic;
	      led1, led2, led3, led4, led5 : out std_logic);
end bincnt;

architecture behavioral of bincnt is
	signal cnt : unsigned (4 downto 0) := (others => '0');
begin
	process (clk)
		variable delay : unsigned (23 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if delay = 2_999_999 then
				cnt <= cnt + 1;
				delay := x"000000";
			else
				delay := delay + 1;
			end if;
		end if;
	end process;

	(led5,led4,led3,led2,led1) <= std_logic_vector(cnt);
end behavioral;
