library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity Writeback is
	Port(
		MemtoReg            : in  std_logic;
		ALUResult, ReadData : in  std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		Result              : out std_logic_vector ( BIT_DEPTH - 1 downto 0 )
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

end;
