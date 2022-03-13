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

begin
aeqb_proc : process(a, b) is begin
	if a = b then
		aeqb <= '1';
	else
		aeqb <= '0';
	end if;
end process;

agtz_proc : process(a) is begin
	if signed(a) > 0 then
		agtz <= '1';
	else
		agtz <= '0';
	end if;
end process;

aeqz_proc : process(a) is begin
	if signed(a) = 0 then
		aeqz <= '1';
	else
		aeqz <= '0';
	end if;
end process;
end SomeRandomName;
