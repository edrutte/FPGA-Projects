library ieee;
use ieee.std_logic_1164.all;

--use ieee.numeric_std.all;

entity Execute is
	Port (
		clk         : in  std_logic;
		ALUSrc      : in  std_logic;
		RegDst      : in  std_logic;
		RegSrcA     : in  std_logic_vector (31 downto 0);
		RegSrcB     : in  std_logic_vector (31 downto 0);
		SignImm     : in  std_logic_vector (31 downto 0);
		RtDest      : in  std_logic_vector (4 downto 0);
		RdDest      : in  std_logic_vector (4 downto 0);
		ALUControl  : in  std_logic_vector (3 downto 0);
		ALUResult   : out std_logic_vector (31 downto 0);
		WriteData   : out std_logic_vector (31 downto 0);
		WriteReg    : out std_logic_vector (4 downto 0)
	);
end Execute;

architecture SomeRandomName of Execute is

signal ALUop2 : std_logic_vector (31 downto 0);

begin

ALU : entity work.alu4
	generic map(
		COMBINE_MULADD => true
	)
	Port map(
		clk => clk,
		A   => RegSrcA,
		B   => ALUop2,
		OP  => ALUControl,
		Y   => ALUResult
	);

with ALUSrc select ALUop2 <=
	SignImm when '1',
	RegSrcB when others;

with RegDst select WriteReg <=
	RdDest when '1',
	RtDest when others;

WriteData <= RegSrcB;

end SomeRandomName;
