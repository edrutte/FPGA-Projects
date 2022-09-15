library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity MIPS is
	Generic (
		SIM : boolean := FALSE
	);
	Port ( 
		clk	    : in  std_logic;
		rst	    : in  std_logic;
		sw	    : in  std_logic_vector (NUM_SWITCHES - 1 downto 0);
		an_7seg : out std_logic_vector (3 downto 0) := "1111";
		ag_seg  : out std_logic_vector (6 downto 0) := "1111111";
		seg_dot : out std_logic := '1'
	);
end MIPS;

architecture Behavioral of MIPS is

signal PC          : std_logic_vector (27 downto 0) := (others => '0');
signal Instruction : std_logic_vector (31 downto 0) := (others => '0');

signal dataAddr    : std_logic_vector (DATA_ADDR_BITS - 1 downto 0);
signal readData    : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal writeData   : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal we          : std_logic := '0';

signal displayed_number : std_logic_vector(15 downto 0);

signal clk_out1 : std_logic := '0';

signal swMeta   : std_logic_vector (NUM_SWITCHES - 1 downto 0) := (others => '0');
signal swNoMeta : std_logic_vector (NUM_SWITCHES - 1 downto 0) := (others => '0');

signal rst_debounce : std_logic := '0';

signal rstMeta   : std_logic := '0';
signal rstNoMeta : std_logic := '0';

component clk_wiz_0
	port(
		clkIn    : in  std_logic;
		clk_out1 : out std_logic
	);
end component;

component seg7 is
	Port(
		Clock_50MHz      : in  std_logic;
		displayed_number : in  std_logic_vector (15 downto 0);
		Anode_Activate   : out std_logic_vector (3 downto 0);
		LED_out          : out std_logic_vector (6 downto 0)
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

real_synth : if not SIM generate
	clk_div : clk_wiz_0
		Port map(
			clk_out1 => clk_out1,
			clkIn    => clk
		);

	Debouncer : entity work.debounce
		Port map(
			clk          => clk_out1,
			rst          => '0',
			button_in    => rstNoMeta,
			button_out_p => rst_debounce
		);
end generate;

fast_sim : if SIM generate
	rst_debounce <= rst;
	clk_out1 <= clk;
end generate;

memI : entity work.InstructionMem
	Port map(
		addr => PC,
		d_out => Instruction
	);

cpu : entity work.core
	Port map(
		clk         => clk_out1,
		rst         => rst_debounce,
		PC          => PC,
		Instruction => Instruction,
		dataAddr    => dataAddr,
		d_in        => readData,
		we          => we,
		d_out       => writeData
	);

memD : entity work.DataMem
	Port map(
		clk       => clk_out1,
		w_en      => we,
		addr      => dataAddr,
		d_in      => writeData,
		switches  => swNoMeta,
		d_out     => readData,
		seven_seg => displayed_number
	);

sev_seg : seg7
	Port map(
		clock_50MHz      => clk_out1,
		displayed_number => displayed_number,
		Anode_Activate   => an_7seg,
		LED_out          => ag_seg
	);

unmeta_proc : process (clk_out1) is begin
	if rising_edge(clk_out1) then
		swMeta <= sw;
		swNoMeta <= swMeta;
		rstMeta <= rst;
		rstNoMeta <= rstMeta;
	end if;
end process;

end Behavioral;
