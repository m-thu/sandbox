-- ghdl -a --std=93 io_buffer.vhd

library ieee;
use ieee.std_logic_1164.all;

entity io_buffer is
	port (
		osig, clk, res : in std_logic;
		s : in std_logic_vector (2 downto 0);
		isig : out std_logic;
		iopad : inout std_logic
	);
end entity;

architecture behav of io_buffer is
	signal odir, oreg, omux : std_logic;
begin
	-- Concurrent signal assignments
	isig <= iopad;
	odir <= s(2) xor osig;

	-- D-FF
	process (clk, res)
	begin
		if res = '1' then
			oreg <= '0';
		elsif rising_edge(clk) then
			oreg <= odir;
		end if;
	end process;

	-- MUX (alternative 1)
	omux <= oreg when s(1) = '1'
		else odir;

	-- MUX (alternative 2)
	--with s(1) select omux <=
		--oreg when '1',
		--odir when others;

	-- MUX (alternative 3)
	--process (s(1), oreg, odir)
	--begin
		--case s(1) is
			--when '1'    => omux <= oreg;
			--when others => omux <= odir;
		--end case;
	--end process;

	-- Driver (alternative 1)
	iopad <= omux when s(0) = '1'
		 else 'Z';

	-- Driver (alternative 2)
	--with s(0) select iopad <=
		--omux when '1',
		--'Z' when others;

	-- Driver (alternative 3)
	--process (s(0), omux)
	--begin
		--if s(0) = '1' then
			--iopad <= omux;
		--else
			--iopad <= 'Z';
		--end if;
	--end process;
end architecture;
