library ieee;
use ieee.std_logic_1164.all;

entity xorN is
	generic (N: integer := 4);
	port (
		A : in  std_logic_vector (N - 1 downto 0);
		B : in  std_logic_vector (N - 1 downto 0);
		Y : out std_logic_vector (N - 1 downto 0)
	);
	end;
	
architecture generator of xorN is
begin
    Y <= A xor B;
end;
