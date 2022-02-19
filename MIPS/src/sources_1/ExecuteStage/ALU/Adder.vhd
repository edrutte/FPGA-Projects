library ieee;
use ieee.std_logic_1164.ALL;
use work.globals.all;

use ieee.NUMERIC_std.ALL;

entity Adder is
	Generic (
		USE_STRUCTURAL_ARCH : boolean := false	
	);
	Port ( 
		A   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		B   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		OP  : in  std_logic;
		Sum : out std_logic_vector (BIT_DEPTH - 1 downto 0));
end Adder;

architecture SomeRandomName of Adder is

signal carries : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
signal OpB : std_logic_vector (BIT_DEPTH - 1 downto 0);

begin
	with OP select
		OpB <= not B when '1',
				   B when others;
	struct_gen : if USE_STRUCTURAL_ARCH = true generate
		gen_add : for i in 0 to BIT_DEPTH - 1 generate
			add_0 : if i = 0 generate
				adder_0 : entity work.FullAdder
					port map(A => A(i), B => OpB(i), Cin => OP, Cout => carries(i), Sum => Sum(i));
				end generate add_0;
			add_i : if i > 0 generate
				adder_i : entity work.FullAdder
					port map(A => A(i), B => OpB(i), Cin => carries(i - 1), Cout => carries(i), Sum => Sum(i));
			end generate add_i;
		end generate gen_add;
	else generate
		Sum <= std_logic_vector(unsigned(A) + unsigned(OpB) + OP);
	end generate struct_gen;
end SomeRandomName;
