library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity MIPS is
	Port ( 
		clk	     : in  std_logic;
		rst	     : in  std_logic;
		sw	     : in  std_logic_vector ( NUM_SWITCHES - 1 downto 0 );
		--ALUResult    : out std_logic_vector ( 31 downto 0 );
		an_7seg      : out std_logic_vector ( 3 downto 0 );
		ag_seg       : out std_logic_vector ( 6 downto 0 ) := "0000000";
		seg_dot      : out std_logic
	);

	attribute dont_touch         : string;
	attribute dont_touch of MIPS : entity is "true";

end MIPS;

architecture Behavioral of MIPS is

attribute dont_touch of Behavioral : architecture is "true";
attribute dont_touch of Fetch      : label is "true";
attribute dont_touch of Decode     : label is "true";
attribute dont_touch of Execute    : label is "true";
attribute dont_touch of Mem        : label is "true";
attribute dont_touch of Wb         : label is "true";

signal clk_out1 : std_logic := '0';

signal swMeta : std_logic_vector ( NUM_SWITCHES - 1 downto 0 );
signal swNoMeta : std_logic_vector ( NUM_SWITCHES - 1 downto 0 );

signal rst_debounce : std_logic;

--signal rstMeta   : std_logic;
--signal rstNoMeta : std_logic;

signal fetchOut : std_logic_vector ( 31 downto 0 );
signal decodeIn : std_logic_vector ( 31 downto 0 ) := ( others => '0' );

signal RegWriteD : std_logic;
signal RegWriteE : std_logic;
signal RegWriteM : std_logic;
signal RegWriteW : std_logic;

signal RegWriteOutE : std_logic;
signal RegWriteOutM : std_logic;
signal RegWriteOutW : std_logic;

signal WriteRegE : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal WriteRegM : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal WriteRegW : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );

signal WriteRegOutM : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal WriteRegOutW : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );

signal MemtoRegD : std_logic;
signal MemtoRegE : std_logic;
signal MemtoRegM : std_logic;
signal MemtoRegW : std_logic;

signal MemtoRegOutE : std_logic;
signal MemtoRegOutM : std_logic;

signal MemWriteD : std_logic;
signal MemWriteE : std_logic;
signal MemWriteM : std_logic;

signal MemWriteOutE : std_logic;

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

signal RsD : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal RsE : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );

signal RtD : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal RtE : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );

signal RdD : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );
signal RdE : std_logic_vector ( LOG_Port_DEPTH - 1 downto 0 );

signal ImmD : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ImmE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal ALUResultE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ALUResultM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal ALUResultW : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal ALUResultOutM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal WriteDataE : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal WriteDataM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal MemOutM : std_logic_vector ( BIT_DEPTH - 1 downto 0 );
signal MemOutW : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal result : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

signal StallF, StallD, FlushE : std_logic;

signal ForwardAE, ForwardBE : std_logic_vector ( 1 downto 0 );

signal RegSrcA, RegSrcB : std_logic_vector ( BIT_DEPTH - 1 downto 0 );

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clkIn           : in     std_logic
 );
end component;

begin

--slow_clk_proc : process (clk) is 

--variable clk_divider : unsigned (1 downto 0) := (others => '0');

--begin
	--if rising_edge(clk) then
		--clk_divider := clk_divider + 1;
		--if clk_divider(0) = '1' then
			--clk_out1 <= not clk_out1;
			--clk_divider := (others => '0');
		--end if;
	--end if;
--end process;

clk_div : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_out1,
   -- Clock in ports
   clkIn => clk
 );

Fetch : entity work.InstructionFetch
	Port map(
		clk         => clk_out1,
		rst         => rst_debounce,
		StallF      => StallF,
		Instruction => fetchOut
	);

Debouncer : entity work.debounce
	Port map(
		clk          => clk_out1,
		rst          => '0',
		button_in    => rst,
		button_out_p => rst_debounce
	);

Decode : entity work.InstructionDecode
	Port map(
		clk          => clk_out1,
		Instruction  => decodeIn,
		RegWriteAddr => WriteRegOutW,
		RegWriteData => result,
		RegWriteEn   => RegWriteOutW,
		RegWrite     => RegWriteD,
		MemtoReg     => MemtoRegD,
		MemWrite     => MemWriteD,
		ALUControl   => ALUControlD,
		ALUSrc       => ALUSrcD,
		RegDst       => RegDstD,
		OpA          => RD1D,
		RD2          => RD2D,
		RtDest       => RtD,
		RdDest       => RdD,
		Rs           => RsD,
		ImmOut       => ImmD
	);
	    
