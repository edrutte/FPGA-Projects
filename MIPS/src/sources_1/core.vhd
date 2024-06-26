library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity core is
	Port ( 
		clk         : in  std_logic;
		rst         : in  std_logic;
		Instruction : in  std_logic_vector (31 downto 0);
		d_in        : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		we          : out std_logic;
		PC          : out std_logic_vector (27 downto 0) := (others => '0');
		d_out       : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		dataAddr    : out std_logic_vector (DATA_ADDR_BITS - 1 downto 0)
	);
end core;

architecture Behavioral of core is

signal fetchOut, decodeIn : std_logic_vector (31 downto 0 ) := (others => '0');

signal RegWriteD, RegWriteE, RegWriteM, RegWriteW : std_logic := '0';

signal RegWriteHiD, RegWriteHiE, RegWriteHiM, RegWriteHiW : std_logic := '0';

signal RegWriteLoD, RegWriteLoE, RegWriteLoM, RegWriteLoW : std_logic := '0';

signal WriteRegE, WriteRegM, WriteRegW : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0) := (others => '0');

signal MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW : std_logic := '0';

signal MemWriteD, MemWriteE, MemWriteM : std_logic := '0';

signal LinkD, LinkE : std_logic := '0';

signal BranchCalcD : std_logic := '0';

signal TakeDelaySlot : std_logic := '1';

signal PCSrcD : std_logic := '0';

signal PCPlus4F, PCPlus4D : std_logic_vector (27 downto 0) := (others => '0');

signal PCBranchD : std_logic_vector (27 downto 0) := (others => '0');

signal ALUControlD, ALUControlE : std_logic_vector (3 downto 0) := (others => '0');

signal ALUSrcD: std_logic := '0';

signal RegDstD, RegDstE : std_logic := '0';

signal RD1D, RD2D : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal RsD : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0) := (others => '0');

signal RtD, RtE : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0) := (others => '0');

signal RdD, RdE : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0) := (others => '0');

signal ImmD : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal ALUResultE, ALUResultM, ALUResultW : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal HiWriteDataE, HiWriteDataM, HiWriteDataW : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal WriteDataD, WriteDataE, WriteDataM : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal MemOutM, MemOutW : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal result : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal StallF, StallD, FlushE : std_logic := '0';

signal RegSrcA, RegSrcB : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal CmpData1, CmpData2 : std_logic_vector (BIT_DEPTH - 1 downto 0) := (others => '0');

signal ExceptD : std_logic_vector (3 downto 0) := "0000";

begin

F_reg : process (clk) is begin
	if rising_edge(clk) then
		if rst = '1' then
			PC <= (others => '0');
		else
			case StallF & PCSrcD & ExceptD is
				when "100000" | "110000" => PC <= PC;
				when "000000" => PC <= PCPlus4F;
				when "010000" => PC <= PCBranchD;
				when others => PC <= ExceptD & x"000000";
			end case;
		end if;
	end if;
end process;

PCPlus4F <= std_logic_vector(to_unsigned((to_integer(unsigned(PC)) + 4), 28));

Decode : entity work.InstructionDecode
	Port map(
		clk          => clk,
		Instruction  => decodeIn,
		RegWriteAddr => WriteRegW,
		RegWriteData => result,
		HiWriteData  => HiWriteDataW,
		CmpData1     => CmpData1,
		CmpData2     => CmpData2,
		PCPlus4      => PCPlus4D,
		RegWriteEn   => RegWriteW,
		RegWriteHi   => RegWriteHiW,
		RegWriteLo   => RegWriteLoW,
		RegWrite     => RegWriteD,
		MemtoReg     => MemtoRegD,
		MemWrite     => MemWriteD,
		Link         => LinkD,
		CalcBranch   => BranchCalcD,
		PCSrc        => PCSrcD,
		ALUSrc       => ALUSrcD,
		RegDst       => RegDstD,
		we_hi        => RegWriteHiD,
		we_lo        => RegWriteLoD,
		OpA          => RD1D,
		RD2          => RD2D,
		ImmOut       => ImmD,
		RtDest       => RtD,
		RdDest       => RdD,
		RsDest       => RsD,
		PCBranch     => PCBranchD,
		ALUControl   => ALUControlD,
		Except       => ExceptD
	);

