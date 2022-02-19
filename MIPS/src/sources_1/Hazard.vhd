library IEEE;
use IEEE.std_logic_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity Hazard is
	Port ( 
		RegWriteM : in  std_logic;
		RegWriteW : in  std_logic;
		MemtoReg  : in  std_logic;
		RsD       : in  std_logic_vector ( 4 downto 0 );
		RtD       : in  std_logic_vector ( 4 downto 0 );
		RsE       : in  std_logic_vector ( 4 downto 0 );
		RtE       : in  std_logic_vector ( 4 downto 0 );
		WriteRegM : in  std_logic_vector ( 4 downto 0 );
		WriteRegW : in  std_logic_vector ( 4 downto 0 );
		StallF    : out std_logic;
		StallD    : out std_logic;
		FlushE    : out std_logic;
		ForwardAE : out std_logic_vector ( 1 downto 0 );
		ForwardBE : out std_logic_vector ( 1 downto 0 )
	);
end Hazard;

architecture Behavioral of Hazard is

signal lwStall : std_logic;

begin

ForwardAE_proc : process (RsE, RegWriteM, RegWriteW, WriteRegM, WriteRegW) is begin
	if RsE /= "00000" and RsE = WriteRegM and RegWriteM = '1' then
		ForwardAE <= "10";
	elsif RsE /= "00000" and RsE = WriteRegW and RegWriteW = '1' then
		ForwardAE <= "01";
	else
		ForwardAE <= "00";
	end if;
end process;

ForwardBE_proc : process (RtE, RegWriteM, RegWriteW, WriteRegM, WriteRegW) is begin
	if RtE /= "00000" and RtE = WriteRegM and RegWriteM = '1' then
		ForwardBE <= "10";
	elsif RtE /= "00000" and RtE = WriteRegW and RegWriteW = '1' then
		ForwardBE <= "01";
	else
		ForwardBE <= "00";
	end if;
end process;

lwStall_proc : process(RsD, RsE, RtD, RtE, MemtoReg) is begin
	if (RsD = RsE or RtD = RtE) and MemtoReg = '1' then
		lwStall <= '1';
	else
		lwStall <= '0';
	end if;
end process;

StallF <= lwStall;
StallD <= lwStall;
FlushE <= lwStall;

end Behavioral;
