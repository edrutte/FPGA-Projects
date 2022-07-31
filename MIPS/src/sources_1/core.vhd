library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity core is
	Port ( 
		clk	        : in  std_logic;
		rst	        : in  std_logic;
		Instruction : in  std_logic_vector (31 downto 0);
		d_in        : in  std_logic_vector (BIT_DEPTH - 1 downto 0);
		we          : out std_logic;
		PC          : out std_logic_vector (27 downto 0);
		d_out       : out std_logic_vector (BIT_DEPTH - 1 downto 0);
		dataAddr    : out std_logic_vector (DATA_ADDR_BITS - 1 downto 0)
	);

end core;

architecture Behavioral of core is

signal fetchOut : std_logic_vector ( 31 downto 0 ) := ( others => '0' );
signal decodeIn : std_logic_vector ( 31 downto 0 ) := ( others => '0' );

signal RegWriteD : std_logic := '0';
signal RegWriteE : std_logic := '0';
signal RegWriteM : std_logic := '0';
signal RegWriteW : std_logic := '0';

signal WriteRegE : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
signal WriteRegM : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
signal WriteRegW : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );

signal MemtoRegD : std_logic := '0';
signal MemtoRegE : std_logic := '0';
signal MemtoRegM : std_logic := '0';
signal MemtoRegW : std_logic := '0';

signal MemWriteD : std_logic := '0';
signal MemWriteE : std_logic := '0';
signal MemWriteM : std_logic := '0';

signal LinkD : std_logic := '0';
signal LinkE : std_logic := '0';
signal LinkM : std_logic := '0';
signal LinkW : std_logic := '0';

signal BranchCalcD : std_logic := '0';

signal TakeDelaySlot : std_logic := '1';

signal PCSrcD : std_logic := '0';

signal PCPlus4F : std_logic_vector(27 downto 0);
signal PCPlus4D : std_logic_vector(27 downto 0);

signal PCBranchD : std_logic_vector(27 downto 0);

signal ALUControlD : std_logic_vector ( 3 downto 0 );
signal ALUControlE : std_logic_vector ( 3 downto 0 );

signal ALUSrcD : std_logic;
signal ALUSrcE : std_logic;

signal RegDstD : std_logic;
signal RegDstE : std_logic;

signal RD1D : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal RD1E : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal RD2D : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal RD2E : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal RsD : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
signal RsE : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );

signal RtD : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
signal RtE : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );

signal RdD : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
signal RdE : std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );

signal ImmD : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ImmE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal ALUResultE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ALUResultM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ALUResultW : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal WriteDataE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal WriteDataM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal MemOutM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal MemOutW : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal result : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal StallF, StallD, FlushE : std_logic;

signal ForwardAD, ForwardBD : std_logic;

signal ForwardAE, ForwardBE : std_logic_vector ( 1 downto 0 );

signal RegSrcA, RegSrcB : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

begin

F_reg : process (clk) is begin
	if rising_edge(clk) then
		if rst = '1' then
			PC <= (others => '0');
		elsif StallF = '0' then
			if PCSrcD = '0' then
				PC <= PCPlus4F;
			else
				PC <= PCBranchD;
			end if;
		end if;
	end if;
end process;

PCPlus4F <= std_logic_vector(to_unsigned((to_integer(unsigned(PC)) + 4), 28));

Decode : entity work.InstructionDecode
	Port map(
		clk          => clk,
		Instruction  => decodeIn,
		RegWriteAddr => WriteRegW,
		RegWriteData => result,
		CmpData      => ALUResultM,
		PCPlus4      => PCPlus4D,
		RegWriteEn   => RegWriteW,
		LinkWriteEn  => LinkW,
		ForwardAD    => ForwardAD,
		ForwardBD    => ForwardBD,
		RegWrite     => RegWriteD,
		MemtoReg     => MemtoRegD,
		MemWrite     => MemWriteD,
		Link         => LinkD,
		CalcBranch   => BranchCalcD,
		PCSrc        => PCSrcD,
		ALUControl   => ALUControlD,
		ALUSrc       => ALUSrcD,
		RegDst       => RegDstD,
		OpA          => RD1D,
		RD2          => RD2D,
		RtDest       => RtD,
		RdDest       => RdD,
		RsDest       => RsD,
		ImmOut       => ImmD,
		PCBranch     => PCBranchD
	);

