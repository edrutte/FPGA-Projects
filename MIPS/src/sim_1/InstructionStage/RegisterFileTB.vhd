-------------------------------------------------
--  File:          RegisterFileTB.vhd
--
--  Entity:        RegisterFileTB
--  Architecture:  testbench
--  Author:        Jason Blocklove
--  Created:       09/03/19
--  Modified:	   7/18/2022 By Evan Ruttenberg
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                 testbench for the complete
--                 register file
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity RegisterFileTB is
end RegisterFileTB;

architecture tb of RegisterFileTB is

type test_vector is record
	we, Link: std_logic;
	Addr1   : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	Addr2   : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	Addr3   : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
	wd      : std_logic_vector(BIT_DEPTH-1 downto 0);
	RD1     : std_logic_vector(BIT_DEPTH-1 downto 0);
	RD2     : std_logic_vector(BIT_DEPTH-1 downto 0);
end record;

constant num_tests : integer := 10;
type test_array is array (0 to num_tests-1) of test_vector;

constant test_vector_array : test_array := (
	(we => '0', Link => '0', Addr1 => 5b"000", Addr2 =>5b"000", Addr3 => 5b"001", wd => 32x"10", RD1 => 32x"00", RD2 => 32x"00"),
	(we => '0', Link => '1', Addr1 => 5b"000", Addr2 =>5b"000", Addr3 => 5b"001", wd => 32x"10", RD1 => 32x"00", RD2 => 32x"00"),
	(we => '1', Link => '0', Addr1 => 5b"001", Addr2 =>5b"000", Addr3 => 5b"010", wd => 32x"ff", RD1 => 32x"10", RD2 => 32x"00"),
	(we => '1', Link => '0', Addr1 => 5b"000", Addr2 =>5b"010", Addr3 => 5b"100", wd => 32x"af", RD1 => 32x"00", RD2 => 32x"ff"),
	(we => '0', Link => '1', Addr1 => 5b"001", Addr2 =>5b"100", Addr3 => 5b"011", wd => 32x"ba", RD1 => 32x"10", RD2 => 32x"af"),
	(we => '0', Link => '0', Addr1 => 5b"011", Addr2 =>5b"010", Addr3 => 5b"001", wd => 32x"10", RD1 => 32x"ba", RD2 => 32x"ff"),
	(we => '1', Link => '0', Addr1 => 5b"000", Addr2 =>5b"011", Addr3 => 5b"101", wd => 32x"cd", RD1 => 32x"00", RD2 => 32x"ba"),
	(we => '0', Link => '0', Addr1 => 5b"101", Addr2 =>5b"011", Addr3 => 5b"001", wd => 32x"10", RD1 => 32x"cd", RD2 => 32x"ba"),
	(we => '0', Link => '1', Addr1 => 5b"100", Addr2 =>5b"001", Addr3 => 5b"110", wd => 32x"42", RD1 => 32x"af", RD2 => 32x"10"),
	(we => '0', Link => '0', Addr1 => 5b"110", Addr2 =>5b"100", Addr3 => 5b"001", wd => 32x"10", RD1 => 32x"42", RD2 => 32x"af"));

component RegisterFile is

	PORT (
	------------ INPUTS ---------------
		clk_n	: in std_logic;
		we		: in std_logic;
		Link    : in std_logic;
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
signal we, Link : std_logic;
signal Addr1	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 1
signal Addr2	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --read address 2
signal Addr3	: std_logic_vector(LOG_PORT_DEPTH-1 downto 0); --write address
signal wd		: std_logic_vector(BIT_DEPTH-1 downto 0); --write data, din
signal RD1		: std_logic_vector(BIT_DEPTH-1 downto 0); --Read from Addr1
signal RD2		: std_logic_vector(BIT_DEPTH-1 downto 0); --Read from Addr2
begin

UUT : RegisterFile

	port map (
	------------ INPUTS ---------------
		clk_n	 => clk_n,
		we		 => we,
		Link 	 => Link,
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
	wait for 50 ns;
	clk_n <= '0';
	wait for 50 ns;
end process;

stim_proc : process is begin
	for i in 0 to num_tests-1 loop
		we <= test_vector_array(i).we;
		Link <= test_vector_array (i).Link;
		Addr1 <= test_vector_array(i).Addr1;
		Addr2 <= test_vector_array(i).Addr2;
		Addr3 <= test_vector_array(i).Addr3;
		wd <= test_vector_array(i).wd;
		wait for 100 ns;
		assert (RD1 = test_vector_array(i).RD1) and (RD2 = test_vector_array(i).RD2)
			report "incorrect data read at " & time'image(now) severity error;
	end loop;

	-- Stop testbench once done testing
	assert false
		report "Testbench Concluded"
		severity failure;

end process;

end tb;
