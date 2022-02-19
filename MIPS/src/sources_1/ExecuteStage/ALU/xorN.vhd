library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity xorN is
	generic(N: integer := 4);
	port(a:	in STD_LOGIC_VECTOR(N-1 downto 0);
		 b: in STD_LOGIC_VECTOR(N-1 downto 0);
		 y:	out STD_LOGIC_VECTOR(N-1 downto 0));
	end;
	
architecture generator of xorN is
begin
    y <= a xor b;
end;
