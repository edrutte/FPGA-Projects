library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity Comparator is
    Port (
    	a     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		b     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		aeqb  : out std_logic;
		agtz  : out std_logic;
		aeqz  : out std_logic
	);
end Comparator;

architecture SomeRandomName of Comparator is

signal aneg, aeqz_tmp : std_logic;

begin

aeqb <= '1' when a = b else '0';

aeqz_tmp <= '1' when unsigned(a) = to_unsigned(0, BIT_DEPTH) else '0';

aneg <= a(BIT_DEPTH - 1);

agtz <= aneg nor aeqz_tmp;

aeqz <= aeqz_tmp;

end SomeRandomName;
