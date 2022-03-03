library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity RegisterFile is
	Port (
		Addr1 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Addr2 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Addr3 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		clk_n : in  std_logic;
		wd    : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		we    : in  std_logic;
		RD1   : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2   : out std_logic_vector (BIT_DEPTH - 1 downto 0)
	);
end RegisterFile;

architecture FileRegister of RegisterFile is

type mem_data_type is array (2**LOG_PORT_DEPTH downto 0) of std_logic_vector (BIT_DEPTH - 1 downto 0);
signal mem_data : mem_data_type := (others => (others => '0'));

begin

mem_proc : process (clk_n) is begin
	if falling_edge(clk_n) then
		if we = '1' then
			if to_integer(unsigned(Addr3)) /= 0 then
				mem_data(to_integer(unsigned(Addr3))) <= wd;
			end if;
		end if;
	end if;
end process;


RD1 <= mem_data(to_integer(unsigned(Addr1)));

RD2 <= mem_data(to_integer(unsigned(Addr2)));

end FileRegister;
