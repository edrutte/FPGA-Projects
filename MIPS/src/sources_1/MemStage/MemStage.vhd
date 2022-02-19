library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

--use ieee.numeric_std.all;

entity MemStage is
	Port ( 
		clk          : in  std_logic;
		RegWrite     : in  std_logic;
		MemtoReg     : in  std_logic;
		MemWrite     : in  std_logic;
		ALUResult    : in  std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		WriteData    : in  std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		switches     : in  std_logic_vector ( NUM_SWITCHES - 1 downto 0 );
		WriteReg     : in  std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
		RegWriteOut  : out std_logic;
		MemtoRegOut  : out std_logic;
		WriteRegOut  : out std_logic_vector ( LOG_PORT_DEPTH - 1 downto 0 );
		MemOut       : out std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		ALUResultOut : out std_logic_vector ( BIT_DEPTH - 1 downto 0 );
		active_digit : out std_logic_vector ( 3 downto 0 );
		seven_seg    : out std_logic_vector ( 6 downto 0 )
	);
end MemStage;

architecture Behavioral of MemStage is

signal seven_seg_temp : std_logic_vector ( 15 downto 0 );

component seg7 is
	Port(
		Clock_50MHz      : in  std_logic;
		displayed_number : in  std_logic_vector ( 15 downto 0 );
		Anode_Activate   : out std_logic_vector ( 3 downto 0 );
		LED_out          : out std_logic_vector ( 6 downto 0 )
	);
end component;

begin

mem : entity work.DataMem
	Port map(
		clk       => clk,
		w_en      => MemWrite,
		addr      => ALUResult ( DATA_ADDR_BITS - 1 downto 0 ),
		d_in      => WriteData,
		switches  => switches,
		d_out     => MemOut,
		seven_seg => seven_seg_temp
	);

sev_seg : seg7
	Port map(
		clock_50MHz      => clk,
		displayed_number => seven_seg_temp,
		Anode_Activate   => active_digit,
		LED_out          => seven_seg
	);

RegWriteOut  <= RegWrite;
MemtoRegOut  <= MemtoReg;
WriteRegOut  <= WriteReg;
ALUResultOut <= ALUResult;

end Behavioral;
