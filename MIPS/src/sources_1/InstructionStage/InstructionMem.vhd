library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity InstructionMem is
	Port (
		addr  : in  std_logic_vector (27 downto 0);
		d_out : out std_logic_vector (31 downto 0) := (others => '0')
	);
end InstructionMem;

architecture SomeRandomName of InstructionMem is

type mem_data_type is array (0 to 1023) of std_logic_vector (7 downto 0);
signal mem_data : mem_data_type := 
	(
		--x"00", x"00", x"00", x"00", 
		--x"00", x"00", x"00", x"00",
		
----------psuedocode: 7seg = sw(7 downto 4) * sw(3 downto 0)--------
		--x"20", x"09", x"03", x"FE", --addi $t1, $0, 1022
		--x"8D", x"28", x"00", x"00", --lw $t0, $t1
		--x"20", x"09", x"00", x"0F", --addi $t1, $0, 0x0F
		--x"20", x"0A", x"00", x"F0", --addi $t2, $0, 0xF0
		--x"01", x"28", x"48", x"24", --and $t1, $t1, $t0
		--x"01", x"48", x"50", x"24", --and $t2, $t2, $t0
		--x"20", x"0B", x"00", x"04", --addi $t3, $0, 0x4
		--x"01", x"6A", x"50", x"02", --srl $t2, $t2, $t3
		--x"01", x"49", x"58", x"19", --mul $t3, $t2, $t1
		--x"20", x"09", x"03", x"FF", --addi $t1, $0, 1023
		--x"AD", x"2B", x"00", x"00", --sw $t3, $t1
----------------------------------------------------------------------
--------------------test all instructions-----------------------------
		--x"20", x"08", x"12", x"34", --addi $t0, $zero, 0x1234
		--x"20", x"09", x"43", x"21", --addi $t1, $zero, 0x4321
		--x"01", x"28", x"50", x"20", --add $t2, $t1, $t0
		--x"01", x"28", x"50", x"25", --or $t2, $t1, $t0
		--x"01", x"28", x"50", x"26", --xor $t2, $t1, $t0
		--x"01", x"28", x"50", x"22", --sub $t2, $t1, $t0
		--x"31", x"2a", x"40", x"20", --andi $t2, $t1, 0x4020
		--x"35", x"2a", x"84", x"00", --ori $t2, $t1, 0x8400
		--x"39", x"2a", x"4c", x"08", --xori $t2, $t1, 0x4C08
		--x"01", x"28", x"50", x"19", --mul $t2, $t1, $t0
		--x"20", x"0b", x"00", x"05", --addi $t3, $zero, 0x5
		--x"01", x"6A", x"50", x"04", --sllv $t2, $t1, $t3
		--x"00", x"0A", x"51", x"43", --sra $t2, $t2, 0x5
		--x"ad", x"6a", x"00", x"00", --sw $t2, 0x0($t3)
		--x"8d", x"6c", x"00", x"00", --lw $t4, 0x0($t3)
----------------------------------------------------------------------
----------------------first 10 fib nums-------------------------------
		--x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0 ;save pointer
		--x"20", x"11", x"10", x"23", --addi $s1, $zero, 0x1023 ;7seg pointer
		--x"20", x"08", x"00", x"00", --addi $t0, $zero, 0x0 ;fib(0) = 0
		--x"20", x"09", x"00", x"01", --addi $t1, $zero, 0x1 ;fib(1) = 1
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"ae", x"29", x"00", x"00", --sw $t1 0x0($s1) ;store to 7seg
----------------------------------------------------------------------
----------------------first 10 fib nums using branch------------------
		--x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0 ;save pointer
		--x"20", x"11", x"10", x"23", --addi $s1, $zero, 0x1023 ;7seg pointer
		--x"20", x"12", x"00", x"0b", --addi $s2, $zero, 0xb ;Num fibs to calculate
		--x"20", x"08", x"00", x"00", --addi $t0, $zero, 0x0 ;fib(0) = 0
		--x"20", x"09", x"00", x"01", --addi $t1, $zero, 0x1 ;fib(1) = 1
		--x"01", x"28", x"40", x"20", --add $t0, $t1, $t0 ;next fib
		--x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"12", x"50", x"00", x"05", --beq $s2, $s0, 0x5 ; check if done
		--x"01", x"28", x"48", x"20", --add $t1, $t1, $t0 ;next fib
		--x"ae", x"09", x"00", x"00", --sw $t1, 0x0($s0) ;store
		--x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1 ;store pointer++
		--x"16", x"50", x"ff", x"f8", --bne $s2, $s0, -0x8 ; loop if not done
----------------------------------------------------------------------
------------------------------branch/jump test------------------------
		x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0
		x"20", x"08", x"00", x"01", --addi $t0, $zero, 0x1
		x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
		x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
		x"1d", x"00", x"00", x"0a", --bgtz $t0, 0xa
		x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
		x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
		x"05", x"01", x"00", x"09", --bgez $t0 0x9
		x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
		x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
		x"05", x"00", x"00", x"08", --bltz $t0 0x8
		x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
		x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
		x"19", x"00", x"00", x"07", --blez $t0 0x7
		x"08", x"00", x"00", x"02", --j 0x2
		x"21", x"08", x"ff", x"fd", --addi $t0, $t0, -0x3
		x"08", x"00", x"00", x"05", --j 0x5
		x"21", x"08", x"ff", x"fe", --addi $t0, $t0, -0x2
		x"08", x"00", x"00", x"08", --j 0x8
		x"21", x"08", x"00", x"07", --addi $t0, $t0, 0x7
		x"08", x"00", x"00", x"0b", --j 0xb
		x"21", x"08", x"ff", x"fd", --addi $t0, $t0, -0x3
		x"08", x"00", x"00", x"02", --j 0x2

		others => (others => '0')
	);
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
