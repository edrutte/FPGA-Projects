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
		RegWriteEn   : in  std_logic;
		RegWrite     : out std_logic;
		MemtoReg     : out std_logic;
		MemWrite     : out std_logic;
		ALUControl   : out std_logic_vector (3 downto 0);
		ALUSrc       : out std_logic;
		RegDst       : out std_logic;
		OpA          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RD2          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		RtDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RdDest       : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		Rs           : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		ImmOut       : out std_logic_vector (BIT_DEPTH - 1 downto 0)
	);
end InstructionDecode;

architecture SomeRandomName of InstructionDecode is

signal RtDestTemp : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
signal RD1 : std_logic_vector (BIT_DEPTH - 1 downto 0);

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
		clk_n => clk,
		wd    => RegWriteData,
		we    => RegWriteEn,
		RD1   => RD1,
		RD2   => RD2
	);

with std_logic_vector'(Instruction(31 downto 26) & Instruction(5 downto 0)) select 
	OpA <=
	std_logic_vector(to_signed(to_integer(signed(Instruction (10 downto 6))), BIT_DEPTH)) when "000000000000" | "000000000010" | "000000000011",
	RD1 when others;

Rs     <= Instruction (25 downto 21);
RtDest <= RtDestTemp;
RdDest <= Instruction (15 downto 11);			
ImmOut <= std_logic_vector(to_signed(to_integer(signed(Instruction (15 downto 0))), BIT_DEPTH));

end SomeRandomName;
