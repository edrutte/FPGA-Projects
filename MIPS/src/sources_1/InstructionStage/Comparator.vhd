library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

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

signal aneg : std_logic;

begin

aeqb <= '1' when a = b else '0';

aeqz <= '1' when signed(a) = 0 else '0';

aneg <= a(BIT_DEPTH - 1);

agtz <= aneg nor aeqz;

end SomeRandomName;
