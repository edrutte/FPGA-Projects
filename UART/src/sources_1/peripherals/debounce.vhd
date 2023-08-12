--from Cliver
library ieee;
use ieee.std_logic_1164.all;

entity debounce is
	Port (
		clk          : in  std_logic;
		rst          : in  std_logic;
		button_in    : in  std_logic;
		button_out_p : out std_logic
	);
end debounce;

architecture oh_behave of debounce is

signal button_in_sr : std_logic_vector (4 downto 0) := (others=> '0');

begin

shift_reg_proc : process (clk, rst) is begin
    if rst = '1' then
        button_in_sr <= (others => '0');
    elsif rising_edge(clk) then
        button_in_sr <= button_in_sr (3 downto 0) & button_in;
    end if;
end process;

button_out_p <= (not button_in_sr(4)) and button_in_sr(3) and button_in_sr(2) and button_in_sr(1);
end oh_behave;
