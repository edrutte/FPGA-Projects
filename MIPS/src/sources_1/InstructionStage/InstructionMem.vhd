library ieee;
use ieee.std_logic_1164.all;

package mem_package is
	type mem_type is array (0 to 1023) of std_logic_vector (7 downto 0);
	constant fib_prg : mem_type := (

	x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0 ;save pointer
	x"20", x"11", x"10", x"23", --addi $s1, $zero, 0x1023 ;7seg pointer
	x"20", x"08", x"00", x"00", --addi $t0, $zero, 0x0 ;fib(0) = 0
	x"20", x"09", x"00", x"01", --addi $t1, $zero, 0x1 ;fib(1) = 1
	x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
	x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
	x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
	x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
	x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
	x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
	x"ae", x"29", x"00", x"00", --sw $t1 0x0($s1) ;store to 7seg

	others => (others => '0')
);
end package mem_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;

entity InstructionMem is
	Generic (PRG : mem_type := fib_prg);
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
