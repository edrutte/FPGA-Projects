library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity MipsTB is
--  Port ( );
end MipsTB;

architecture Behavioral of MipsTB is

signal  clk : std_logic;
signal rst : std_logic;
signal sw : std_logic_vector (7 downto 0);
--ALUResult : out std_logic_vector (31 downto 0);
signal an_7seg : std_logic_vector (3 downto 0);
signal ag_seg : std_logic_vector (6 downto 0);
signal seg_dot : std_logic;

begin
uut : entity work.MIPS
	port map(
		clk     => clk,
		rst     => rst,
		sw      => sw,
		--led     => led
		an_7seg => an_7seg,
		ag_seg  => ag_seg,
		seg_dot =>seg_dot
	);
clk_proc : process is begin
	clk <= '0';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
end process;

rst_proc : process is begin
	--rst <= '0';
	--wait until clk = '0';
	rst <= '1';
	wait until clk = '0';
	rst <= '0';
	wait;
end process;

sw <= "10010110";

end Behavioral;
