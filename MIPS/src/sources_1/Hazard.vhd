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
signal branchStall     : std_logic;
signal RegSrcB_tmp     : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

begin

RegSrcA_proc : process (clk) is begin
	if rising_edge(clk) then
		case RsD is
			when "00000" => RegSrcA <= RD1D;
			when others =>
				case (RsD xor WriteRegE) & RegWriteE is
					when "000001" => RegSrcA <= ALUResultE;
					when others =>
						case (RsD xor WriteRegM) & RegWriteM is
							when "000001" =>
								if MemtoRegM = '1' then
									RegSrcA <= MemOutM;
								else
									RegSrcA <= ALUResultM;
								end if;
							when others => RegSrcA <= RD1D;
						end case;
				end case;
		end case;
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
		case std_logic_vector'(lwStall & branchStall & ALUSrcD) is
			when "001" => RegSrcB <= SignImmD;
			when "000" => RegSrcB <= RegSrcB_tmp;
			when others => RegSrcB <= (others => '0');
		end case;
	end if;
end process;

ForwardAD_proc : process (RsD, WriteRegM, RegWriteM, RD1D, ALUResultM) is begin
	if RsD /= "00000" and (RsD = WriteRegM) and RegWriteM = '1' then
		CmpData1 <= ALUResultM;
	else
		CmpData1 <= RD1D;
	end if;
end process;

ForwardBD_proc : process (RtD, WriteRegM, RegWriteM, RD2D, ALUResultM) is begin
	if RtD /= "00000" and (RtD = WriteRegM) and RegWriteM = '1' then
		CmpData2 <= ALUResultM;
	else
		CmpData2 <= RD2D;
	end if;
end process;

lwStall_proc : process (RsD, RtD, RtE, MemtoRegE) is begin
	if RsD = RtE or RtD = RtE then
		lwStall <= MemtoRegE;
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
WriteData <= RegSrcB_tmp;

end Behavioral;
