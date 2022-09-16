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
		HiWriteData  : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData1     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData2     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		PCPlus4      : in  std_logic_vector (27 downto 0);
		RegWriteEn   : in  std_logic;
		RegWriteHi   : in  std_logic;
		RegWriteLo   : in  std_logic;
		RegWrite     : out std_logic;
		MemtoReg     : out std_logic;
		MemWrite     : out std_logic;
		Link         : out std_logic;
		CalcBranch   : out std_logic;
		PCSrc        : out std_logic;
		ALUControl   : out std_logic_vector (3 downto 0);
		ALUSrc       : out std_logic;
		RegDst       : out std_logic;
		we_hi        : out std_logic;
		we_lo        : out std_logic;
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

signal Opcode      : std_logic_vector (5 downto 0);
signal Funct       : std_logic_vector (5 downto 0);
signal rd_hi       : std_logic;
signal rd_lo       : std_logic;
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
		RegDst     => RegDst,
		CalcBranch => CalcBranch,
		rd_hi      => rd_hi,
		rd_lo      => rd_lo,
		we_hi      => we_hi,
		we_lo      => we_lo
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
		we_hi => RegWriteHi,
		we_lo => RegWriteLo,
		RD1   => RD1,
		RD2   => RD2
	);

compare : entity work.Comparator
	port map (
		a     => CmpData1,
		b     => CmpData2,
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

PCSrc_proc : process(Opcode, Funct, eq, gt, z, RtDest) is begin
	case Opcode is
		when "000100" => PCSrc <= eq;
		when "000101" => PCSrc <= not eq;
		when "000111" => PCSrc <= gt;
		when "000110" => PCSrc <= not gt;
		when "000001" =>
			case RtDest is
				when "00000" => PCSrc <= gt nor z;
				when "00001" => PCSrc <= gt or z;
				when others => PCSrc <= '0';
			end case;
		when "000000" =>
			case Funct is
				when "001000" => PCSrc <= '1';
				when others => PCSrc <= '0';
			end case;
		when "000010" | "000011" => PCSrc <= '1';
		when others => PCSrc <= '0';
	end case;
end process;

PCBranch_proc : process(Opcode, Funct, Instruction, PCPlus4, ImmOut, RD1) is begin
	case Opcode is
		when "000010" | "000011" => PCBranch <= Instruction (25 downto 0) & "00";
		when "000000" =>
			case Funct is
				when "001000" => PCBranch <= RD1 (27 downto 0);
				when others => PCBranch <= std_logic_vector(signed(unsigned(PCPlus4)) + signed(ImmOut(15 downto 0) & "00"));
			end case;
		when others => PCBranch <= std_logic_vector(signed(unsigned(PCPlus4)) + signed(ImmOut(15 downto 0) & "00"));
	end case;
end process;

Opcode <= Instruction (31 downto 26);
RsDest <= Instruction (25 downto 21);
RtDest <= Instruction (20 downto 16);
RdDest <= Instruction (15 downto 11) when Link = '0' else "11111";
sa     <= Instruction (10 downto 6);
Funct  <= Instruction (5 downto 0);

ImmOut <= std_logic_vector(to_signed(to_integer(signed(Instruction(15 downto 0))), BIT_DEPTH));

end SomeRandomName;
