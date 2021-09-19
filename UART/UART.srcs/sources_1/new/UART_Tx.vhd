----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2021 09:58:17 AM
-- Design Name: 
-- Module Name: UART_Tx - SomeRandomName
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

entity UART_Tx is
    Port ( 
    	   clk : in std_logic;
    	   go : in std_logic;
           tx_data : in STD_LOGIC_VECTOR (7 downto 0);
           busy : out std_logic;
           tx_out : out STD_LOGIC
         );
end UART_Tx;

architecture SomeRandomName of UART_Tx is

type state_type is (Hold, Init, Send, DeInit);
signal state, next_state : state_type := Hold;

signal bit_count : unsigned (3 downto 0) := (others => '0');

signal tx_data_buf : std_logic_vector (7 downto 0) := (others => '0');

begin

sync_proc : process (clk) is begin
	if rising_edge(clk) then
		state <= next_state;
	end if;
end process;

next_state_proc : process (state, bit_count, go) is begin
	case state is
		when Hold =>
			if go = '1' then
				next_state <= Init;
			else
				next_state <= Hold;
			end if;
		when Init => next_state <= Send;
		when Send =>
			if bit_count = "0111" then
				next_state <= DeInit;
			else
				next_state <= Send;
			end if;
		when DeInit => next_state <= Hold;
	end case;
end process;

bit_count_proc : process (clk) is begin
	if rising_edge(clk) then
		if state = Send then
			bit_count <= bit_count + 1;
		else
			bit_count <= (others => '0');
		end if;
	end if;
end process;

tx_data_buf_proc : process (clk) is begin
	if rising_edge(clk) then
		if state = Init then
			tx_data_buf <= tx_data;
		else
			tx_data_buf <= '0' & tx_data_buf (7 downto 1);
		end if;
	end if;
end process;

busy_proc : process (state) is begin
	if state = Hold then
		busy <= '0';
	else
		busy <= '1';
	end if;
end process;

tx_out_proc : process (state, tx_data_buf) is begin
	--if rising_edge(clk) then
		if state = Init then
			tx_out <= '0';
		elsif state = Send then
			tx_out <= tx_data_buf(0);
		else
			tx_out <= '1';
		end if;
	--end if;
end process;
			
end SomeRandomName;
