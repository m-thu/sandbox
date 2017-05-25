-- ghdl -a --std=08 ex_4_9.vhd

entity reg is
	port ( din : in bit_vector(31 downto 0);
	       read, write : in integer range 0 to 15;
	       wen : in bit;
	       dout : out bit_vector(31 downto 0) );
end entity reg;

architecture behav of reg is
begin
	process (din, read, write, wen) is
		type mem is array(0 to 15) of bit_vector (31 downto 0);
		variable memory : mem;
	begin
		if (wen = '1') then
			memory(write) := din;
		end if;
		dout <= memory(read);
	end process;
end architecture behav;
