----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2021 05:23:44 AM
-- Design Name: 
-- Module Name: scroller - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scroller is
	generic (bignum_size : INTEGER);
    Port ( clk : in STD_LOGIC;
    	   en : in std_logic;
           bignum : in STD_LOGIC_VECTOR (bignum_size - 1 downto 0);
           aa : out STD_LOGIC_VECTOR (3 downto 0);
           led_out : out STD_LOGIC_VECTOR (6 downto 0));
end scroller;

architecture Behavioral of scroller is
signal d_num : std_logic_vector (15 downto 0);
signal halfSecClk : std_logic := '0';
begin

clockdiv_proc : process (clk) is
	variable count : INTEGER := 0;
begin
	if rising_edge(clk) then
		if count = 25000000 then
			halfSecClk <= not halfSecClk;
			count := 0;
		else
			count := count + 1;
		end if;
	end if;
end process;

scroll_proc : process (halfSecClk, en) is
	variable i : INTEGER := bignum_size + 19;
begin
	if rising_edge(halfSecClk) then
	if en = '1' then
		if i <= bignum_size - 1 then
			d_num <= bignum (i downto i - 15);
		end if;
		if i = 15 then
			i := bignum_size + 19;
		else
			i := i - 4;
		end if;
		end if;
	end if;
end process;			

--with bignum select d_num <=
--	x"1111" when x"248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1",
--	x"0000" when others;

lseg7 : entity work.seg7
	port map(
		clock_50MHz => clk,
		displayed_number => d_num,
		Anode_Activate => aa,
		LED_out => led_out
	);

end Behavioral;
