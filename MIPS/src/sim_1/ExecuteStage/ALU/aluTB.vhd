-------------------------------------------------
--  File:          aluTB.vhd
--
--  Entity:        aluTB
--  Architecture:  Testbench
--  Author:        Jason Blocklove
--  Created:       07/29/19
--  Modified:	   7/18/2022 By Evan Ruttenberg
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                aluTB
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aluTB is
end aluTB;

architecture tb of aluTB is
function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;

component alu4 IS
    Port ( A  : in  std_logic_vector(31 downto 0);
           B  : in  std_logic_vector(31 downto 0);
           OP : in  std_logic_vector(3 downto 0);
           Y  : out std_logic_vector(31 downto 0)
          );
end component;

signal A  : std_logic_vector(31 downto 0);
signal B  : std_logic_vector(31 downto 0);
signal OP : std_logic_vector(3 downto 0);
signal Y  : std_logic_vector(31 downto 0);

type alu_tests is record
	-- Test Inputs
	A  : std_logic_vector(31 downto 0);
	B  : std_logic_vector(31 downto 0);
	OP : std_logic_vector(3 downto 0);
	-- Test Outputs
	Y  : std_logic_vector(31 downto 0);
end record;

type test_array is array (natural range <>) of alu_tests;

--TODO: Add at least 2 cases for each operation in the ALU
constant tests : test_array :=(
	(A => x"12345678", B => x"FEDCBA98", OP => "1010", Y => x"12141218"),
	(A => x"02155ABC", B => x"FFFF8DAC", OP => "1010", Y => x"021508AC"),
	(A => x"12344321", B => x"55824231", OP => "0100", Y => x"67B68552"),
	(A => x"7359AC12", B => x"00003291", OP => "0100", Y => x"7359DEA3"),
	(A => x"00004059", B => x"00009816", OP => "0110", Y => x"263A5FA6"),
	(A => x"0000A6DB", B => x"00000000", OP => "0110", Y => x"00000000"),
	(A => x"0000CAB9", B => x"00000001", OP => "0110", Y => x"0000CAB9"),
	(A => x"00007E62", B => x"0000FF38", OP => "0110", Y => x"7DFF4370"),
	(A => x"0000DEC0", B => x"0000DED0", OP => "0110", Y => x"C1DF7C00"),
	(A => x"FB5C9EEC", B => x"FC125888", OP => "1000", Y => x"FF5EDEEC"),
	(A => x"E80FD2FB", B => x"00007952", OP => "1000", Y => x"E80FFBFB"),
	(A => x"479D0B16", B => x"364482F6", OP => "1011", Y => x"71D989E0"),
	(A => x"80CE94E0", B => x"00003C9D", OP => "1011", Y => x"80CEA87D"),
	(B => x"D0C9F331", A => x"0000000E", OP => "1100", Y => x"7CCC4000"),
	(B => x"FB2AD16D", A => x"00000010", OP => "1100", Y => x"D16D0000"),
	(B => x"5431F3AF", A => x"00000009", OP => "1110", Y => x"002A18F9"),
	(B => x"A6A59075", A => x"00000016", OP => "1110", Y => x"FFFFFE9A"),
	(B => x"861EA09B", A => x"00000001", OP => "1101", Y => x"430F504D"),
	(B => x"73B74FC3", A => x"0000001D", OP => "1101", Y => x"00000003"),
	(A => x"1EB18E92", B => x"F21AC77A", OP => "0101", Y => x"2C96C718"),
	(A => x"9E36B1FC", B => x"00003E8D", OP => "0101", Y => x"9E36736F")
);

begin

aluN_0 : alu4
    port map (
			A  => A,
			B  => B,
            OP => OP,
            Y  => Y
		);

stim_proc : process is begin
	for i in tests'range loop
		A <= tests(i).A;
		B <= tests(i).B;
		OP <= tests(i).OP;
		wait for 100 ns;
		assert Y = tests(i).Y 
			report "Expected: " & to_string(tests(i).Y) & " Got: " & to_string(Y) & " OP: " & to_string(tests(i).OP)
			severity error;
	end loop;
	assert false
		report "Testbench Concluded."
		severity failure;
end process;
end tb;
