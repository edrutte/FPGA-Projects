library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity Execute is
	Port (
		RegDst      : in  std_logic;
		RegWriteHi  : in  std_logic;
		RegWriteLo  : in  std_logic;
		RegSrcA     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		RegSrcB     : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		RtDest      : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		RdDest      : in  std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
		ALUControl  : in  std_logic_vector (3 downto 0);
		Hi          : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		ALUResult   : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		WriteReg    : out std_logic_vector (LOG_PORT_DEPTH - 1 downto 0)
	);
end Execute;

architecture SomeRandomName of Execute is

signal ALUResult_tmp, Hi_tmp : std_logic_vector (31 downto 0);

begin

ALU : entity work.alu4
	Port map(
		A   => RegSrcA,
		B   => RegSrcB,
		OP  => ALUControl,
		Hi  => Hi_tmp,
		Y   => ALUResult_tmp
	);

with RegDst select WriteReg <=
	RdDest when '1',
	RtDest when others;

Hi_proc : process(RegWriteHi, RegWriteLo, Hi_tmp, ALUResult_tmp) is
	variable HiSel : std_logic_vector (1 downto 0) := std_logic_vector'(RegWriteHi & RegWriteLo);
begin
	HiSel := std_logic_vector'(RegWriteHi & RegWriteLo);
	case HiSel is
		when "10" => Hi <= ALUResult_tmp;
		when others => Hi <= Hi_tmp;
	end case;
end process;

ALUResult <= ALUResult_tmp;

end SomeRandomName;
