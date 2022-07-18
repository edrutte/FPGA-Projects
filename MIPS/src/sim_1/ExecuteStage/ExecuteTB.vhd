library ieee;
use ieee.std_logic_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity ExecuteTB is
--  Port ( );
end ExecuteTB;

architecture Tester of ExecuteTB is

function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;

signal clk        : std_logic := '0';
signal ALUControl : std_logic_vector (3 downto 0);
signal ALUSrc     : std_logic;
signal RegDst     : std_logic;
signal RegSrcA    : std_logic_vector (31 downto 0);
signal RegSrcB    : std_logic_vector (31 downto 0);
signal RtDest     : std_logic_vector (4 downto 0);
signal RdDest     : std_logic_vector (4 downto 0);
signal SignImm    : std_logic_vector (31 downto 0);
signal ALUResult  : std_logic_vector (31 downto 0);
signal WriteData  : std_logic_vector (31 downto 0);
signal WriteReg   : std_logic_vector (4 downto 0);

component Execute is
    Port ( clk        : in  std_logic;
           ALUControl : in  std_logic_vector (3 downto 0);
           ALUSrc     : in  std_logic;
           RegDst     : in  std_logic;
           RegSrcA    : in  std_logic_vector (31 downto 0);
           RegSrcB    : in  std_logic_vector (31 downto 0);
           RtDest     : in  std_logic_vector (4 downto 0);
           RdDest     : in  std_logic_vector (4 downto 0);
           SignImm    : in  std_logic_vector (31 downto 0);
           ALUResult  : out std_logic_vector (31 downto 0);
           WriteData  : out std_logic_vector (31 downto 0);
           WriteReg   : out std_logic_vector (4 downto 0)
           );
end component;

type execute_tests is record
	-- Test Inputs
	RegSrcA    : std_logic_vector (31 downto 0);
	RegSrcB    : std_logic_vector (31 downto 0);
	ALUControl : std_logic_vector (3 downto 0);
	ALUSrc     : std_logic;
	SignImm    : std_logic_vector (31 downto 0);
	RegDst     : std_logic;
	RtDest     : std_logic_vector (4 downto 0);
	RdDest     : std_logic_vector (4 downto 0);
	-- Test Outputs
	ALUResult  : std_logic_vector (31 downto 0);
	WriteReg   : std_logic_vector (4 downto 0);
end record;

type test_array is array (natural range <>) of execute_tests;

