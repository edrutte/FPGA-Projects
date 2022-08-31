library ieee;
use ieee.std_logic_1164.all;

package mem_package is
	type mem_type is array (0 to 1023) of std_logic_vector (7 downto 0);
end package mem_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.mem_type;

entity InstructionMem is
	Generic (PRG : mem_type := (others => (others => '0')));
	Port (
		addr  : in  std_logic_vector (27 downto 0);
		d_out : out std_logic_vector (31 downto 0) := (others => '0')
	);
end InstructionMem;

architecture SomeRandomName of InstructionMem is

signal mem_data : mem_type := PRG;

begin

mem_proc : process (addr) is begin
	if addr(27 downto 10) = std_logic_vector(to_unsigned(0, 18)) then
		d_out <= mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "00"))))&
			mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "01"))))&
			mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "10"))))&
			mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "11"))));
	else
		d_out <= std_logic_vector(to_unsigned(0, 32));
	end if;
end process;

end SomeRandomName;
