library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionFetch is 
	Port (
		clk         : in  std_logic;
		rst         : in  std_logic;
		StallF      : in  std_logic;
		PCSrc       : in  std_logic;
		PCBranch    : in  std_logic_vector (27 downto 0);
		PC          : out std_logic_vector (27 downto 0);
		PCPlus4     : out std_logic_vector (27 downto 0)
	);
end InstructionFetch;

architecture SomeRandomName of InstructionFetch is

component InstructionMem
	Port (
		addr  : in  std_logic_vector (27 downto 0);
		d_out : out std_logic_vector (31 downto 0)
	);
end component;

signal PCtmp : std_logic_vector(27 downto 0) := (others => '0');

begin
				 
fetch_proc : process (rst, clk) is begin
	if rst = '1' then
		PC <= (others => '0');
	elsif rising_edge(clk) then
		if StallF = '0' then
			if PCSrc = '1' then
				PC <= PCBranch;
			else
				PC <= PCtmp;
			end if;
		end if;
	end if;
end process;

PCtmp <= std_logic_vector(to_unsigned((to_integer(unsigned(PC)) + 4), 28));
PCPlus4 <= PCtmp;

end SomeRandomName;