Hazard : entity work.Hazard
	Port map(
		RsD       => RsD,
		RtD       => RtD,
		RsE       => RsE,
		RtE       => RtE,
		StallF    => StallF,
		StallD    => StallD,
		FlushE    => FlushE,
		MemtoReg  => MemtoRegE,
		WriteRegM => WriteRegM,
		WriteRegW => WriteRegW,
		RegWriteM => RegWriteM,
		RegWriteW => RegWriteW,
		ForwardAE => ForwardAE,
		ForwardBE => ForwardBE
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
		RegWrite    => RegWriteE,
		MemtoReg    => MemtoRegE,
		MemWrite    => MemWriteE,
		ALUControl  => ALUControlE,
		ALUSrc      => ALUSrcE,
		RegDst      => RegDstE,
		RegSrcA     => RegSrcA,
		RegSrcB     => RegSrcB,
		RtDest      => RtE,
		RdDest      => RdE,
		SignImm     => ImmE,
		RegWriteOut => RegWriteOutE,
		MemtoRegOut => MemtoRegOutE,
		MemWriteOut => MemWriteOutE,
		ALUResult   => ALUResultE,
		WriteData   => WriteDataE,
		WriteReg    => WriteRegE
	);

Mem : entity work.MemStage
	Port map(
		clk                      => clk_out1,
		RegWrite                 => RegWriteM,
		MemtoReg                 => MemtoRegM,
		WriteReg                 => WriteRegM,
		MemWrite                 => MemWriteM,
		ALUResult                => ALUResultM,
		WriteData                => WriteDataM,
		switches                 => swNoMeta,
		RegWriteOut              => RegWriteOutM,
		MemtoRegOut              => MemtoRegOutM,
		WriteRegOut              => WriteRegOutM,
		MemOut                   => MemOutM,
		ALUResultOut             => ALUResultOutM,
		active_digit             => an_7seg,
		seven_seg ( 6 downto 0 ) => ag_seg
	);

Wb : entity work.Writeback
	Port map(
		WriteReg    => WriteRegW,
		RegWrite    => RegWriteW,
		MemtoReg    => MemtoRegW,
		ALUResult   => ALUResultW,
		ReadData    => MemOutW,
		Result      => result,
		WriteRegOut => WriteRegOutW,
		RegWriteOut => RegWriteOutW
	);

stageDiv : process (clk_out1) is begin
	if rising_edge(clk_out1) then
		MemtoRegM   <= MemtoRegOutE;
		MemtoRegW   <= MemtoRegOutM;
		MemWriteM   <= MemWriteOutE;
		RegWriteW   <= RegWriteOutM;
		ALUResultM  <= ALUResultE;
		ALUResultW  <= ALUResultOutM;
		WriteDataM  <= WriteDataE;
		WriteRegM   <= WriteRegE;
		WriteRegW   <= WriteRegOutM;
		MemOutW     <= MemOutM;
		swMeta      <= sw;
		swNoMeta    <= swMeta;
		--rstMeta   <= rst;
		--rstNoMeta <= rstMeta;
	end if;
end process;

D_reg : process (clk_out1, StallD) is begin
	if StallD = '0' then
		if rising_edge(clk_out1) then
			decodeIn <= fetchOut;
		end if;
	end if;
end process;

E_reg : process (clk_out1, FlushE) is begin
	if rising_edge(clk_out1) then
		if FlushE = '1' then
			RegWriteE   <= '0';
			RegWriteM   <= '0';
			MemWriteE   <= '0';
			MemtoRegE   <= '0';
			ALUSrcE     <= '0';
			RegDstE     <= '0';
			ImmE        <= (others => '0');
			RtE         <= (others => '0');
			RsE         <= (others => '0');
			RdE         <= (others => '0');	 
			RD1E        <= (others => '0');
			RD2E        <= (others => '0');
			ALUControlE <= (others => '0');
		else
			RegWriteE   <= RegWriteD;
			RegWriteM   <= RegWriteOutE;
			MemWriteE   <= MemWriteD;
			MemtoRegE   <= MemtoRegD;
			RdE         <= RdD;
			RD1E        <= RD1D;
			RD2E        <= RD2D;
			ALUControlE <= ALUControlD;
			ALUSrcE     <= ALUSrcD;
			RegDstE     <= RegDstD;
			ImmE        <= ImmD;
			RtE         <= RtD;
			RsE         <= RsD;
		end if;
	end if;
end process;
	
seg_dot <= '1';
--ALUResult <= ALUresultE;
end Behavioral;
