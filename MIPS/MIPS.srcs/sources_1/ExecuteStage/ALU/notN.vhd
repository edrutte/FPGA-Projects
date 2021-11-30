library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;

entity  notN is
	GENERIC (N : INTEGER  := 4); --bit  width
	PORT (
		A : IN  std_logic_vector(N-1  downto  0);
		Y : OUT  std_logic_vector(N-1  downto  0)
	);
end  notN;

architecture generator of notN is
begin
	y <= not a;
end;
