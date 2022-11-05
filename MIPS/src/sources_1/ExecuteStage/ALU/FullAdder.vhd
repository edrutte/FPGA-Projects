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
	
	HAdder1 : entity work.HalfAdder
		port map(
			A => A,
			B => B,
			Sum => s_2,
			Cout => s_1
		);

	HAdder2 : entity work.HalfAdder
		port map(
			A => Cin,
			B => s_2,
			Sum => Sum,
			Cout => s_3
		);

	Cout <= s_1 or s_3;

end;

