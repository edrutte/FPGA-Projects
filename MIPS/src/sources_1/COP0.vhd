library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity COP0 is
	port(
		clk   : in  std_logic;
		we    : in  std_logic;
		eret  : in  std_logic;
		Addr1 : in  std_logic_vector (4 downto 0);
		Addr2 : in  std_logic_vector (4 downto 0);
		Cause : in  std_logic_vector (4 downto 0);
		EPC   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		wd    : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		PC    : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD1   : out std_logic_vector (BIT_DEPTH - 1 downto 0)
	);
end entity COP0;

architecture SomeRandomName of COP0 is
	signal StatusReg, CauseReg : std_logic_vector (31 downto 0) := (others => '0');
	signal ErrEPCReg, EPCReg   : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
begin

Except_proc : process(clk) is begin
	if rising_edge(clk) then
		if Cause /= "00000" then
			if Cause /= CauseReg(6 downto 2) and StatusReg(1) = '0' then
				EPCReg <= EPC;
				ErrEPCReg <= EPC; --fudge for now
				StatusReg(1) <= '1'; --EXL bit
				CauseReg(6 downto 2) <= Cause;
			end if;
		end if;
	end if;
end process;

eret_proc : process(clk) is begin
	if rising_edge(clk) then
		if eret = '1' then
			if StatusReg(2) = '1' then --ERL
				PC <= ErrEPCReg;
				StatusReg(2) <= '0';
			else
				PC <= EPCReg;
				StatusReg(1) <= '0'; --EXL
			end if;
		end if;
	end if;
end process;
			

Addr1_proc : process(clk) is begin
	if rising_edge(clk) then
		case Addr1 is
			when "01100" => RD1 <= StatusReg;
			when "01101" => RD1 <= CauseReg;
			when "01110" => RD1 <= EPCReg;
			when "11110" => RD1 <= ErrEPCReg;
			when others => RD1 <= (others => '0');
		end case;
	end if;
end process;

Addr2_proc : process(clk) is begin
	if rising_edge(clk) then
		if we = '1' then
			case Addr2 is
				when "01100" => StatusReg <= wd;
				when "01101" => CauseReg <= wd;
				when "01110" => EPCReg <= wd;
				when "11110" => ErrEPCReg <= wd;
				when others => EPCReg <= EPCReg;
			end case;
		end if;
	end if;
end process;

end architecture SomeRandomName;
