library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sraN is
	GENERIC (N : INTEGER := 4); --bit width
	PORT (
		A     : IN std_logic_vector(N-1 downto 0);
		SHIFT_AMT : IN std_logic_vector(4 downto 0);
		Y     : OUT std_logic_vector(N-1 downto 0)
	 );
end sraN;

architecture behavioral of sraN is
	type shifty_array is array(N-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal aSRA : shifty_array;
begin
	generateSRA: for i in 0 to N-1 generate
		aSRA(i)(N-1-i downto 0) <= A(N-1 downto i);
		right_fill: if i > 0 generate
			aSRA(i)(N-1 downto N-i) <= (others => A(N-1));
		end generate right_fill;
end generate generateSRA;

Y <= (others => '0') when
	 (to_integer(unsigned(SHIFT_AMT)) > 32) else aSRA(to_integer(unsigned(SHIFT_AMT)));

end behavioral;
