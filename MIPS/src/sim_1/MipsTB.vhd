library ieee;
use ieee.std_logic_1164.all;

--use IEEE.NUMERIC_STD.ALL;

entity MipsTB is
--  Port ( );
end MipsTB;

architecture Behavioral of MipsTB is

signal clk     : std_logic := '0';
signal rst     : std_logic := '1';
signal sw      : std_logic_vector (7 downto 0);
signal an_7seg : std_logic_vector (3 downto 0);
signal ag_seg  : std_logic_vector (6 downto 0);
signal seg_dot : std_logic;

begin
uut : entity work.MIPS
	generic map(SIM => TRUE)
	port map(
		clk     => clk,
		rst     => rst,
		sw      => sw,
		an_7seg => an_7seg,
		ag_seg  => ag_seg,
		seg_dot => seg_dot
	);
	
clk <= not clk after 5 ns;

rst_proc : process is begin
	wait until clk = '0';
	rst <= '0';
	wait;
end process;

sw <= "10010110";

end Behavioral;
