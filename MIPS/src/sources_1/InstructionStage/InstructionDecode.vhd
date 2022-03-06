library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

use ieee.numeric_std.all;

entity InstructionDecode is
	Port ( 
		clk_n        : in  std_logic;
		Instruction  : in  std_logic_vector (31 downto 0);
		RegWriteAddr : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RegWriteData : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData      : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCPlus4      : in  std_logic_vector (27 downto 0);
		RegWriteEn   : in  std_logic;
		ForwardAD    : in  std_logic;
		ForwardBD    : in  std_logic;
		RegWrite     : out std_logic;
		MemtoReg     : out std_logic;
		MemWrite     : out std_logic;
		Branch       : out std_logic;
		ALUControl   : out std_logic_vector (3 downto 0);
		ALUSrc       : out std_logic;
		RegDst       : out std_logic;
		OpA          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RtDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RdDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Rs           : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		ImmOut       : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCBranch     : out std_logic_vector (27 downto 0)
	);
end InstructionDecode;

architecture SomeRandomName of InstructionDecode is

signal RtDestTemp  : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
signal RegImmBr    : std_logic;
signal CmpIn1      : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal CmpIn2      : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal RD1         : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal eq          : std_logic;
signal gt          : std_logic;
signal z           : std_logic;

begin

RtDestTemp <= Instruction (20 downto 16);

CU : entity work.ControlUnit
	port map (
		Opcode     => Instruction (31 downto 26),
		Funct      => Instruction (5 downto 0),
		RegWrite   => RegWrite,
		MemtoReg   => MemtoReg,
		MemWrite   => MemWrite,
		ALUControl => ALUControl,
		ALUSrc     => ALUSrc,
		RegDst     => RegDst
	);
		
RegFile : entity work.RegisterFile
	Port map (
		Addr1 => Instruction (25 downto 21),
		Addr2 => Instruction (20 downto 16),
		Addr3 => RegWriteAddr,
		clk_n => clk_n,
		wd    => RegWriteData,
		we    => RegWriteEn,
		RD1   => RD1,
		RD2   => RD2
	);

compare : entity work.Comparator
	port map (
		clk_n => clk_n,
		a     => CmpIn1,
		b     => CmpIn2,
		aeqb  => eq,
		agtz  => gt,
		aeqz  => z
	);

with Instruction(31 downto 26) select
	Branch <=
		eq when "000100",
		not eq when "000101",
		gt when "000111",
		not gt when "000110",
		RegImmBr when "000001",
		'0' when others;

with RtDestTemp select
	RegImmBr <=
		gt nand z when "00000",
		gt or z when "00001",
		'0' when others;


with std_logic_vector'(Instruction(31 downto 26) & Instruction(5 downto 0)) select 
	OpA <=
		std_logic_vector(to_unsigned(to_integer(unsigned(Instruction(10 downto 6))), BIT_DEPTH)) when "000000000000" | "000000000010" | "000000000011" | "000000000111",
		RD1 when others;

CmpIn1 <= CmpData when ForwardAD = '1' else RD1;
CmpIn2 <= CmpData when ForwardBD = '1' else RD2;

PCBranch <= std_logic_vector(signed(PCPlus4) + signed(ImmOut(15 downto 0) & "00"));
Rs       <= Instruction (25 downto 21);
RtDest   <= RtDestTemp;
RdDest   <= Instruction (15 downto 11);
ImmOut   <= std_logic_vector(to_signed(to_integer(signed(Instruction (15 downto 0))), BIT_DEPTH));

end SomeRandomName;
