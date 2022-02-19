-------------------------------------------------
--  File:          InstructionFetchTB.vhd
--
--  Entity:        InstructionFetchTB
--  Architecture:  BEHAVIORAL
--  Author:        Jason Blocklove
--  Created:       07/26/19
--  Modified:	   2/25/2021 By Evan Ruttenberg
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                 Testbench for Instruction Fetch
--                 Stage
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionFetchTB is
end InstructionFetchTB;

architecture Behavioral of InstructionFetchTB is

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

type test_vector is record
	rst : std_logic;
	Instruction	 : std_logic_vector(31 downto 0);
end record;

type test_array is array (natural range <>) of test_vector;
constant test_vector_array : test_array := (
	(rst => '1', Instruction => x"11111111"),
	(rst => '0', Instruction => x"11111111"),
	(rst => '0', Instruction => x"22222222"),
	(rst => '0', Instruction => x"1f2e3d4c"),
	(rst => '0', Instruction => x"abcdef23"),
	(rst => '0', Instruction => x"dabcef56"),
	(rst => '0', Instruction => x"467ddeac"),
	(rst => '0', Instruction => x"12345678"),
	(rst => '0', Instruction => x"99558eda")
);

component InstructionFetch
  port (
    clk : in std_logic;
    rst : in std_logic;
    Instruction : out std_logic_vector(31 DOWNTO 0)
  );
end component;

	signal rst : std_logic;
	signal clk : std_logic;
	signal instruction : std_logic_vector(31 downto 0);


begin

uut : InstructionFetch
  port map (
    clk => clk,
    rst => rst,
    Instruction => Instruction
  );

clk_proc:process
begin
	clk <= '0';
	wait for 50 ns;
	clk <= '1';
	wait for 50 ns;
end process;

stim_proc:process
begin

	for i in test_vector_array'range loop
		wait until clk='0';
		rst <= test_vector_array(i).rst;
		assert instruction = test_vector_array(i).instruction
			report "Instruction " & to_string(instruction) &
				" not equal to expected instruction " & to_string(test_vector_array(i).instruction)
			severity error;
	end loop;
	wait until clk='0';

	assert false
		report "Testbench Concluded"
		severity failure;


end process;

end Behavioral;
