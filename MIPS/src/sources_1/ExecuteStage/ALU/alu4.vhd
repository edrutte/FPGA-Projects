library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity alu4 is
	port (
		A   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		B   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		OP  : in  std_logic_vector (3 downto 0);
		Hi  : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		Y   : out std_logic_vector (BIT_DEPTH - 1 downto 0)
	);
end alu4;

architecture structural of alu4 is	
	signal not_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal and_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal or_result  : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal xor_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal sll_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal srl_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal sra_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal add_result : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal hi_result  : std_logic_vector (BIT_DEPTH - 1 downto 0);
	signal lo_result  : std_logic_vector (BIT_DEPTH - 1 downto 0);
begin
	-- Instantiate the inverter
	not_comp: entity work.notN
		generic map (N => BIT_DEPTH)
		port map (A => A, Y => not_result);

	and_comp: entity work.andN
		generic map (N => BIT_DEPTH)
		port map (A => A, B => B, Y => and_result);

	or_comp: entity work.orN
		generic map (N => BIT_DEPTH)
		port map (A => A, B => B, Y => or_result);

	xor_comp: entity work.xorN
		generic map (N => BIT_DEPTH)
		port map (A => A, B => B, Y => xor_result);

	sll_comp: entity work.sllN
		generic map (N => BIT_DEPTH)
		port map (A => B , SHIFT_AMT => A (4 downto 0), Y => sll_result);

	srl_comp: entity work.srlN
		generic map (N => BIT_DEPTH)
		port map (A => B, SHIFT_AMT => A (4 downto 0), Y => srl_result);

	sra_comp: entity work.sraN
		generic map (N  => BIT_DEPTH)
		port map (A => B, SHIFT_AMT => A (4 downto 0), Y => sra_result);

	add_comp: entity work.Adder
		generic map (USE_STRUCTURAL_ARCH => false)
		port map (A => A, B => B, OP => OP (0), Sum => add_result);

	mult_comp: entity work.Multiplier
		generic map (USE_STRUCTURAL_ARCH => false)
		port map (A => A, B => B, OP => OP (0), Lo => lo_result, Hi => hi_result);
		-- Use OP to control which operation to show/perform

	with OP select Y <= 
		 not_result when "0000",
		 or_result  when "1000",
		 add_result when "0100" | "0101",
		 and_result when "1010",
		 lo_result  when "0110" | "0111",
		 xor_result when "1011",
		 sll_result when "1100",
		 srl_result when "1101",
		 sra_result when "1110",
		 std_logic_vector(to_unsigned(0, BIT_DEPTH)) when others;

	Hi <= hi_result when OP = "0110" or OP = "0111" else (others => '0');

end structural;
