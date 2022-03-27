library IEEE;
use IEEE.std_logic_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity Hazard is
	Port ( 
		RegWriteE : in  std_logic;
		RegWriteM : in  std_logic;
		RegWriteW : in  std_logic;
		MemtoRegE : in  std_logic;
		MemtoRegM : in  std_logic;
		BranchD   : in  std_logic;
		LinkM     : in  std_logic;
		LinkW     : in  std_logic;
		RsD       : in  std_logic_vector ( 4 downto 0 );
		RtD       : in  std_logic_vector ( 4 downto 0 );
		RsE       : in  std_logic_vector ( 4 downto 0 );
		RtE       : in  std_logic_vector ( 4 downto 0 );
		WriteRegE : in  std_logic_vector ( 4 downto 0 );
		WriteRegM : in  std_logic_vector ( 4 downto 0 );
		WriteRegW : in  std_logic_vector ( 4 downto 0 );
		StallF    : out std_logic;
		StallD    : out std_logic;
		FlushE    : out std_logic;
		ForwardAE : out std_logic_vector ( 1 downto 0 );
		ForwardBE : out std_logic_vector ( 1 downto 0 );
		ForwardAD : out std_logic;
		ForwardBD : out std_logic
	);
end Hazard;

architecture Behavioral of Hazard is

signal lwStall         : std_logic;
signal branchStallTmp1 : std_logic;
signal branchStallTmp2 : std_logic;
signal branchStall     : std_logic;

begin

ForwardAD_proc : process (RsD, WriteRegM, RegWriteM) is begin
	if RsD /= "00000" and (((RsD = WriteRegM) and (RegWriteM = '1')) or ((RsD = "11111") and (LinkM = '1'))) then
		ForwardAD <= '1';
	else
		ForwardAD <= '0';
	end if;
end process;

ForwardAE_proc : process (RsE, RegWriteM, RegWriteW, WriteRegM, WriteRegW) is begin
	if RsE /= "00000" and (((RsE = WriteRegM) and (RegWriteM = '1')) or ((RsE = "11111") and (LinkM = '1'))) then
		ForwardAE <= "10";
	elsif (RsE /= "00000") and (((RsE = WriteRegW) and (RegWriteW = '1')) or ((RsE = "11111") and (LinkW = '1'))) then
		ForwardAE <= "01";
	else
		ForwardAE <= "00";
	end if;
end process;

ForwardBD_proc : process (RtD, WriteRegM, RegWriteM) is begin
	if RtD /= "00000" and (((RtD = WriteRegM) and (RegWriteM = '1')) or ((RtD = "11111") and (LinkM = '1'))) then
		ForwardBD <= '1';
	else
		ForwardBD <= '0';
	end if;
end process;

ForwardBE_proc : process (RtE, RegWriteM, RegWriteW, WriteRegM, WriteRegW) is begin
	if RtE /= "00000" and (((RtE = WriteRegM) and (RegWriteM = '1')) or ((RtE = "11111") and (LinkM = '1'))) then
		ForwardBE <= "10";
	elsif RtE /= "00000" and(((RtE = WriteRegW) and (RegWriteW = '1')) or ((RtE = "11111") and (LinkW = '1'))) then
		ForwardBE <= "01";
	else
		ForwardBE <= "00";
	end if;
end process;

lwStall_proc : process (RsD, RsE, RtD, RtE, MemtoRegM) is begin
	if (RsD = RsE or RtD = RtE) and MemtoRegM = '1' then
		lwStall <= '1';
	else
		lwStall <= '0';
	end if;
end process;

BranchStallTmp1 <= (BranchD and RegWriteE) when (WriteRegE = RsD) or (WriteRegE = RtD) else '0';
BranchStallTmp2 <= (BranchD and MemToRegM) when (WriteRegM = RsD) or (WriteRegM = RtD) else '0';
branchStall <= branchStallTmp1 or branchStallTmp2;
StallF <= lwStall or branchStall;
StallD <= lwStall or branchStall;
FlushE <= lwStall or branchStall;

end Behavioral;
