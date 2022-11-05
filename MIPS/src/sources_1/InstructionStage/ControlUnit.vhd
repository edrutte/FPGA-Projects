library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity ControlUnit is
	Port ( 
		Opcode     : in  std_logic_vector (5 downto 0);
		RegImmInst : in  std_logic_vector (4 downto 0);
		Funct      : in  std_logic_vector (5 downto 0);
		CmpData1   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData2   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		Link       : out std_logic;
		RegWrite   : out std_logic;
		MemtoReg   : out std_logic;
		MemWrite   : out std_logic;
		ALUControl : out std_logic_vector (3 downto 0);
		Except     : out std_logic_vector (3 downto 0);
		ALUSrc     : out std_logic;
		PCSrc      : out std_logic;
		RegDst     : out std_logic;
		CalcBranch : out std_logic;
		rd_hi      : out std_logic;
		rd_lo      : out std_logic;
		we_hi      : out std_logic;
		we_lo      : out std_logic
	);
end ControlUnit;
architecture SomeRandomName of ControlUnit is

signal gtbu      : std_logic;
signal gtb       : std_logic;
signal gtz       : std_logic;
signal eq        : std_logic;
signal z         : std_logic;

begin

compare : entity work.Comparator
	port map (
		a     => CmpData1,
		b     => CmpData2,
		agtb  => gtb,
		agtbu => gtbu,
		aeqb  => eq,
		agtz  => gtz,
		aeqz  => z
	);

Except_proc : process(Opcode, Funct, eq, gtb, gtbu) is begin
	case Opcode is
		when "000000" =>
			case Funct is
				when "110100" => Except <= "000" & eq; --teq
				when "110110" => Except <= "000" & not eq; --tne
				when "110000" => Except <= "000" & (gtb or eq); --tge
				when "110001" => Except <= "000" & (gtbu or eq); --tgeu
				when "110010" => Except <= "000" & not (gtb or eq); --tlt
				when "110011" => Except <= "000" & not (gtbu or eq); --tltu
				when "001101" => Except <= "0010"; --break
				when "001100" => Except <= "0011"; --syscall
				when others => Except <= "0000";
			end case;
		when others => Except <= "0000";
	end case;
end process;

PCSrc_proc : process(Opcode, Funct, eq, gtz, z, RegImmInst) is begin
	case Opcode is
		when "000100" => PCSrc <= eq;
		when "000101" => PCSrc <= not eq;
		when "000111" => PCSrc <= gtz;
		when "000110" => PCSrc <= not gtz;
		when "000001" =>
			case RegImmInst is
				when "00000" => PCSrc <= gtz nor z;
				when "00001" => PCSrc <= gtz or z;
				when others => PCSrc <= '0';
			end case;
		when "000000" =>
			case Funct is
				when "001000" | "001001" => PCSrc <= '1';
				when others => PCSrc <= '0';
			end case;
		when "000010" | "000011" => PCSrc <= '1';
		when others => PCSrc <= '0';
	end case;
end process;

Link_proc : process(Opcode, Funct) is begin
	case Opcode is
		when "000011" => Link <= '1';
		when "000000" =>
			case Funct is
				when "001001" => Link <= '1';
				when others => Link <= '0';
			end case;
		when others => Link <= '0';
	end case;
end process;

RegWrite_proc : process (Opcode, Funct) is begin
	case Opcode is
		when "101011" | "000001" | "000101" | "000111" | "000110" | "000100" | "000010" => RegWrite <= '0';
		when "000000" =>
			case Funct is
				when "011000" | "011001" | "010001" | "010011" | "001000" => RegWrite <= '0'; --mult, multu, mthi, mtlo, jr
				when "110100" | "110110" | "110000" | "110001" | "110010" | "110011" | "001101" | "001100" => RegWrite <= '0'; --traps, break, syscall
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
				when "100000" | "010000" | "010010" | "010011" | "010001" | "001000" | "001001" => ALUControl <= "0100";
				when "100100" => ALUControl <= "1010";
				when "011000" => ALUControl <= "0110";
				when "011001" => ALUControl <= "0111";
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

CalcBranch_proc : process (Opcode, RegImmInst) is begin
	case Opcode is
		when "000100" | "000101" | "000111" | "000110" => CalcBranch <= '1';
		when "000001" =>
			case RegImmInst is
				when "00000" | "00001" => CalcBranch <= '1';
				when others => CalcBranch <= '0';
			end case;
		when others => CalcBranch <= '0';
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
