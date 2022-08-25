----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2021 09:26:20 AM
-- Design Name: 
-- Module Name: debounce - oh_behave
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

--from Cliver
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           button_in : in STD_LOGIC;
           button_out_p : out STD_LOGIC);
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
