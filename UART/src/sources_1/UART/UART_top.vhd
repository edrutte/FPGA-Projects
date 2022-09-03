library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_top is
	Generic (
		CLK_IN_MHZ : integer := 50;
		BAUD_RATE  : integer := 115200
	);
	Port (
		clk      : in  std_logic;
		tx_data  : in  std_logic_vector (7 downto 0);
		tx_send  : in  std_logic;
		rx_in    : in  std_logic;
		rx_data  : out std_logic_vector (7 downto 0);
		tx_ready : out std_logic;
		rx_ready : out std_logic;
		tx_out   : out std_logic
	);
end UART_top;

architecture SomeRandomName of UART_top is

signal baud_clk, tx_busy : std_logic := '0';

constant BAUD_DIV : unsigned (15 downto 0) := to_unsigned((CLK_IN_MHZ * 1000000) / BAUD_RATE, 16); --large enough for baud down to 9600

begin

baud_clk_proc : process (clk) is
	variable div : unsigned (15 downto 0) := (others => '0');
begin
	if rising_edge(clk) then
		if div = BAUD_DIV / 2 then
			div := (others => '0');
			baud_clk <= not baud_clk;
		else
			div := div + 1;
		end if;
	end if;
end process;

rx : entity work.UART_Rx
	port map(
		clk => baud_clk,
		rx_in => rx_in,
		rx_ready => rx_ready,
		rx_data => rx_data
	);

tx : entity work.UART_Tx
	port map(
		clk => baud_clk,
		go => tx_send,
		tx_data => tx_data,
		busy => tx_busy,
		tx_out => tx_out
	);
			
tx_ready <= not tx_busy;

end SomeRandomName;
