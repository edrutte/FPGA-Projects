library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity InstructionDecode is
	Port ( 
		clk          : in  std_logic;
		Instruction  : in  std_logic_vector (31 downto 0);
		RegWriteAddr : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RegWriteData : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		HiWriteData  : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		COP0Data     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData1     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData2     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCPlus4      : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		EPC          : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		RegWriteEn   : in  std_logic;
		RegWriteHi   : in  std_logic;
		RegWriteLo   : in  std_logic;
		RegWrite     : out std_logic;
		COP0Write    : out std_logic;
		MemtoReg     : out std_logic;
		MemWrite     : out std_logic;
		Link         : out std_logic;
		CalcBranch   : out std_logic;
		TakeDelay    : out std_logic;
		PCSrc        : out std_logic;
		ALUSrc       : out std_logic;
		RegDst       : out std_logic;
		we_hi        : out std_logic;
		we_lo        : out std_logic;
		eret         : out std_logic;
		OpA          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		ImmOut       : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RtDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RdDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RsDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		PCBranch     : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		ALUControl   : out std_logic_vector (3 downto 0);
		Except       : out std_logic_vector (4 downto 0)
	);
end InstructionDecode;

architecture SomeRandomName of InstructionDecode is

signal Opcode      : std_logic_vector (5 downto 0);
signal Funct       : std_logic_vector (5 downto 0);
signal rd_hi       : std_logic;
signal rd_lo       : std_logic;
signal RD1         : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal sa          : std_logic_vector (4 downto 0);

begin

CU : entity work.ControlUnit
	port map (
		Opcode     => Opcode,
		COPop      => RsDest,
		RegImmInst => RtDest,
		Funct      => Funct,
		CmpData1   => CmpData1,
		CmpData2   => CmpData2,
		Link       => Link,
		RegWrite   => RegWrite,
		COP0Write  => COP0Write,
		MemtoReg   => MemtoReg,
		MemWrite   => MemWrite,
		ALUControl => ALUControl,
		Except     => Except,
		ALUSrc     => ALUSrc,
		PCSrc      => PCSrc,
		RegDst     => RegDst,
		CalcBranch => CalcBranch,
		TakeDelay  => TakeDelay,
		rd_hi      => rd_hi,
		rd_lo      => rd_lo,
		we_hi      => we_hi,
		we_lo      => we_lo,
		eret       => eret
	);
		
RegFile : entity work.RegisterFile
	Port map (
		clk_n => clk,
		Addr1 => RsDest,
		Addr2 => RtDest,
		Addr3 => RegWriteAddr,
		wd    => RegWriteData,
		wd_hi => HiWriteData,
		rd_hi => rd_hi,
		rd_lo => rd_lo,
		we    => RegWriteEn,
		we_lo => RegWriteLo,
		we_hi => RegWriteHi,
		RD1   => RD1,
		RD2   => RD2
	);

OpA_proc : process(Opcode, Funct, RD1, sa, PCPlus4, COP0Data, RsDest) is begin
	case Opcode is
		when "000000" =>
			case Funct is
				when "000000" | "000010" | "000011" => OpA <= std_logic_vector(to_unsigned(to_integer(unsigned(sa)), BIT_DEPTH));
				when "001001" => OpA <= std_logic_vector(to_unsigned(to_integer(unsigned(PCPlus4) + 4), BIT_DEPTH));
				when others => OpA <= RD1;
			end case;
		when "000011" => OpA <= std_logic_vector(to_unsigned(to_integer(unsigned(PCPlus4) + 4), BIT_DEPTH));
		when "010000" =>
			case RsDest is
				when "00000" => OpA <= COP0Data; --mfc0
				when others => OpA <= RD1;
			end case;
		when others => OpA <= RD1;
	end case;
end process;

PCBranch_proc : process(Opcode, Funct, Instruction, PCPlus4, ImmOut, CmpData1, RsDest, EPC) is begin
	case Opcode is
		when "000010" | "000011" => PCBranch <= PCPlus4(BIT_DEPTH - 1 downto 28) & Instruction (25 downto 0) & "00";
		when "010000" => --COP0
			case RsDest is
				when "10000" =>
					case Funct is
						when "011000" => PCBranch <= EPC; --eret
						when others => PCBranch <= (others => '0');
					end case;
				when others => PCBranch <= (others => '0');
			end case;
		when "000000" =>
			case Funct is
				when "001000" | "001001" => PCBranch <= CmpData1;
				when others => PCBranch <= (others => '0');
			end case;
		when others => PCBranch <= std_logic_vector(signed(unsigned(PCPlus4)) + signed(ImmOut(minimum(15, BIT_DEPTH - 3) downto 0) & "00"));
	end case;
end process;

Opcode <= Instruction (31 downto 26);
RsDest <= Instruction (25 downto 21);
RtDest <= Instruction (20 downto 16);
RdDest <= Instruction (15 downto 11) when Opcode /= "000011" else "11111";
sa     <= Instruction (10 downto 6);
Funct  <= Instruction (5 downto 0);

ImmOut <= std_logic_vector(to_signed(to_integer(signed(Instruction(15 downto 0))), BIT_DEPTH));

end SomeRandomName;
