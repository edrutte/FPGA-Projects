----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/27/2021 12:00:38 PM
-- Design Name: 
-- Module Name: hash_tb - Behavioral
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

entity hash_tb is
--  Port ( );
end hash_tb;

architecture Behavioral of hash_tb is


--signal hash : std_logic_vector (255 downto 0);
signal clk : std_logic := '0';
signal done : std_logic := '0';
--signal hashrev : std_logic_vector (255 downto 0);
--signal hashret : std_logic_vector (255 downto 0);
--signal hashret2 : std_logic_vector (255 downto 0);
--signal inrev : std_logic_vector (511 downto 0);
--signal ini : std_logic_vector (511 downto 0);
--signal ini1 : std_logic_vector (255 downto 0);
--signal ini2 : std_logic_vector (255 downto 0);
begin

clk <= not clk after 50 ns;
--hash <= x"6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19";
--hashrev <= hash(31 downto 0) & hash(63 downto 32) & hash(95 downto 64) & hash(127 downto 96) & hash(159 downto 128) & hash(191 downto 160) & hash(223 downto 192) & hash(255 downto 224);

--ash: entity work.sha256chunk
--	port map (
--		ap_clk => clk,
--		ap_rst => '0',
--		ap_start => '1',
--		LastHash => hashrev,
--		D => x"00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626380",
--		ap_return => hashret
--		);

--ash: entity work.sha256chunk                                                                                                               
--	port map (                                                                                                                                
--		ap_clk => clk,                                                                                                                           
--		ap_rst => '0',                                                                                                                           
--		ap_start => '1',                                                                                                                         
--		LastHash => hashrev,                                                                                                                     
--		D => x"00000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000726c64806f20776f68656c6c",
--		ap_return => hashret                                                                                                                     
--		);                                                                                                                                       

ash : entity work.sha256chunk_top
	port map (
	ap_clk => clk,
	ap_rst => '0',
	start => '1',
	ap_done => done
	);
	
done_proc : process (clk) is begin
    if rising_edge(clk) then
        assert done = '0' report "Hashing Finished";
    end if;
end process;
end Behavioral;
