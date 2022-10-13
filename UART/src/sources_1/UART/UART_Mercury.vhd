library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Mercury is
  Port ( 
  		clk     : in  std_logic;
  		rx_in   : in  std_logic;
  		btn     : in  std_logic;
  		sw      : in  std_logic_vector (7 downto 0);
  		an_7seg : out std_logic_vector (3 downto 0);
        ag_seg  : out std_logic_vector (6 downto 0);
        --seg_dot : out std_logic;
        tx_out  : out std_logic;
  		);
end UART_Mercury;

architecture SomeRandomName of UART_Mercury is

signal tx_send, tx_ready, rx_ready : std_logic;
signal tx_data, rx_data : std_logic_vector (7 downto 0);
signal rx_data_led : std_logic_vector (15 downto 0);

component seg7 is
    port(
            Clock_50MHz : in std_logic;
            displayed_number : in std_logic_vector (15 downto 0);
            Anode_Activate : out std_logic_vector (3 downto 0);
            LED_out : out std_logic_vector (6 downto 0)
        );
end component;

begin

UART : entity work.UART_top
	port map(
				clk => clk,
				tx_data => tx_data,
				tx_send => btn,--tx_send,
				rx_in => rx_in,
				rx_data => rx_data,
				tx_ready => tx_ready,
				rx_ready => rx_ready,
				tx_out => tx_out
			);

--no_bounce : entity work.debounce
--	port map(
--				clk => clk,
--				rst => '0',
--				button_in => btn,
--				button_out_p => tx_send
--			);

sev_seg : seg7
    port map(
                clock_50MHz => clk,
                displayed_number => rx_data_led,
                Anode_Activate => an_7seg,
                LED_out => ag_seg
            );

tx_data <= sw;
rx_data_led <= std_logic_vector(to_unsigned(to_integer(unsigned(rx_data)), 16));

end SomeRandomName;
