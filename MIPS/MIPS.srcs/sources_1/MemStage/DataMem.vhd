library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

use ieee.numeric_std.all;

entity DataMem is
	Port ( 
		clk, w_en : in  std_logic;
		addr      : in  std_logic_vector ( DATA_ADDR_BITS - 1 downto 0 );
		d_in      : in  std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		switches  : in  std_logic_vector ( NUM_SWITCHES - 1 downto 0 );
		d_out     : out std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		seven_seg : out std_logic_vector ( 15 downto 0 )
	);
end DataMem;

architecture Behavioral of DataMem is

type mem_type is array (0 to 2**DATA_ADDR_BITS - 1) of std_logic_vector (BIT_DEPTH - 1 downto 0);
signal data_mem : mem_type := (others => (others => '0'));

begin

seven_seg_proc : process (all) is begin
	if rising_edge(clk) then
		if w_en = '1' then
			case addr is
				when std_logic_vector(to_unsigned(1023, DATA_ADDR_BITS)) => seven_seg <= d_in (15 downto 0);
				when others => seven_seg <= seven_seg;
			end case;
		end if;
	end if;
end process;

store_proc : process ( clk ) is begin
	if rising_edge ( clk ) then
		if w_en = '1' then
			data_mem ( to_integer ( unsigned ( addr ) ) ) <= d_in;
		end if;
	end if;
end process;

with addr select d_out <=
	std_logic_vector(to_unsigned(to_integer(unsigned(switches)), BIT_DEPTH)) when std_logic_vector(to_unsigned(1022, DATA_ADDR_BITS)), 
	data_mem(to_integer(unsigned(addr))) when others;

end Behavioral;
