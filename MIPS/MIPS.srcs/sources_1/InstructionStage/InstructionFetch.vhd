library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

entity InstructionFetch is 
	Port (
		clk         : in  std_logic;
		rst         : in  std_logic;
		StallF      : in  std_logic;
		Instruction : out std_logic_vector ( 31 downto 0 )
	);
end InstructionFetch;

architecture SomeRandomName of InstructionFetch is

component InstructionMem
	Port (
		addr  : in  std_logic_vector ( 27 downto 0 );
		d_out : out std_logic_vector ( 31 downto 0 )
	);
end component;

signal addr : std_logic_vector ( 27 downto 0 ) := ( others => '0' );

begin

mem : InstructionMem
	Port map (
		addr  => addr,
		d_out => Instruction
	);
				 
fetch_proc : process (all) is begin
	if rst = '1' then
		addr <= (others => '0');
	elsif StallF = '0' then
		if rising_edge(clk) then
			addr <= std_logic_vector(to_unsigned((to_integer(unsigned(addr)) + 4), 28));
		end if;
	end if;
end process;

end SomeRandomName;