D_reg : process (clk) is begin
	if rising_edge(clk) then
		case TakeDelaySlot & StallD & ExceptD is
			when "110000" =>
				decodeIn <= decodeIn;
				PCPlus4D <= PCPlus4D;
			when "100000" =>
				decodeIn <= fetchOut;
				PCPlus4D <= PCPlus4F;
			when others =>
				decodeIn <= (others => '0');
				PCPlus4D <= (others => '0');
		end case;
	end if;
end process;
	    
Hazard : entity work.Hazard
	Port map(
		clk        => clk,
		RegWriteE  => RegWriteE,
		RegWriteM  => RegWriteM,
		MemtoRegE  => MemtoRegE,
		MemtoRegM  => MemtoRegM,
		BranchD    => BranchCalcD,
		ALUSrcD    => ALUSrcD,
		LinkD      => LinkD,
		Except     => ExceptD,
		WriteRegE  => WriteRegE,
		WriteRegM  => WriteRegM,
		RsD        => RsD,
		RtD        => RtD,
		RtE        => RtE,
		RD1D       => RD1D,
		RD2D       => RD2D,
		MemOutM    => MemOutM,
		SignImmD   => ImmD,
		ALUResultE => ALUResultE,
		ALUResultM => ALUResultM,
		StallF     => StallF,
		StallD     => StallD,
		FlushE     => FlushE,
		RegSrcA    => RegSrcA,
		RegSrcB    => RegSrcB,
		WriteData  => WriteDataD,
		CmpData1   => CmpData1,
		CmpData2   => CmpData2
	);

Execute : entity work.Execute
	Port map(
		RegDst     => RegDstE,
		RegWriteHi => RegWriteHiE,
		RegWriteLo => RegWriteLoE,
		RegSrcA    => RegSrcA,
		RegSrcB    => RegSrcB,
		RtDest     => RtE,
		RdDest     => RdE,
		ALUControl => ALUControlE,
		Hi         => HiWriteDataE,
		ALUResult  => ALUResultE,
		WriteReg   => WriteRegE
	);

E_reg : process (clk) is begin
	if rising_edge(clk) then
		if FlushE = '1' then
			RegWriteHiE <= '0';
			RegWriteLoE <= '0';
			RegWriteE   <= '0';
			MemWriteE   <= '0';
			MemtoRegE   <= '0';
		else
			RegWriteHiE <= RegWriteHiD;
			RegWriteLoE <= RegWriteLoD;
			RegWriteE   <= RegWriteD;
			MemWriteE   <= MemWriteD;
			MemtoRegE   <= MemtoRegD;
		end if;
	end if;
end process;

Wb : entity work.Writeback
	Port map(
		MemtoReg  => MemtoRegW,
		ALUResult => ALUResultW,
		ReadData  => MemOutW,
		Result    => result
	);

stageDiv : process (clk) is begin
	if rising_edge(clk) then
		RtE          <= RtD;
		RdE          <= RdD;
		LinkE        <= LinkD;
		ALUControlE  <= ALUControlD;
		RegWriteM    <= RegWriteE or LinkE;
		RegWriteHiM  <= RegWriteHiE;
		RegWriteHiW  <= RegWriteHiM;
		RegWriteLoM  <= RegWriteLoE;
		RegWriteLoW  <= RegWriteLoM;
		MemtoRegM    <= MemtoRegE;
		MemtoRegW    <= MemtoRegM;
		MemWriteM    <= MemWriteE;
		RegWriteW    <= RegWriteM;
		ALUResultM   <= ALUResultE;
		ALUResultW   <= ALUResultM;
		WriteDataE   <= WriteDataD;
		WriteDataM   <= WriteDataE;
		WriteRegM    <= WriteRegE;
		WriteRegW    <= WriteRegM;
		MemOutW      <= MemOutM;
		HiWriteDataM <= HiWriteDataE;
		HiWriteDataW <= HiWriteDataM;
		RegDstE      <= RegDstD;
	end if;
end process;

fetchOut <= Instruction;
dataAddr <= ALUResultM (DATA_ADDR_BITS - 1 downto 0);
MemOutM  <= d_in;
d_out    <= WriteDataM;
we       <= MemWriteM;

end Behavioral;
