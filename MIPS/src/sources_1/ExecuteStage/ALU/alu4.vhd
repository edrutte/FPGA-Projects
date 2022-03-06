library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity alu4 is
	generic (
		N              : integer := BIT_DEPTH;
		COMBINE_MULADD : boolean := false
	);
	port (
		clk : in  std_logic;
		A	: in  std_logic_vector(N-1 downto 0);
		B	: in  std_logic_vector(N-1 downto 0);
		OP  : in  std_logic_vector(3 downto 0);
		Y	: out std_logic_vector(N-1 downto 0)
	);
end alu4;

architecture structural of alu4 is	
	signal not_result : std_logic_vector (N-1 downto 0);
	signal and_result : std_logic_vector (N-1 downto 0);
	signal or_result  : std_logic_vector (N-1 downto 0);
	signal xor_result : std_logic_vector (N-1 downto 0);
	signal sll_result : std_logic_vector (N-1 downto 0);
	signal srl_result : std_logic_vector (N-1 downto 0);
	signal sra_result : std_logic_vector (N-1 downto 0);
	signal add_result : std_logic_vector (N-1 downto 0);
	signal mul_result : std_logic_vector (N-1 downto 0);
begin
	-- Instantiate the inverter
	not_comp: entity work.notN
		generic map ( N => N)
		port map ( A => A, Y => not_result );

	and_comp: entity work.andN
		generic map ( N => N)
		port map ( A => A, B => B, Y => and_result );

	or_comp: entity work.orN
		generic map ( N => N)
		port map ( A => A, B => B, Y => or_result );

	xor_comp: entity work.xorN
		generic map ( N => N )
		port map ( A => A, B => B, Y => xor_result );

	sll_comp: entity work.sllN
		generic map ( N => N )
		port map ( A => B , SHIFT_AMT => A (4 downto 0), Y => sll_result );

	srl_comp: entity work.srlN
		generic map ( N => N )
		port map ( A => B, SHIFT_AMT => A (4 downto 0), Y => srl_result );

	sra_comp: entity work.sraN
		generic map ( N => N )
		port map ( A => B, SHIFT_AMT => A (4 downto 0), Y => sra_result );

	muladd : if COMBINE_MULADD generate
		signal muladd_result : std_logic_vector(N - 1 downto 0);
		signal subadd, mul : std_logic;
		begin
		multadd_comp: entity work.multadd
			port map ( clk => clk, OpA => A, OpB => B, pout => muladd_result, mul => mul, subadd => subadd);

		with OP select mul <=
			'1' when "0110",
			'0' when others;

		subadd <= OP(0);

		mul_result <= muladd_result;
		add_result <= muladd_result;
	else generate
		add_comp: entity work.Adder
			generic map(USE_STRUCTURAL_ARCH => false)
			port map (A => A, B => B, OP => OP (0), Sum => add_result);

		mult_comp: entity work.Multiplier
			generic map(USE_STRUCTURAL_ARCH => false)
			port map(A => A (15 downto 0), B => B (15 downto 0), Product => mul_result);
			-- Use OP to control which operation to show/perform
	end generate;

	with OP select Y <= 
		 not_result when "0000",
		 or_result  when "1000",
		 add_result when "0100" | "0101",
		 and_result when "1010",
		 mul_result when "0110",
		 xor_result when "1011",
		 sll_result when "1100",
		 srl_result when "1101",
		 sra_result when "1110",
		 x"00000000" when others;

end structural;
