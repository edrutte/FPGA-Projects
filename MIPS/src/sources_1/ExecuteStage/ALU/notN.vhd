library ieee;
use ieee.std_logic_1164.all;

entity notN is
	generic (N : INTEGER  := 4); --bit  width
	port (
		A : in   std_logic_vector (N - 1  downto  0);
		Y : out  std_logic_vector (N - 1  downto  0)
	);
end  notN;

architecture generator of notN is
begin
	Y <= not A;
end;
