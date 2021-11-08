----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2021 11:39:36 AM
-- Design Name: 
-- Module Name: UART_tb - tb
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

entity UART_tb is
--  Port ( );
end UART_tb;

architecture tb of UART_tb is

signal clk, baud_clk, rx_in, tx_out, tx_send, tx_ready, rx_ready : std_logic := '0';
signal tx_data, rx_data : std_logic_vector (7 downto 0);

constant CLK_IN : Integer := 50000000;
constant BAUD_RATE : Integer := 115200;
constant BAUD_DIV : unsigned (15 downto 0) := to_unsigned(CLK_IN / BAUD_RATE, 16); --large enough for baud down to 9600

constant num_tests : integer := 10;
type test_array is array (0 to num_tests-1) of std_logic_vector (7 downto 0);

constant test_vector_array : test_array := (
	x"69",
	x"14",
	x"EF",
	x"1F",
	x"C7",
	x"23",
	x"74",
	x"94",
	x"F5",
	x"D7",
	others => (others => '0')
											);

begin

UART : entity work.UART_top
	port map(
				clk => clk,
				tx_data => tx_data,
				tx_send => tx_send,
				rx_in => rx_in,
				rx_data => rx_data,
				tx_ready => tx_ready,
				rx_ready => rx_ready,
				tx_out => tx_out
			);

clk_proc : process is begin
	wait for 20 ns;
	clk <= not clk;
end process;

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

stim_proc : process is begin
	
	for i in 0 to num_tests - 1 loop
		wait until baud_clk = '0';
		tx_data <= test_vector_array(i);
		tx_send <= '1';
		wait until baud_clk = '0';
		tx_send <= '0';
		--wait until baud_clk = '0';
		wait until tx_ready = '1';
	end loop;
	
end process;

assert_proc : process is begin
	for i in 0 to num_tests - 1 loop
		wait until baud_clk = '0';
		if i = 0 then
			wait until baud_clk = '0';
		end if;
		assert tx_out = '0'
			report "Failed to find start bit"
			severity error;
		assert tx_ready = '0'
			report "tx shouldn't be ready"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(0)
			report "Failed bit 1"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(1)
			report "Failed bit 2"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(2)
			report "Failed bit 3"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(3)
			report "Failed bit 4"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(4)
			report "Failed bit 5"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(5)
			report "Failed bit 6"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(6)
			report "Failed bit 7"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = test_vector_array(i)(7)
			report "Failed bit 8"
			severity error;
		wait until baud_clk = '0';
		assert tx_out = '1'
			report "Failed to find stop bit"
			severity error;
		assert rx_ready = '1'
			report "rx should be ready"      --rx_ready when stop bit recieved because all data recieved
			severity error;
		assert rx_data = test_vector_array(i)
			report "rx_error"
			severity error;
		wait until baud_clk = '0';
		assert rx_data = test_vector_array(i)
			report "rx should not change"
			severity error;
		assert rx_ready = '0'
			report "rx shouldn't be ready"
			severity error;
		assert tx_ready = '1'
			report "tx should be ready"      --tx ready not until after stop bit fully sent because thats when new data can be sent
			severity error;
		--wait until baud_clk = '0';
	end loop;
	assert false
		report "end"
		severity failure;
end process;
rx_in <= tx_out;

end tb;
