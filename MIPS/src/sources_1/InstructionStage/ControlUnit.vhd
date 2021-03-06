library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity ControlUnit is
	Port ( 
		Opcode     : in  std_logic_vector (5 downto 0);
		RegImmInst : in  std_logic_vector (4 downto 0);
		Funct      : in  std_logic_vector (5 downto 0);
		Link       : out std_logic;
		RegWrite   : out std_logic;
		MemtoReg   : out std_logic;
		MemWrite   : out std_logic;
		ALUControl : out std_logic_vector (3 downto 0);
		ALUSrc     : out std_logic;
		RegDst     : out std_logic
	);
end ControlUnit;
architecture SomeRandomName of ControlUnit is

begin

Link_proc : process(Opcode) is begin
	case Opcode is
		when "000011" => Link <= '1';
		when others => Link <= '0';
	end case;
end process;

RegWrite_proc : process (Opcode) is begin
	case Opcode is
		when "101011" | "000001" | "000101" | "000111" | "000110" | "000100" | "000010" | "000011" => RegWrite <= '0';
		when others => RegWrite <= '1';
	end case;
end process;
	
MemtoReg_proc : process (Opcode) is begin
	if Opcode = "100011" then
		MemtoReg <= '1';
	else
		MemtoReg <= '0';
	end if;
end process;
	
MemWrite_proc :process (Opcode) is begin
	if Opcode = "101011" then
		MemWrite <= '1';
	else
		MemWrite <= '0';
	end if;
end process;
	
ALUControl_proc : process (Opcode, Funct) is begin
	case Opcode is
		when "001000" | "101011" | "100011" | "000011" => ALUControl <= "0100";
		when "001100" => ALUControl <= "1010";
		when "001101" => ALUControl <= "1000";
		when "001110" => ALUControl <= "1011";
		when "000000" =>
			case Funct is
				when "100000" => ALUControl <= "0100";
				when "100100" => ALUControl <= "1010";
				when "011001" => ALUControl <= "0110";
				when "100101" => ALUControl <= "1000";
				when "000000" | "000100" => ALUControl <= "1100";
				when "000011" | "000111" => ALUControl <= "1110";
				when "000010" | "000110" => ALUControl <= "1101";
				when "100010" => ALUControl <= "0101";
				when "100110" => ALUControl <= "1011";
				when others   => ALUControl <= "0000";
			end case;
		when others => ALUControl <= "0000";
	end case;
end process;
	
ALUSrc_proc : process (Opcode) is begin
	case Opcode is
		when "000000" | "000011" => ALUSrc <= '0';
		when others => ALUSrc <= '1';
	end case;
end process;
	
RegDst_proc : process (Opcode) is begin
	if Opcode = "000000" then
		RegDst <= '1';
	else
		RegDst <= '0';
	end if;
end process;
	
end SomeRandomName;
