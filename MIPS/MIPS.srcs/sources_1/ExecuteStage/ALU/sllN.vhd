library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sllN is
	GENERIC (N : INTEGER := 4); --bit width
	PORT (
		A         : IN std_logic_vector(N-1 downto 0);
		SHIFT_AMT : IN std_logic_vector(4 downto 0);
		Y         : OUT std_logic_vector(N-1 downto 0)
	);
end sllN;

architecture behavioral of sllN is
	type shifty_array is array(N-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal aSLL : shifty_array;
begin
	generateSLL: for i in 0 to N-1 generate
		aSLL(i)(N-1 downto i) <= A(N-1-i downto 0);
		left_fill: if i > 0 generate
			aSLL(i)(i-1 downto 0) <= (others => '0');
		end generate left_fill;
end generate generateSLL;

Y <= (others => '0') when
	 (to_integer(unsigned(SHIFT_AMT)) > 32) else aSLL(to_integer(unsigned(SHIFT_AMT)));

end behavioral;
