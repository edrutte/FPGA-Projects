library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity RegisterFile is
	Port (
		clk_n : in  std_logic;
		Addr1 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Addr2 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Addr3 : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		wd    : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		wd_hi : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		rd_hi : in  std_logic;
		rd_lo : in  std_logic;
		we    : in  std_logic;
		we_lo : in  std_logic;
		we_hi : in  std_logic;
		Link  : in  std_logic;
		RD1   : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2   : out std_logic_vector (BIT_DEPTH - 1 downto 0)
	);
end RegisterFile;

architecture FileRegister of RegisterFile is

type mem_data_type is array (2**LOG_PORT_DEPTH - 1 downto 0) of std_logic_vector (BIT_DEPTH - 1 downto 0);
signal mem_data : mem_data_type := (others => (others => '0'));
signal hi, lo : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

begin

mem_proc : process (clk_n) is begin
	if falling_edge(clk_n) then
		if we = '1' or Link = '1' then
			if to_integer(unsigned(Addr3)) /= 0 then
				mem_data(to_integer(unsigned(Addr3))) <= wd;
			end if;
		end if;
	end if;
end process;

hi_proc : process(clk_n) is begin
	if falling_edge(clk_n) then
		if we_hi = '1' then
			hi <= wd_hi;
		end if;
	end if;
end process;

lo_proc : process(clk_n) is begin
	if falling_edge(clk_n) then
		if we_lo = '1' and we = '0' and Link = '0' then
			lo <= wd;
		end if;
	end if;
end process;

RD1 <= mem_data(to_integer(unsigned(Addr1)));

RD2_proc : process(rd_hi, rd_lo, hi, lo, Addr2, mem_data) is
	variable rd_sel : std_logic_vector (1 downto 0) := std_logic_vector'(rd_hi & rd_lo);
begin
	rd_sel := std_logic_vector'(rd_hi & rd_lo);
	case rd_sel is
		when "10" => RD2 <= hi;
		when "01" => RD2 <= lo;
		when others => RD2 <= mem_data(to_integer(unsigned(Addr2)));
	end case;
end process;

end FileRegister;
