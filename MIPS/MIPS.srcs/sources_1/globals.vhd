library ieee;
use ieee.std_logic_1164.all;
package globals is
	constant BIT_DEPTH : INTEGER := 32;
	constant LOG_PORT_DEPTH : INTEGER := 5;
	constant DATA_ADDR_BITS : INTEGER := 10;
	constant NUM_SWITCHES : INTEGER := 8;
	
	function to_string( a: std_logic_vector) return string;
end package globals;

package body globals is

function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
	for i in a'range loop
		b(stri) := std_logic'image(a((i)))(2);
		stri := stri+1;
	end loop;
return b;
end function;
end package body globals;
