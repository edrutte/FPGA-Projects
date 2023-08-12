library ieee;
use ieee.std_logic_1164.all;

package mem_package is
	type handler_type is array (0 to 63) of std_logic_vector (7 downto 0);
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
	constant debug_handler : handler_type := (

	x"ac", x"08", x"00", x"ff", --sw $t0, 0xff($zero) ;save $t0
	x"40", x"08", x"68", x"00", --mfc0 $t0, 0xd ;get cause reg
	x"31", x"08", x"00", x"7c", --andi $t0, $t0, 0x7c ;isolate cause bits
	x"00", x"08", x"40", x"82", --srl $t0, $t0, 0x2 ;shift cause to base of register
	x"ac", x"08", x"01", x"00", --sw $t0, 0x100($zero) ;store cause
	x"8c", x"08", x"00", x"ff", --lw $t0, 0xff($zero) ;restore $t0
	x"42", x"00", x"00", x"18", --eret

	others => (others => '0')
);
end package mem_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.mem_package.all;

entity InstructionMem is
	Generic (PRG : mem_type := fib_prg);
	Port (
		addr  : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		d_out : out std_logic_vector (31 downto 0) := (others => '0')
	);
end InstructionMem;

architecture SomeRandomName of InstructionMem is

signal mem_data : mem_type := PRG;
signal except_handler : handler_type := debug_handler;

begin

mem_proc : process (addr, mem_data, except_handler) is begin
	case addr(BIT_DEPTH - 1 downto 10) is
		when x"00000" & "00" =>
			d_out <= mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "00"))))&
					mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "01"))))&
					mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "10"))))&
					mem_data(to_integer(unsigned(std_logic_vector'(addr(9 downto 2) & "11"))));
		when x"80000" & "00" =>
			if addr(9 downto 7) = "011" then
				d_out <= except_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "00"))))&
						except_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "01"))))&
						except_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "10"))))&
						except_handler(to_integer(unsigned(std_logic_vector'(addr(6 downto 2) & "11"))));
			else
				d_out <= (others => '0');
			end if;
		when others => d_out <= (others => '0');
	end case;
end process;

end SomeRandomName;
