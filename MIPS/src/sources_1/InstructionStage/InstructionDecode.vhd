library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

use ieee.numeric_std.all;

entity InstructionDecode is
	Port ( 
		clk          : in  std_logic;
		Instruction  : in  std_logic_vector (31 downto 0);
		RegWriteAddr : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RegWriteData : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData      : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCPlus4      : in  std_logic_vector (27 downto 0);
		RegWriteEn   : in  std_logic;
		LinkWriteEn  : in  std_logic;
		ForwardAD    : in  std_logic;
		ForwardBD    : in  std_logic;
		RegWrite     : out std_logic;
		MemtoReg     : out std_logic;
		MemWrite     : out std_logic;
		Link         : out std_logic;
		CalcBranch   : out std_logic;
		PCSrc        : out std_logic;
		ALUControl   : out std_logic_vector (3 downto 0);
		ALUSrc       : out std_logic;
		RegDst       : out std_logic;
		OpA          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RtDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RdDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RsDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		ImmOut       : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCBranch     : out std_logic_vector (27 downto 0)
	);
end InstructionDecode;

architecture SomeRandomName of InstructionDecode is

signal RegBrCalc   : std_logic;
signal RegImmBr    : std_logic;
signal Opcode      : std_logic_vector (5 downto 0);
signal CmpIn1      : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal CmpIn2      : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal Funct       : std_logic_vector (5 downto 0);
signal RD1         : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal eq          : std_logic;
signal gt          : std_logic;
signal sa          : std_logic_vector (4 downto 0);
signal z           : std_logic;

begin

CU : entity work.ControlUnit
	port map (
		Opcode     => Opcode,
		RegImmInst => RtDest,
		Funct      => Funct,
		Link       => Link,
		RegWrite   => RegWrite,
		MemtoReg   => MemtoReg,
		MemWrite   => MemWrite,
		ALUControl => ALUControl,
		ALUSrc     => ALUSrc,
		RegDst     => RegDst
	);
		
RegFile : entity work.RegisterFile
	Port map (
		clk_n => clk,
		Addr1 => RsDest,
		Addr2 => Instruction (20 downto 16),
		Addr3 => RegWriteAddr,
		wd    => RegWriteData,
		we    => RegWriteEn,
		Link  => LinkWriteEn,
		RD1   => RD1,
		RD2   => RD2
	);

compare : entity work.Comparator
	port map (
		a     => CmpIn1,
		b     => CmpIn2,
		aeqb  => eq,
		agtz  => gt,
		aeqz  => z
	);

OpA_proc : process(Opcode, Funct, RD1, sa, PCPlus4) is begin
	case Opcode is
		when "000000" =>
			case Funct is
				when "000000" | "000010" | "000011" => OpA <= std_logic_vector(to_unsigned(to_integer(unsigned(sa)), BIT_DEPTH));
				when others => OpA <= RD1;
			end case;
		when "000011" => OpA <= std_logic_vector(to_unsigned(to_integer(unsigned(PCPlus4) + 4), BIT_DEPTH));
		when others => OpA <= RD1;
	end case;
end process;

with Opcode select
	PCSrc <=
		eq when "000100",
		not eq when "000101",
		gt when "000111",
		not gt when "000110",
		RegImmBr when "000001",
		'1' when "000010" | "000011",
		'0' when others;

with Opcode select
	CalcBranch <=
		'1' when "000100" | "000101" | "000111" | "000110",
		RegBrCalc when "000001",
		'0' when others;

with RtDest select
	RegImmBr <=
		gt nor z when "00000",
		gt or z when "00001",
		'0' when others;

with RtDest select
	RegBrCalc <=
		'1' when "00000" | "00001",
		'0' when others;

with Opcode select
	PCBranch <=
		Instruction (25 downto 0) & "00" when "000010" | "000011",
		std_logic_vector(signed(unsigned(PCPlus4)) + signed(ImmOut(15 downto 0) & "00")) when others;

CmpIn1 <= CmpData when ForwardAD = '1' else RD1;
CmpIn2 <= CmpData when ForwardBD = '1' else RD2;

Opcode <= Instruction (31 downto 26);
RsDest <= Instruction (25 downto 21);
RtDest <= Instruction (20 downto 16) when Link = '0' else "11111";
RdDest <= Instruction (15 downto 11) when Link = '0' else "11111";
sa     <= Instruction (10 downto 6);
Funct  <= Instruction (5 downto 0);

ImmOut <= std_logic_vector(to_signed(to_integer(signed(Instruction (15 downto 0))), BIT_DEPTH));

end SomeRandomName;
