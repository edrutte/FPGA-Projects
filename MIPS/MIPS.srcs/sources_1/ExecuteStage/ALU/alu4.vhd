library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globals.all;

entity alu4 is
	GENERIC (N : INTEGER := BIT_DEPTH); --bit width
	PORT (
		A	: IN std_logic_vector(N-1 downto 0);
		B	: IN std_logic_vector(N-1 downto 0);
		OP      : IN std_logic_vector(3 downto 0);
		Y	: OUT std_logic_vector(N-1 downto 0));
end alu4;

architecture structural of alu4 is
-- Declare teh inverter component
	Component notN is
		GENERIC ( N : INTEGER := N); -- bit width
		PORT (
			A : IN std_logic_vector(N-1 downto 0);
			Y : OUT std_logic_vector(N-1 downto 0)
		);
	end Component;
	
	Component andN is
		GENERIC ( N : INTEGER := N); -- bit width
		PORT (
			A : IN std_logic_vector(N-1 downto 0);
			B : IN std_logic_vector(N-1 downto 0);
			Y : OUT std_logic_vector(N-1 downto 0)
		);
	end Component;
	
	Component orN is
		GENERIC ( N : INTEGER := N); -- bit width
		PORT (
			A : IN std_logic_vector(N-1 downto 0);
			B : IN std_logic_vector(N-1 downto 0);
			Y : OUT std_logic_vector(N-1 downto 0)
		);
	end Component;
	
	Component xorN is
		GENERIC ( N : INTEGER := N); -- bit width
		PORT (
				A : IN std_logic_vector(N-1 downto 0);
				B : IN std_logic_vector(N-1 downto 0);
				Y : OUT std_logic_vector(N-1 downto 0)
			 );
	end Component;
	
-- Declare the shift left component
	Component sllN is
		GENERIC (N : INTEGER := N); --bit width
		PORT (
				A		  : IN std_logic_vector(N-1 downto 0);
				SHIFT_AMT  : IN std_logic_vector(4 downto 0);
				Y		  : OUT std_logic_vector(N-1 downto 0)
			 );
	end Component;
	
	Component srlN is
		GENERIC (N : INTEGER := N); --bit width
		PORT (
				A		  : IN std_logic_vector(N-1 downto 0);
				SHIFT_AMT  : IN std_logic_vector(4 downto 0);
				Y		  : OUT std_logic_vector(N-1 downto 0)
			 );
	end Component;
	
	Component sraN is
		GENERIC (N : INTEGER := N); --bit width
		PORT (
				A		  : IN std_logic_vector(N-1 downto 0);
				SHIFT_AMT  : IN std_logic_vector(4 downto 0);
				Y		  : OUT std_logic_vector(N-1 downto 0)
			 );
	end Component;
	signal not_result : std_logic_vector (N-1 downto 0);
	signal and_result : std_logic_vector (N-1 downto 0);
	signal or_result : std_logic_vector (N-1 downto 0);
	signal xor_result : std_logic_vector (N-1 downto 0);
	signal sll_result : std_logic_vector (N-1 downto 0);
	signal srl_result : std_logic_vector (N-1 downto 0);
	signal sra_result : std_logic_vector (N-1 downto 0);
	signal add_result : std_logic_vector (N-1 downto 0);
	signal mul_result : std_logic_vector (N-1 downto 0);
begin
-- Instantiate the inverter
not_comp: notN
	generic map ( N => N)
	port map ( A => A, Y => not_result );

and_comp: andN
	generic map ( N => N)
	port map ( A => A, B => B, Y => and_result );

or_comp: orN
	generic map ( N => N)
	port map ( A => A, B => B, Y => or_result );

xor_comp: xorN
	generic map ( N => N )
	port map ( A => A, B => B, Y => xor_result );
-- Instantiate the SLL unit
sll_comp: sllN
	generic map ( N => N )
	port map ( A => B , SHIFT_AMT => A (4 downto 0), Y => sll_result );

srl_comp: srlN
	generic map ( N => N )
	port map ( A => B, SHIFT_AMT => A (4 downto 0), Y => srl_result );

sra_comp: sraN
	generic map ( N => N )
	port map ( A => B, SHIFT_AMT => A (4 downto 0), Y => sra_result );

add_comp: entity work.Adder
	generic map(USE_STRUCTURAL_ARCH => false)
	port map (A => A, B => B, OP => OP (0), Sum => add_result);

mult_comp: entity work.Multiplier
	generic map(USE_STRUCTURAL_ARCH => false)
	port map(A => A (15 downto 0), B => B (15 downto 0), Product => mul_result);
	-- Use OP to control which operation to show/perform

	with OP select Y <= 
		 not_result when "0000",
		 or_result when "1000",
		 add_result when "0100" | "0101",
		 and_result when "1010",
		 mul_result when "0110",
		 xor_result when "1011",
		 sll_result when "1100",
		 srl_result when "1101",
		 sra_result when "1110",
		 x"00000000" when others;
	
end structural;