D_reg : process (clk) is begin
	if rising_edge(clk) then
		if TakeDelaySlot = '0' then
			decodeIn <= (others => '0');
			PCPlus4D <= (others => '0');
		elsif StallD = '0' then
			decodeIn <= fetchOut;
			PCPlus4D <= PCPlus4F;
		end if;
	end if;
end process;
	    
Hazard : entity work.Hazard
	Port map(
		RsD       => RsD,
		RtD       => RtD,
		RsE       => RsE,
		RtE       => RtE,
		StallF    => StallF,
		StallD    => StallD,
		FlushE    => FlushE,
		MemtoRegE => MemtoRegE,
		MemtoRegM => MemToRegM,
		BranchD   => BranchCalcD,
		LinkM     => LinkM,
		LinkW     => LinkW,
		WriteRegE => WriteRegE,
		WriteRegM => WriteRegM,
		WriteRegW => WriteRegW,
		RegWriteE => RegWriteE,
		RegWriteM => RegWriteM,
		RegWriteW => RegWriteW,
		ForwardAE => ForwardAE,
		ForwardBE => ForwardBE,
		ForwardAD => ForwardAD,
		ForwardBD => ForwardBD
	);

RegSrcA_proc : process (ForwardAE, RD1E, result, ALUResultM) is begin
	case ForwardAE is
		when "00"   => RegSrcA <= RD1E;
		when "01"   => RegSrcA <= result;
		when "10"   => RegSrcA <= ALUResultM;
		when others => RegSrcA <= RD1E;
	end case;
end process;

RegSrcB_proc : process (ForwardBE, RD2E, result, ALUResultM) is begin
	case ForwardBE is
		when "00"   => RegSrcB <= RD2E;
		when "01"   => RegSrcB <= result;
		when "10"   => RegSrcB <= ALUResultM;
		when others => RegSrcB <= RD2E;
	end case;
end process;

Execute : entity work.Execute
	Port map(
		clk         => clk,
		ALUControl  => ALUControlE,
		ALUSrc      => ALUSrcE,
		RegDst      => RegDstE,
		RegSrcA     => RegSrcA,
		RegSrcB     => RegSrcB,
		RtDest      => RtE,
		RdDest      => RdE,
		SignImm     => ImmE,
		ALUResult   => ALUResultE,
		WriteData   => WriteDataE,
		WriteReg    => WriteRegE
	);

E_reg : process (clk, FlushE) is begin
	if rising_edge(clk) then
		if FlushE = '1' then
			RegWriteE   <= '0';
			MemWriteE   <= '0';
			MemtoRegE   <= '0';
			ALUSrcE     <= '0';
			RegDstE     <= '0';
			ImmE        <= (others => '0');
			RD2E        <= (others => '0');
			RsE         <= (others => '0');
		else
			RegWriteE   <= RegWriteD;
			MemWriteE   <= MemWriteD;
			MemtoRegE   <= MemtoRegD;
			ALUSrcE     <= ALUSrcD;
			RegDstE     <= RegDstD;
			ImmE        <= ImmD;
			RD2E        <= RD2D;
			RsE         <= RsD;
		end if;
	end if;
end process;

Wb : entity work.Writeback
	Port map(
		MemtoReg    => MemtoRegW,
		ALUResult   => ALUResultW,
		ReadData    => MemOutW,
		Result      => result
	);

stageDiv : process (clk) is begin
	if rising_edge(clk) then
		RD1E        <= RD1D;
		RtE         <= RtD;
		RdE         <= RdD;
		LinkE       <= LinkD;
		LinkM       <= LinkE;
		LinkW       <= LinkM;
		ALUControlE <= ALUControlD;
		RegWriteM   <= RegWriteE;
		MemtoRegM   <= MemtoRegE;
		MemtoRegW   <= MemtoRegM;
		MemWriteM   <= MemWriteE;
		RegWriteW   <= RegWriteM;
		ALUResultM  <= ALUResultE;
		ALUResultW  <= ALUResultM;
		WriteDataM  <= WriteDataE;
		WriteRegM   <= WriteRegE;
		WriteRegW   <= WriteRegM;
		MemOutW     <= MemOutM;
	end if;
end process;

fetchOut <= Instruction;
dataAddr <= ALUResultM ( DATA_ADDR_BITS - 1 downto 0 );
MemOutM <= d_in;
d_out <= WriteDataM;
we <= MemWriteM;

end Behavioral;
