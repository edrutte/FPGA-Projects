library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity srlN is
	generic (N : INTEGER := 4); --bit width
	port (
		A         : in  std_logic_vector (N - 1 downto 0);
		SHIFT_AMT : in  std_logic_vector (4 downto 0);
		Y         : out std_logic_vector (N - 1 downto 0)
	 );
end srlN;

architecture behavioral of srlN is
	type shifty_array is array(N-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal aSRL : shifty_array;
begin
	generateSRL: for i in 0 to N-1 generate
		aSRL(i)(N-1-i downto 0) <= A(N-1 downto i);
		right_fill: if i > 0 generate
			aSRL(i)(N-1 downto N-i) <= (others => '0');
		end generate right_fill;
end generate generateSRL;

Y <= (others => '0') when
	 (to_integer(unsigned(SHIFT_AMT)) > 32) else aSRL(to_integer(unsigned(SHIFT_AMT)));
end behavioral;
