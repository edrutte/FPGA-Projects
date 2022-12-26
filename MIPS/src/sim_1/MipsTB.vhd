library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;
use work.mem_package.mem_type;

entity MipsTB is
--  Port ( );
end MipsTB;

architecture Behavioral of MipsTB is

signal Instruction      : std_logic_vector (31 downto 0) := (others => '0');
signal PC               : std_logic_vector (27 downto 0) := (others => '0');
signal sw               : std_logic_vector (7 downto 0);
signal dataAddr         : std_logic_vector (DATA_ADDR_BITS - 1 downto 0);
signal readData         : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal writeData        : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal we               : std_logic := '0';
signal clk              : std_logic := '0';
signal rst              : std_logic := '1';

constant br_prg : mem_type:= (

	x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0
	x"20", x"11", x"00", x"03", --addi $s1, $zero, 0x3
	x"20", x"12", x"00", x"01", --addi $s2, $zero, 0x1
	x"20", x"08", x"00", x"01", --addi $t0, $zero, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"1d", x"00", x"00", x"12", --bgtz $t0, 0x12
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"05", x"01", x"00", x"11", --bgez $t0 0x11
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"05", x"00", x"00", x"10", --bltz $t0 0x10
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"19", x"00", x"00", x"0f", --blez $t0 0xf
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"11", x"11", x"00", x"0e", --beq $t0, $s1, 0xe
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"15", x"12", x"00", x"0d", --bne $t0, $s2, 0xd
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"08", x"00", x"00", x"04", --j 0x4
	x"00", x"00", x"00", x"00",
	x"08", x"00", x"00", x"07", --j 0x7
	x"21", x"08", x"ff", x"fd", --addi $t0, $t0, -0x3
	x"08", x"00", x"00", x"0a", --j 0xa
	x"21", x"08", x"ff", x"fe", --addi $t0, $t0, -0x2
	x"08", x"00", x"00", x"0d", --j 0xd
	x"21", x"08", x"00", x"07", --addi $t0, $t0, 0x7
	x"08", x"00", x"00", x"10", --j 0x10
	x"21", x"08", x"ff", x"fd", --addi $t0, $t0, -0x3
	x"08", x"00", x"00", x"13", --j 0x13
	x"21", x"08", x"ff", x"fe", --addi $t0, $t0, -0x2
	x"08", x"00", x"00", x"04", --j 0x4
	x"21", x"08", x"ff", x"ff", --addi $t0, $t0, -0x1

	others => (others => '0')
);

constant sub_prg : mem_type := (

	x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0
	x"0c", x"00", x"00", x"09", --jal 0x9
	x"20", x"08", x"11", x"11", --addi $t0, $zero, 0x1111
	x"ae", x"08", x"00", x"00", --sw $t0, 0x0($s0)
	x"20", x"02", x"00", x"34", --addi $v0, $zero, 0x34
	x"00", x"40", x"a8", x"09", --jalr $s5, $v0
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"08", x"00", x"00", x"10", --j 0x10
	x"ae", x"10", x"00", x"00", --sw $s0, 0x0($s0)
	x"ae", x"1f", x"00", x"00", --sw $ra, 0x0($s0)
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1
	x"03", x"e0", x"00", x"08", --jr $ra
	x"20", x"08", x"22", x"22", --addi $t0, $zero, 0x2222
	x"ae", x"15", x"00", x"00", --sw $s5, 0x0($s0)
	x"02", x"a0", x"00", x"08", --jr $s5
	x"22", x"10", x"00", x"01", --addi $s0, $s0, 0x1

	others => (others => '0')
);

constant hilo_prg : mem_type := (

	x"20", x"10", x"00", x"00", --addi $s0, $zero, 0x0
	x"20", x"08", x"13", x"37", --addi $t0, $zero, 0x1337
	x"00", x"08", x"44", x"00", --sll $t0, $t0, 0x10
	x"21", x"08", x"24", x"07", --addi $t0, $t0, 0x2407
	x"21", x"29", x"7a", x"d3", --addi $t1, $t1, 0x7ad3
	x"00", x"09", x"4c", x"00", --sll $t1, $t1, 0x10
	x"21", x"29", x"60", x"47", --addi $t1, $t1, 0x6047
	x"01", x"09", x"00", x"18", --mult $t0, $t1
	x"00", x"00", x"00", x"00", --noop because reads/writes of hi/lo must be seperated by 3 instructions
	x"00", x"00", x"00", x"00", --noop because reads/writes of hi/lo must be seperated by 3 instructions
	x"00", x"00", x"50", x"10", --mfhi $t2
	x"00", x"00", x"58", x"12", --mflo $t3
	x"ae", x"0a", x"00", x"00", --sw $t2, 0x0($s0)
	x"01", x"20", x"00", x"11", --mthi $t1
	x"01", x"00", x"00", x"13", --mtlo $t0
	x"ae", x"0b", x"00", x"01", --sw $t3, 0x1($s0)
	x"00", x"00", x"58", x"10", --mfhi $t3
	x"00", x"00", x"50", x"12", --mflo $t2
	x"ae", x"0b", x"00", x"02", --sw $t3, 0x2($s0)
	x"00", x"00", x"00", x"00", --noop so that wait until we = '1' will catch each store
	x"ae", x"0a", x"00", x"03", --sw $t2, 0x3($s0)

	others => (others => '0')
);

constant except_prg : mem_type := (

	x"21", x"08", x"00", x"42", --addi $t0, $t0 0x42
	x"0c", x"00", x"00", x"03", --jal 0x3
	x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"0d", --break
	x"ac", x"08", x"00", x"00", --sw $t0, 0x0($zero) but shouldn't be reachable

	others => (others => '0')
);

