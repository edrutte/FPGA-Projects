----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/15/2021 03:52:00 PM
-- Design Name: 
-- Module Name: sha256chunk_top - Behavioral
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

entity sha256chunk_top is
	generic (num : INTEGER := 2);
    Port ( ap_clk : in STD_LOGIC;
    	   ap_rst : IN STD_LOGIC;
    	   start : in std_logic;
           ap_done : OUT STD_LOGIC;
           an_7seg : out std_logic_vector (3 downto 0);
           ag_seg : out std_logic_vector (6 downto 0);
           seg_dot : out std_logic
           );
end sha256chunk_top;

architecture Behavioral of sha256chunk_top is
type memtype is array (0 to num - 1) of std_logic_vector (511 downto 0);
signal mem : memtype := (x"6162636462636465636465666465666765666768666768696768696a68696a6b696a6b6c6a6b6c6d6b6c6d6e6c6d6e6f6d6e6f706e6f70718000000000000000", x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0", others => (others => '0'));--x"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018", others => (others => '0'));
type lasttype is array (0 to num - 1) of std_logic_vector (255 downto 0);
signal last : lasttype;
signal lastinitrev : STD_LOGIC_VECTOR (255 downto 0);
signal lastinit : STD_LOGIC_VECTOR (255 downto 0);
signal read : std_logic_vector (0 to num - 1):= (others => '0');
signal hash : STD_LOGIC_VECTOR (255 downto 0);
signal red : std_logic := '0';
begin
lastinit <= x"6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19";
lastinitrev <= lastinit(31 downto 0) & lastinit(63 downto 32) & lastinit(95 downto 64) & lastinit(127 downto 96) & lastinit(159 downto 128) & lastinit(191 downto 160) & lastinit(223 downto 192) & lastinit(255 downto 224);
ap_done <= read(num - 1);
seg_dot <= '1';

shagen : for i in 0 to num - 1 generate
	gen0 : if i = 0 generate
		ashsha0 : entity work.sha256chunk
			port map (
				ap_clk => ap_clk,
				ap_rst => read(num - 1),
				ap_start => start,
				ap_ready => read(i),
				LastHash => lastinitrev,
				D => mem(i)(31 downto 0) & mem(i)(63 downto 32) & mem(i)(95 downto 64) & mem(i)(127 downto 96) & mem(i)(159 downto 128) & mem(i)(191 downto 160) & mem(i)(223 downto 192) & mem(i)(255 downto 224) & mem(i)(287 downto 256) & mem(i)(319 downto 288) & mem(i)(351 downto 320) & mem(i)(383 downto 352) & mem(i)(415 downto 384) & mem(i)(447 downto 416) & mem(i)(479 downto 448) & mem(i)(511 downto 480),
				ap_return => last(i)
			);
	else generate
		ashshai : entity work.sha256chunk
			port map (
				ap_clk => ap_clk,
				ap_rst => read(num - 1),
				ap_start => read(i - i),
				ap_ready => read(i),
				LastHash => last(i - 1),
				D => mem(i)(31 downto 0) & mem(i)(63 downto 32) & mem(i)(95 downto 64) & mem(i)(127 downto 96) & mem(i)(159 downto 128) & mem(i)(191 downto 160) & mem(i)(223 downto 192) & mem(i)(255 downto 224) & mem(i)(286 downto 256) & mem(i)(319 downto 287) & mem(i)(351 downto 320) & mem(i)(383 downto 352) & mem(i)(415 downto 384) & mem(i)(447 downto 416) & mem(i)(479 downto 448) & mem(i)(511 downto 480),
				ap_return => last(i)
			);
	end generate;
end generate;

hash_proc : process (ap_clk) is begin
	if rising_edge(ap_clk) then
		if read(num - 1) = '1' then
			hash <= last(num - 1)(31 downto 0) & last(num - 1)(63 downto 32) & last(num - 1)(95 downto 64) & last(num - 1)(127 downto 96) & last(num - 1)(159 downto 128) & last(num - 1)(191 downto 160) & last(num - 1)(223 downto 192) & last(num - 1)(255 downto 224);
		else
			hash <= hash;
		end if;
	end if;
end process;
red_proc : process (ap_clk) is begin
	if rising_edge(ap_clk) then
		if read(num - 1) = '1' then
			red <= '1';
		end if;
	end if;
end process;

scroll : entity work.scroller
	generic map(
		bignum_size => 256
	)
	port map(
		clk => ap_clk,
		bignum => hash,
		en => red,
		aa => an_7seg,
		led_out => ag_seg
	);

end Behavioral;
