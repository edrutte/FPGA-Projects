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
		RegDst     : out std_logic;
		CalcBranch : out std_logic;
		rd_hi      : out std_logic;
		rd_lo      : out std_logic;
		we_hi      : out std_logic;
		we_lo      : out std_logic
	);
end ControlUnit;
architecture SomeRandomName of ControlUnit is

signal RegBrCalc : std_logic;

begin

Link_proc : process(Opcode) is begin
	case Opcode is
		when "000011" => Link <= '1';
		when others => Link <= '0';
	end case;
end process;

RegWrite_proc : process (Opcode, Funct) is begin
	case Opcode is
		when "101011" | "000001" | "000101" | "000111" | "000110" | "000100" | "000010" => RegWrite <= '0';
		when "000000" =>
			case Funct is
				when "011000" | "011001" | "010001" | "010011" | "001000" => RegWrite <= '0'; --mult, multu, mthi, mtlo, jr
				when others => RegWrite <= '1';
			end case;
		when others => RegWrite <= '1';
	end case;
end process;
	
MemtoReg_proc : process (Opcode) is begin
	case Opcode is
		when "100011" => MemtoReg <= '1';
		when others => MemtoReg <= '0';
	end case;
end process;
	
MemWrite_proc :process (Opcode) is begin
	case Opcode is
		when "101011" => MemWrite <= '1';
		when others => MemWrite <= '0';
	end case;
end process;
	
ALUControl_proc : process (Opcode, Funct) is begin
	case Opcode is
		when "001000" | "101011" | "100011" | "000011" => ALUControl <= "0100";
		when "001100" => ALUControl <= "1010";
		when "001101" => ALUControl <= "1000";
		when "001110" => ALUControl <= "1011";
		when "000000" =>
			case Funct is
				when "100000" | "010000" | "010010" | "010011" | "010001" | "001000" => ALUControl <= "0100";
				when "100100" => ALUControl <= "1010";
				when "011001" | "011000" => ALUControl <= "0110";
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
	case Opcode is
		when "000000" | "000011" => RegDst <= '1';
		when others => RegDst <= '0';
	end case;
end process;

with Opcode select
    CalcBranch <=
        '1' when "000100" | "000101" | "000111" | "000110",
        RegBrCalc when "000001",
        '0' when others;

with RegImmInst select
    RegBrCalc <=
        '1' when "00000" | "00001",
        '0' when others;

with Opcode & Funct select
    we_hi <=
    '1' when "000000011001" | "000000010001" | "000000011000", --multu, mthi, mult
        '0' when others;

with Opcode & Funct select
    we_lo <=
    '1' when "000000011001" | "000000010011" | "000000011000", --multu, mtlo, mult
        '0' when others;

rd_hi <= '1' when Opcode & Funct = "000000010000" else '0';
rd_lo <= '1' when Opcode & Funct = "000000010010" else '0';

end SomeRandomName;
