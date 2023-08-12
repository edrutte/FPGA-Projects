library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity ControlUnit is
	Port ( 
		Opcode     : in  std_logic_vector (5 downto 0);
		COPop      : in  std_logic_vector (4 downto 0);
		RegImmInst : in  std_logic_vector (4 downto 0);
		Funct      : in  std_logic_vector (5 downto 0);
		CmpData1   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		CmpData2   : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		Link       : out std_logic;
		RegWrite   : out std_logic;
		COP0Write  : out std_logic;
		MemtoReg   : out std_logic;
		MemWrite   : out std_logic;
		ALUControl : out std_logic_vector (3 downto 0);
		Except     : out std_logic_vector (4 downto 0);
		ALUSrc     : out std_logic;
		PCSrc      : out std_logic;
		RegDst     : out std_logic;
		CalcBranch : out std_logic;
		TakeDelay  : out std_logic;
		rd_hi      : out std_logic;
		rd_lo      : out std_logic;
		we_hi      : out std_logic;
		we_lo      : out std_logic;
		eret       : out std_logic
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
				when "110100" | "110110" =>
					if (eq xor Funct(1)) = '1' then
						Except <= "01101"; --teq, tne
					else
						Except <= "00000";
					end if;
				when "110000" | "110010" =>
					if ((gtb or eq) xor Funct(1)) = '1' then
						Except <= "01101"; --tge, tlt
					else
						Except <= "00000";
					end if;
				when "110001" | "110011" =>
					if ((gtbu or eq) xor Funct(1)) = '1' then
						Except <= "01101"; --tgeu, tltu
					else
						Except <= "00000";
					end if;
				when "001101" => Except <= "01001"; --break
				when "001100" => Except <= "01000"; --syscall
				when others => Except <= "00000";
			end case;
		when others => Except <= "00000";
	end case;
end process;

eret_proc : process(Opcode, COPop, Funct) is begin
	case Opcode is
		when "010000" => --COP0
			case COPop is
				when "10000" =>
					if Funct = "011000" then
						eret <= '1';
					else
						eret <= '0';
					end if;
				when others => eret <= '0';
			end case;
		when others => eret <= '0';
	end case;
end process;

PCSrc_proc : process(Opcode, Funct, eq, gtz, z, RegImmInst, COPop) is begin
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
		when "010000" => --COP0
			case COPop is
				when "10000" =>
					if Funct = "011000" then
						PCSrc <= '1'; --eret
					else
						PCSrc <= '0';
					end if;
				when others => PCSrc <= '0';
			end case;
		when others => PCSrc <= '0';
	end case;
end process;

TakeDelay_proc : process(Opcode, COPop, Funct) is begin
	case Opcode is
		when "010000" => --COP0
			case COPop is
				when "10000" =>
					case Funct is
						when "011000" => TakeDelay <= '0'; --eret
						when others => TakeDelay <= '1';
					end case;
				when others => TakeDelay <= '1';
			end case;
		when others => TakeDelay <= '1';
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

RegWrite_proc : process (Opcode, Funct, COPop) is begin
	case Opcode is
		when "101011" | "000001" | "000101" | "000111" | "000110" | "000100" | "000010" => RegWrite <= '0';
		when "010000" => --COP0
			case COPop is
				when "00000" => RegWrite <= '1'; --mf
				when "00100" => RegWrite <= '0'; --mt
				when "10000" =>
					case Funct is
						when "011000" => RegWrite <= '0'; --eret
						when others => RegWrite <= '0';
					end case;
				when others => RegWrite <= '0';
			end case;
		when "000000" =>
			case Funct is
				when "011000" | "011001" | "010001" | "010011" | "001000" => RegWrite <= '0'; --mult, multu, mthi, mtlo, jr
				when "110100" | "110110" | "110000" | "110001" | "110010" | "110011" | "001101" | "001100" => RegWrite <= '0'; --traps, break, syscall
				when others => RegWrite <= '1';
			end case;
		when others => RegWrite <= '1';
	end case;
end process;

COP0Write_proc : process (Opcode, Funct, COPop, eq, gtb, gtbu) is begin
	case Opcode is
		when "000000" =>
			case Funct is
				when "110100" | "110110" => COP0Write <= (eq xor Funct(1)); --teq, tne
				when "110000" | "110010" => COP0Write <= ((gtb or eq) xor Funct(1)); --tge, tlt
				when "110001" | "110011" => COP0Write <= ((gtbu or eq) xor Funct(1)); --tgeu, tltu
				when "001101" | "001100" => COP0Write <= '1'; --break, syscall
				when others => COP0Write <= '0';
			end case;
		when "010000" => --COP0
			case COPop is
				when "00100" => COP0Write <= '1';
				when others => COP0Write <= '0';
			end case;
		when others => COP0Write <= '0';
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
				when others   => ALUControl <= "1100";
			end case;
		when others => ALUControl <= "1100";
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
	
RegDst_proc : process (Opcode, COPop) is begin
	case Opcode is
		when "000000" | "000011" => RegDst <= '1';
		when "010000" =>
			case COPop is
				when "00100" => RegDst <= '1'; --mt
				when others => RegDst <= '0';
			end case;
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
