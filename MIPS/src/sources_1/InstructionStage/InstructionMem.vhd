library ieee;
use ieee.std_logic_1164.all;

package mem_package is
	type handler_type is array (0 to 127) of std_logic_vector (7 downto 0);
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
	constant inf_loop_handler : handler_type := (

	x"10", x"00", x"ff", x"ff", --beq $zero, $zero -0x1

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
signal break_handler, trap_handler, syscall_handler : handler_type := inf_loop_handler;

begin

mem_proc : process (addr, break_handler, mem_data, syscall_handler, trap_handler) is begin
	case addr(27 downto 24) is
		when "0000" =>
			if addr(23 downto 10) = std_logic_vector(to_unsigned(0, 14)) then
				d_out <= mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "00"))))&
						mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "01"))))&
						mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "10"))))&
						mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "11"))));
			else
				d_out <= (others => '0');
			end if;
		when "0001" =>
			d_out <= trap_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "00"))))&
					trap_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "01"))))&
					trap_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "10"))))&
					trap_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "11"))));
		when "0010" =>
			d_out <= break_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "00"))))&
					break_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "01"))))&
					break_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "10"))))&
					break_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "11"))));
		when "0011" =>
			d_out <= syscall_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "00"))))&
					syscall_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "01"))))&
					syscall_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "10"))))&
					syscall_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "11"))));
		when others => d_out <= (others => '0'); --reserved for new exception types
	end case;
end process;

end SomeRandomName;
