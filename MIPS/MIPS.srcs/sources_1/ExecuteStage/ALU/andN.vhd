library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;

entity  andN is
	GENERIC (N : INTEGER  := 4); --bit  width
	PORT (
		A : IN  std_logic_vector(N-1  downto  0);
		B : IN  std_logic_vector(N-1  downto  0);
		Y : OUT  std_logic_vector(N-1  downto  0)
	);
end  andN;

architecture generator of andN is
begin
	y <= a and b;
end;
