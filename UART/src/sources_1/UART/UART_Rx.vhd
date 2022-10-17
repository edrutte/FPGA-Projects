library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Rx is
	Port (
		clk      : in  std_logic;
		baud_en  : in  std_logic;
		rx_in    : in  std_logic;
		rx_ready : out std_logic;
		rx_data  : out std_logic_vector (7 downto 0)
	);
end UART_Rx;

architecture SomeRandomName of UART_Rx is

type state_type is (hold, start_bit, recieve, end_bit);
signal state, next_state : state_type := Hold;

signal rx_data_buf : std_logic_vector (7 downto 0) := (others => '0');
signal rx_data_sr : std_logic_vector (7 downto 0) := (others => '0');

signal bit_count : unsigned (3 downto 0) := (others => '0');

begin

sync_proc : process (clk) is begin
	if rising_edge(clk) and baud_en = '1' then
		state <= next_state;
	end if;
end process;

bit_count_proc : process (clk) is begin
	if rising_edge(clk) and baud_en = '1'then
		if next_state = recieve then
			bit_count <= bit_count + 1;
		else
			bit_count <= (others => '0');
		end if;
	end if;
end process;

rx_data_proc : process (next_state, rx_data_sr, rx_data_buf) is begin
	if next_state = end_bit then
		rx_data <= rx_data_sr;
	else
		rx_data <= rx_data_buf;
	end if;
end process;

rx_data_buf_proc : process (clk) is begin
	if rising_edge(clk) and baud_en = '1' then
		if next_state = end_bit then
			rx_data_buf <= rx_data_sr;
		else
			rx_data_buf <= rx_data_buf;
		end if;
	end if;
end process;

rx_data_sr_proc : process (clk) is begin
	if rising_edge(clk) and baud_en = '1' then
		if next_state = start_bit then
			rx_data_sr <= "00000000";
		elsif next_state = Recieve then
			rx_data_sr <= rx_in & rx_data_sr (7 downto 1);
		else
			rx_data_sr <= rx_data_sr;
		end if;
	end if;
end process;

next_state_proc : process (state, rx_in, bit_count) is begin
	case state is
		when hold =>
			if rx_in = '0' then
				next_state <= start_bit;
			else
				next_state <= hold;
			end if;
		when start_bit => next_state <= recieve;
		when recieve =>
			if bit_count = "1000" and rx_in = '1' then
				next_state <= end_bit;
			elsif bit_count = "1000" and rx_in = '0' then
				next_state <= hold;
			else
				next_state <= recieve;
			end if;
		when end_bit => next_state <= hold;
	end case;
end process;

rx_ready_proc : process (next_state) is begin
	if next_state = end_bit then
		rx_ready <= '1';
	else
		rx_ready <= '0';
	end if;
end process;

end SomeRandomName;
