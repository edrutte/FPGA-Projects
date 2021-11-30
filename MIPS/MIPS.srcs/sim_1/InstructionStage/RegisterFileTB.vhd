-------------------------------------------------
--  File:          RegisterFileTB.vhd
--
--  Entity:        RegisterFileTB
--  Architecture:  testbench
--  Author:        Jason Blocklove
--  Created:       09/03/19
--  Modified:	   2/22/2021 By Evan Ruttenberg
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                 testbench for the complete
--                 register file
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.globals.all;

entity RegisterFileTB is
end RegisterFileTB;

architecture tb of RegisterFileTB is

type test_vector is record
	we : std_logic;
	Addr1 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	Addr2 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	Addr3 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	wd : std_logic_vector(BIT_DEPTH-1 downto 0);
	RD1 : std_logic_vector(BIT_DEPTH-1 downto 0);
	RD2 : std_logic_vector(BIT_DEPTH-1 downto 0);
end record;

--TODO INCREASE TO 10 AND ADD ADDITIONAL CASES
constant num_tests : integer := 10;
type test_array is array (0 to num_tests-1) of test_vector;

constant test_vector_array : test_array := (
	(we => '0', Addr1 => "000", Addr2 => "000", Addr3 => "001", wd => x"10", RD1 => x"00", RD2 => x"00"),
	(we => '1', Addr1 => "000", Addr2 => "000", Addr3 => "001", wd => x"10", RD1 => x"00", RD2 => x"00"),
	(we => '1', Addr1 => "001", Addr2 => "000", Addr3 => "010", wd => x"ff", RD1 => x"10", RD2 => x"00"),
	(we => '1', Addr1 => "000", Addr2 => "010", Addr3 => "100", wd => x"af", RD1 => x"00", RD2 => x"ff"),
	(we => '1', Addr1 => "001", Addr2 => "100", Addr3 => "011", wd => x"ba", RD1 => x"10", RD2 => x"af"),
	(we => '0', Addr1 => "011", Addr2 => "010", Addr3 => "001", wd => x"10", RD1 => x"ba", RD2 => x"ff"),
	(we => '1', Addr1 => "000", Addr2 => "011", Addr3 => "101", wd => x"cd", RD1 => x"00", RD2 => x"ba"),
	(we => '0', Addr1 => "101", Addr2 => "011", Addr3 => "001", wd => x"10", RD1 => x"cd", RD2 => x"ba"),
	(we => '1', Addr1 => "100", Addr2 => "001", Addr3 => "110", wd => x"42", RD1 => x"af", RD2 => x"10"),
	(we => '0', Addr1 => "110", Addr2 => "100", Addr3 => "001", wd => x"10", RD1 => x"42", RD2 => x"af"));

component RegisterFile is

	PORT (
	------------ INPUTS ---------------
		clk_n	: in std_logic;
		we		: in std_logic;
		Addr1	: in std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 1
		Addr2	: in std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 2
		Addr3	: in std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --write address
		wd		: in std_logic_vector(BIT_DEPTH-1 downto 0); --write data, din

	------------- OUTPUTS -------------
		RD1		: out std_logic_vector(BIT_DEPTH-1 downto 0); --Read from Addr1
		RD2		: out std_logic_vector(BIT_DEPTH-1 downto 0) --Read from Addr2
	);
end component;

signal clk_n	: std_logic;
signal we		: std_logic;
signal Addr1	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 1
signal Addr2	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 2
signal Addr3	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --write address
signal wd		: std_logic_vector(BIT_DEPTH-1 downto 0); --write data, din
signal RD1		: std_logic_vector(BIT_DEPTH-1 downto 0); --Read from Addr1
signal RD2		: std_logic_vector(BIT_DEPTH-1 downto 0); --Read from Addr2
constant clk_delay : time := 50 ns;
begin

UUT : RegisterFile

	port map (
	------------ INPUTS ---------------
		clk_n	 => clk_n,
		we		 => we,
		Addr1	 => Addr1,
		Addr2	 => Addr2,
		Addr3	 => Addr3,
		wd		 => wd,
	------------- OUTPUTS -------------
		RD1		 => RD1,
		RD2		 => RD2
	);


clk_proc:process
begin
	clk_n <= '1';
	wait for clk_delay;
	clk_n <= '0';
	wait for clk_delay;
end process;

stim_proc:process
begin
	for i in 0 to num_tests-1 loop
		we <= test_vector_array(i).we;
		Addr1 <= test_vector_array(i).Addr1;
		Addr2 <= test_vector_array(i).Addr2;
		Addr3 <= test_vector_array(i).Addr3;
		wd <= test_vector_array(i).wd;
		wait for 2 * clk_delay;
		assert (RD1 = test_vector_array(i).RD1) and (RD2 = test_vector_array(i).RD2)
			report "incorrect data read at " & time'image(now) severity error;
	end loop;

	-- Stop testbench once done testing
	--assert false
		--report "Testbench Concluded"
		--severity failure;

end process;

end tb;
