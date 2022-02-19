library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity Writeback is
	Port(
		WriteReg            : in  std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
		RegWrite, MemtoReg  : in  std_logic;
		ALUResult, ReadData : in  std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		Result              : out std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		WriteRegOut         : out std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
		RegWriteOut         : out std_logic
	);
end entity;

architecture SomeRandomName of Writeback is

begin

WbData_proc : process (ReadData, MemtoReg, ALUResult) is begin
	if MemtoReg = '1' then
		Result <= ReadData;
	else
		Result <= ALUResult;
	end if;
end process;

WriteRegOut <= WriteReg;
RegWriteOut <= RegWrite;

end;
