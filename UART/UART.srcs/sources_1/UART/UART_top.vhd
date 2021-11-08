----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2021 09:58:17 AM
-- Design Name: 
-- Module Name: UART_top - SomeRandomName
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_top is
    Port ( 
    	   clk : in std_logic;
    	   tx_data : in std_logic_vector (7 downto 0);
    	   tx_send : in std_logic;
           rx_in : in STD_LOGIC;
           rx_data : out std_logic_vector (7 downto 0);
           tx_ready : out std_logic;
           rx_ready : out std_logic;
           tx_out : out STD_LOGIC
           );
end UART_top;

architecture SomeRandomName of UART_top is

signal baud_clk, tx_busy : std_logic := '0';

constant CLK_IN : Integer := 50000000;
constant BAUD_RATE : Integer := 115200;
constant BAUD_DIV : unsigned (15 downto 0) := to_unsigned(CLK_IN / BAUD_RATE, 16); --large enough for baud down to 9600

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
