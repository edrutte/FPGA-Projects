library ieee;
use ieee.std_logic_1164.all;

entity FullAdder is
	Port(
		A, B, Cin : in std_logic;
		Sum, Cout : out std_logic := '0'
	);
	end FullAdder;

architecture arch of FullAdder is

signal s_1, s_2, s_3 : std_logic := '0';

begin
	
	s_1 <= A and B; -- internal signal 1
	s_2 <= A and Cin; -- internal signal 2
	s_3 <= B and Cin; -- internal signal 3
	Cout <= s_1 or s_2 or s_3; -- check carry
	sum <= A xor B xor Cin; -- add bits

end;

