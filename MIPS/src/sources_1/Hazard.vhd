library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity Hazard is
	Port ( 
		clk        : in  std_logic;
		RegWriteE  : in  std_logic;
		RegWriteM  : in  std_logic;
		MemtoRegE  : in  std_logic;
		MemtoRegM  : in  std_logic;
		BranchD    : in  std_logic;
		ALUSrcD    : in  std_logic;
		LinkD      : in  std_logic;
		Except     : in  std_logic_vector (3 downto 0);
		WriteRegE  : in  std_logic_vector (4 downto 0);
		WriteRegM  : in  std_logic_vector (4 downto 0);
		RsD        : in  std_logic_vector (4 downto 0);
		RtD        : in  std_logic_vector (4 downto 0);
		RtE        : in  std_logic_vector (4 downto 0);
		RD1D       : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2D       : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		MemOutM    : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		SignImmD   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		ALUResultE : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		ALUResultM : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		StallF     : out std_logic;
		StallD     : out std_logic;
		FlushE     : out std_logic;
		RegSrcA    : out std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
		RegSrcB    : out std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
		WriteData  : out std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
		CmpData1   : out std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
		CmpData2   : out std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0')
	);
end Hazard;

architecture Behavioral of Hazard is

signal lwStall         : std_logic;
signal branchStallTmp1 : std_logic;
signal branchStallTmp2 : std_logic;
signal Stall           : std_logic;
signal RegSrcA_tmp     : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
signal RegSrcB_tmp     : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');
signal ExceptStall     : std_logic;

begin

RegSrcA_tmp_proc : process (RsD, RD1D, WriteRegE, ALUResultE, MemOutM, ALUResultM, WriteRegM, RegWriteM, RegWriteE, MemtoRegM) is begin
	case RsD is
		when "00000" => RegSrcA_tmp <= RD1D;
		when others =>
			case (RsD xor WriteRegE) & RegWriteE is
				when "000001" => RegSrcA_tmp <= ALUResultE;
				when others =>
					case (RsD xor WriteRegM) & RegWriteM is
						when "000001" =>
							if MemtoRegM = '1' then
								RegSrcA_tmp <= MemOutM;
							else
								RegSrcA_tmp <= ALUResultM;
							end if;
						when others => RegSrcA_tmp <= RD1D;
					end case;
			end case;
	end case;
end process;

RegSrcA_proc : process (clk) is begin
	if rising_edge(clk) then
		if LinkD = '1' then
			RegSrcA <= RD1D;
		else
			RegSrcA <= RegSrcA_tmp;
		end if;
	end if;
end process;

RegSrcB_tmp_proc : process (RtD, RD2D, WriteRegE, ALUResultE, MemOutM, ALUResultM, WriteRegM, RegWriteM, RegWriteE, MemtoRegM) is begin
	case RtD is
		when "00000" => RegSrcB_tmp <= RD2D;
		when others =>
			case (RtD xor WriteRegE) & RegWriteE is
				when "000001" => RegSrcB_tmp <= ALUResultE;
				when others =>
					case (RtD xor WriteRegM) & RegWriteM is
						when "000001" =>
							if MemtoRegM = '1' then
								RegSrcB_tmp <= MemOutM;
							else
								RegSrcB_tmp <= ALUResultM;
							end if;
						when others => RegSrcB_tmp <= RD2D;
					end case;
			end case;
	end case;
end process;

RegSrcB_proc : process (clk) is begin
	if rising_edge(clk) then
		case std_logic_vector'(Stall & ALUSrcD) is
			when "01" => RegSrcB <= SignImmD;
			when "00" => RegSrcB <= RegSrcB_tmp;
			when others => RegSrcB <= (others => '0');
		end case;
	end if;
end process;

CmpData1 <= RegSrcA_tmp;

CmpData2 <= RegSrcB_tmp;

lwStall_proc : process (RsD, RtD, RtE, MemtoRegE) is begin
	if RsD = RtE or RtD = RtE then
		lwStall <= MemtoRegE;
	else
		lwStall <= '0';
	end if;
end process;

BranchStallTmp1_proc : process (BranchD, RsD, RegWriteE, WriteRegE, MemtoRegM, WriteRegM) is begin
	if RsD /= "00000" then
		if RsD = WriteRegE then
			BranchStallTmp1 <= BranchD and RegWriteE;
		elsif RsD = WriteRegM then
			BranchStallTmp1 <= BranchD and MemtoRegM;
		else
			BranchStallTmp1 <= '0';
		end if;
	else
		BranchStallTmp1 <= '0';
	end if;
end process;

BranchStallTmp2_proc : process (BranchD, RtD, RegWriteE, WriteRegE, MemtoRegM, WriteRegM) is begin
	if RtD /= "00000" then
		if RtD = WriteRegE then
			BranchStallTmp2 <= BranchD and RegWriteE;
		elsif RtD = WriteRegM then
			BranchStallTmp2 <= BranchD and MemtoRegM;
		else
			BranchStallTmp2 <= '0';
		end if;
	else
		BranchStallTmp2 <= '0';
	end if;
end process;

ExceptStall <= '1' when Except /= "0000" else '0';
Stall <= branchStallTmp1 or branchStallTmp2 or lwStall or ExceptStall;
StallF <= Stall;
StallD <= Stall;
FlushE <= Stall;
WriteData <= RegSrcB_tmp;

end Behavioral;