--TODO: Add at least 2 cases for each operation in the ALU
constant tests : test_array :=(
	(RegSrcA => x"12345678", RegSrcB => x"FEDCBA98", ALUControl => "1010", ALUSrc => '0', SignImm => x"00007F4A", RegDst => '1', RtDest => "00000", RdDest => "00110", ALUResult => x"12141218", WriteReg => "00110"),
	(RegSrcA => x"02155ABC", RegSrcB => x"ABDCA456", ALUControl => "1010", ALUSrc => '1', SignImm => x"FFFF8DAC", RegDst => '0', RtDest => "01111", RdDest => "00000", ALUResult => x"021508AC", WriteReg => "01111"),
	(RegSrcA => x"12344321", RegSrcB => x"55824231", ALUControl => "0100", ALUSrc => '0', SignImm => x"00006FAD", RegDst => '1', RtDest => "00000", RdDest => "00100", ALUResult => x"67B68552", WriteReg => "00100"),
	(RegSrcA => x"7359AC12", RegSrcB => x"64835282", ALUControl => "0100", ALUSrc => '1', SignImm => x"00003291", RegDst => '0', RtDest => "00111", RdDest => "00000", ALUResult => x"7359DEA3", WriteReg => "00111"),
	(RegSrcA => x"00004059", RegSrcB => x"00009816", ALUControl => "0110", ALUSrc => '0', SignImm => x"00000000", RegDst => '1', RtDest => "00000", RdDest => "00000", ALUResult => x"263A5FA6", WriteReg => "00000"),
	(RegSrcA => x"0000DEC0", RegSrcB => x"0000DED0", ALUControl => "0110", ALUSrc => '0', SignImm => x"00000000", RegDst => '1', RtDest => "00000", RdDest => "00000", ALUResult => x"C1DF7C00", WriteReg => "00000"),
	(RegSrcA => x"FB5C9EEC", RegSrcB => x"FC125888", ALUControl => "1000", ALUSrc => '0', SignImm => x"FFFF8323", RegDst => '1', RtDest => "00000", RdDest => "11000", ALUResult => x"FF5EDEEC", WriteReg => "11000"),
	(RegSrcA => x"E80FD2FB", RegSrcB => x"ECA8DEF4", ALUControl => "1000", ALUSrc => '1', SignImm => x"00007952", RegDst => '0', RtDest => "01000", RdDest => "00000", ALUResult => x"E80FFBFB", WriteReg => "01000"),
	(RegSrcA => x"479D0B16", RegSrcB => x"364482F6", ALUControl => "1011", ALUSrc => '0', SignImm => x"FFFF8010", RegDst => '1', RtDest => "00000", RdDest => "00010", ALUResult => x"71D989E0", WriteReg => "00010"),
	(RegSrcA => x"80CE94E0", RegSrcB => x"D77C5C8A", ALUControl => "1011", ALUSrc => '1', SignImm => x"00003C9D", RegDst => '0', RtDest => "00001", RdDest => "00000", ALUResult => x"80CEA87D", WriteReg => "00001"),
	(RegSrcB => x"D0C9F331", RegSrcA => x"0000000E", ALUControl => "1100", ALUSrc => '0', SignImm => x"00001F31", RegDst => '1', RtDest => "00000", RdDest => "11100", ALUResult => x"7CCC4000", WriteReg => "11100"),
	(RegSrcB => x"FB2AD16D", RegSrcA => x"00000010", ALUControl => "1100", ALUSrc => '0', SignImm => x"000053F5", RegDst => '0', RtDest => "11111", RdDest => "00000", ALUResult => x"D16D0000", WriteReg => "11111"),
	(RegSrcB => x"5431F3AF", RegSrcA => x"00000009", ALUControl => "1110", ALUSrc => '0', SignImm => x"0000659D", RegDst => '1', RtDest => "00000", RdDest => "10001", ALUResult => x"002A18F9", WriteReg => "10001"),
	(RegSrcB => x"A6A59075", RegSrcA => x"00000016", ALUControl => "1110", ALUSrc => '0', SignImm => x"FFFFCB1E", RegDst => '0', RtDest => "10011", RdDest => "00000", ALUResult => x"FFFFFE9A", WriteReg => "10011"),
	(RegSrcB => x"861EA09B", RegSrcA => x"00000001", ALUControl => "1101", ALUSrc => '0', SignImm => x"FFFFC304", RegDst => '1', RtDest => "00000", RdDest => "10101", ALUResult => x"430F504D", WriteReg => "10101"),
	(RegSrcB => x"73B74FC3", RegSrcA => x"0000001D", ALUControl => "1101", ALUSrc => '0', SignImm => x"0000549D", RegDst => '0', RtDest => "01010", RdDest => "00000", ALUResult => x"00000003", WriteReg => "01010"),
	(RegSrcA => x"1EB18E92", RegSrcB => x"F21AC77A", ALUControl => "0101", ALUSrc => '0', SignImm => x"00001732", RegDst => '1', RtDest => "00000", RdDest => "01110", ALUResult => x"2C96C718", WriteReg => "01110"),
	(RegSrcA => x"9E36B1FC", RegSrcB => x"51B44f9B", ALUControl => "0101", ALUSrc => '1', SignImm => x"00003E8D", RegDst => '0', RtDest => "11011", RdDest => "00000", ALUResult => x"9E36736F", WriteReg => "11011")
);                                                                                                                                                    
begin

clk <= not clk after 50 ns;

uut: Execute
    port map(
    			clk => clk,
                ALUControl => ALUControl,
                ALUSrc => ALUSrc,
                RegDst => RegDst,
                RegSrcA => RegSrcA,
                RegSrcB => RegSrcB,
                RtDest => RtDest,
                RdDest => RdDest,
                SignImm => SignImm,
                ALUResult => ALUResult,
                WriteData => WriteData,
                WriteReg => WriteReg
            );

stim_proc : process is begin
	for i in tests'range loop
		RegSrcA <= tests(i).RegSrcA;
		RegSrcB <= tests(i).RegSrcB;
		ALUControl <= tests(i).ALUControl;
		ALUSrc <= tests(i).ALUSrc;
		SignImm <= tests(i).SignImm;
		RegDst <= tests(i).RegDst;
		RtDest <= tests(i).RtDest;
		RdDest <= tests(i).RdDest;
			wait for 100 ns;
			assert ALUResult = tests(i).ALUResult 
				report "Expected: " & to_string(tests(i).ALUResult) & " Got: " & to_string(ALUResult)
				severity error;
			assert WriteReg = tests(i).WriteReg 
				report "Expected: " & to_string(tests(i).WriteReg) & " Got: " & to_string(WriteReg)
				severity error;
	end loop;
	assert false 
		report "End of testbench"
		severity failure;
end process;
end Tester;
