library ieee;
use ieee.std_logic_1164.all;

entity HalfAdder is
	Port(
		A, B : in std_logic;
		Sum, Cout : out std_logic := '0'
	);
	end HalfAdder;

architecture arch of HalfAdder is

begin
	
	Cout <= A and B; -- check carry
	sum <= A xor B; -- add bits
	
end;

