----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2021 09:58:17 AM
-- Design Name: 
-- Module Name: UART_Rx - SomeRandomName
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

entity UART_Rx is
    Port ( 
    	   clk : in std_logic;
    	   rx_in : in STD_LOGIC;
    	   rx_ready : out std_logic;
           rx_data : out STD_LOGIC_VECTOR (7 downto 0));
end UART_Rx;

architecture SomeRandomName of UART_Rx is

type state_type is (Hold, Got_start, Recieve, Got_end);
signal state, next_state : state_type := Hold;

signal rx_data_buf : std_logic_vector (7 downto 0) := (others => '0');
signal rx_data_sr : std_logic_vector (7 downto 0) := (others => '0');

signal bit_count : unsigned (3 downto 0) := (others => '0');

begin

sync_proc : process (clk) is begin
	if rising_edge(clk) then
		state <= next_state;
	end if;
end process;

bit_count_proc : process (clk) is begin
	if rising_edge(clk) then
		if next_state = Recieve then
			bit_count <= bit_count + 1;
		else
			bit_count <= (others => '0');
		end if;
	end if;
end process;

rx_data_proc : process (next_state, rx_data_sr, rx_data_buf) is begin
	--if rising_edge(clk) then
		if next_state = Got_end then
			rx_data <= rx_data_sr;
		else
			rx_data <= rx_data_buf;
		end if;
	--end if;
end process;

rx_data_buf_proc : process (clk) is begin
	if rising_edge(clk) then
		if next_state = Got_end then
			rx_data_buf <= rx_data_sr;
		else
			rx_data_buf <= rx_data_buf;
		end if;
	end if;
end process;

rx_data_sr_proc : process (clk) is begin
	if rising_edge(clk) then
		if next_state = Got_start then
			rx_data_sr <= "00000000";
		elsif next_state = Recieve then
			rx_data_sr <= rx_in & rx_data_sr (7 downto 1);
		else
			rx_data_sr <= rx_data;
		end if;
	end if;
end process;

next_state_proc : process (state, rx_in, bit_count) is begin
	case state is
		when Hold =>
			if rx_in = '0' then
				next_state <= Got_start;
			else
				next_state <= Hold;
			end if;
		when Got_start => next_state <= Recieve;
		when Recieve =>
			if bit_count = "1000" and rx_in = '1' then
				next_state <= Got_end;
			elsif bit_count = "1000" and rx_in = '0' then
				next_state <= Hold;
			else
				next_state <= Recieve;
			end if;
		when Got_end => next_state <= Hold;
	end case;
end process;

rx_ready_proc : process (next_state) is begin
	if next_state = Got_end then
		rx_ready <= '1';
	else
		rx_ready <= '0';
	end if;
end process;

end SomeRandomName;