constant test_prg : mem_type := br_prg; --Change this to change the test

begin

memI : entity work.InstructionMem
	Generic map (PRG => test_prg)
	Port map(
		addr => PC,
		d_out => Instruction
	);

cpu : entity work.core
	Port map(
		clk         => clk,
		rst         => rst,
		Instruction => Instruction,
		d_in        => readData,
		we          => we,
		PC          => PC,
		d_out       => writeData,
		dataAddr    => dataAddr
	);

memD : entity work.DataMem
	Port map(
		clk       => clk,
		w_en      => we,
		addr      => dataAddr,
		d_in      => writeData,
		switches  => sw,
		d_out     => readData,
		seven_seg => open
	);
	
clk <= not clk after 5 ns;

br_test : if test_prg = br_prg generate
	test_proc : process is begin
		wait until clk = '0';
		rst <= '0';
		wait until we = '1';
		assert writeData = 32x"1"
			report "Expected write #1 in branch test to be " & to_hex_string(32x"1") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFE"
			report "Expected write #2 in branch test to be " & to_hex_string(x"FFFFFFFE") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFE"
			report "Expected write #3 in branch test to be " & to_hex_string(x"FFFFFFFE") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"5"
			report "Expected write #4 in branch test to be " & to_hex_string(32x"5") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"5"
			report "Expected write #5 in branch test to be " & to_hex_string(32x"5") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"5"
			report "Expected write #6 in branch test to be " & to_hex_string(32x"5") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"4"
			report "Expected write #7 in branch test to be " & to_hex_string(32x"4") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"1"
			report "Expected write #8 in branch test to be " & to_hex_string(32x"1") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFF"
			report "Expected write #9 in branch test to be " & to_hex_string(x"FFFFFFFF") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"6"
			report "Expected write #10 in branch test to be " & to_hex_string(32x"6") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"6"
			report "Expected write #11 in branch test to be " & to_hex_string(32x"6") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"6"
			report "Expected write #12 in branch test to be " & to_hex_string(32x"6") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"5"
			report "Expected write #13 in branch test to be " & to_hex_string(32x"5") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"2"
			report "Expected write #14 in branch test to be " & to_hex_string(32x"2") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"0"
			report "Expected write #15 in branch test to be " & to_hex_string(32x"0") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"0"
			report "Expected write #16 in branch test to be " & to_hex_string(32x"0") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFD"
			report "Expected write #17 in branch test to be " & to_hex_string(x"FFFFFFFD") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFD"
			report "Expected write #18 in branch test to be " & to_hex_string(x"FFFFFFFD") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFC"
			report "Expected write #19 in branch test to be " & to_hex_string(x"FFFFFFFC") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFC"
			report "Expected write #20 in branch test to be " & to_hex_string(x"FFFFFFFC") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"FFFFFFFC"
			report "Expected write #21 in branch test to be " & to_hex_string(x"FFFFFFFC") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"3"
			report "Expected write #22 in branch test to be " & to_hex_string(32x"3") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"3"
			report "Expected write #23 in branch test to be " & to_hex_string(32x"3") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"1"
			report "Expected write #24 in branch test to be " & to_hex_string(32x"1") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert FALSE
			report "End of testbench"
			severity failure;
	end process;
end generate;

hilo_test : if test_prg = hilo_prg generate
	test_proc : process is begin
		wait until clk = '0';
		rst <= '0';
		wait until we = '1';
		assert writeData = x"093824D8"
			report "Expected result of multiply to be " & to_hex_string(x"093824D809929DF1") & " but got " & to_hex_string(writeData) & " for hi instead of " & to_hex_string(x"093824D8")
			severity error;
		wait until we = '1';
		assert writeData = x"09929DF1"
			report "Expected result of multiply to be " & to_hex_string(x"093824D809929DF1") & " but got " & to_hex_string(writeData) & " for lo instead of " & to_hex_string(x"09929DF1")
			severity error;
		wait until we = '1';
		assert writeData = x"7AD36047"
			report "Expected round-trip of " & to_hex_string(x"7AD36047") & " through hi to remain unchanged but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = x"13372407"
			report "Expected round-trip of " & to_hex_string(x"13372407") & " through lo to remain unchanged but got " & to_hex_string(writeData)
			severity error;
		wait until clk = '0';
		wait until clk = '0'; --wait a couple of clocks for data to get to memory
		assert FALSE
			report "End of testbench"
			severity failure;
	end process;
end generate;

sub_test : if test_prg = sub_prg generate
	test_proc : process is begin
		wait until clk = '0';
		rst <= '0';
		wait until we = '1';
		assert writeData = 32x"c"
			report "Expected return address for sub #1 to be " & to_hex_string(32x"c") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"2222"
			report "Expected sub #1 to return " & to_hex_string(32x"2222") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"1c"
			report "Expected return address for sub #2 to be " & to_hex_string(32x"1c") & " but got " & to_hex_string(writeData)
			severity error;
		wait until we = '1';
		assert writeData = 32x"3"
			report "Expected sub #2 to increment s0 to " & to_hex_string(32x"3") & " but got " & to_hex_string(writeData)
			severity error;
		wait until clk = '0';
		wait until clk = '0'; --wait a couple of clocks for data to get to memory
		assert FALSE
			report "End of testbench"
			severity failure;
	end process;
end generate;

except_test : if test_prg = except_prg generate
	test_proc : process is begin
		wait until clk = '0';
		rst <= '0';
		wait until we = '1';

		--write me

		assert FALSE
			report "End of testbench"
			severity failure;
	end process;
end generate;

sw <= "10010110";

end Behavioral;
