library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

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
signal OpB : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
signal SumTmp : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
begin

	struct_gen : if USE_STRUCTURAL_ARCH generate
		with OP select
		OpB <= not B when '1',
			B when others;
		gen_add : for i in 0 to BIT_DEPTH - 1 generate
			add_0 : if i = 0 generate
				adder_0 : entity work.FullAdder
					port map(A => A(i), B => OpB(i), Cin => OP, Sum => Sum(i), Cout => carries(i));
				end generate add_0;
			add_i : if i > 0 generate
				adder_i : entity work.FullAdder
					port map(A => A(i), B => OpB(i), Cin => carries(i - 1), Sum => Sum(i), Cout => carries(i));
			end generate add_i;
		end generate gen_add;
	end generate struct_gen;

	dsp_gen : if not USE_STRUCTURAL_ARCH generate
		subadd_proc : process(A, B, OP) is begin
			if OP = '1' then
				SumTmp <= std_logic_vector(signed(A) - signed(B));
			else
				SumTmp <= std_logic_vector(signed(A) + signed(B));
			end if;
		end process;
		Sum <= SumTmp(BIT_DEPTH - 1 downto 0);
	end generate dsp_gen;

end SomeRandomName;
