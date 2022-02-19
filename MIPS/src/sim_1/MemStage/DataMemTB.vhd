library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.globals.all;

--use IEEE.NUMERIC_STD.ALL;

entity DataMemTB is
--  Port ( );
end DataMemTB;

architecture Behavioral of DataMemTB is

signal clk, w_en : std_logic := '0';
signal addr : std_logic_vector (DATA_ADDR_BITS - 1 downto 0);
signal d_in : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal d_out : std_logic_vector (BIT_DEPTH - 1 downto 0);

function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;
begin

data_mem : entity work.DataMem
    port map(
                clk => clk,
                w_en => w_en,
                addr => addr,
                d_in => d_in,
                d_out => d_out,
                switches => "01010101"
            );

clk_proc : process is begin
    clk <= not clk;
    wait for 50 ns;
end process;

stim_proc : process is begin
    wait until clk = '0';
    w_en <= '1';
    addr <= "0000011011";
    d_in <= x"AAAA5555";
    wait until clk = '0';
    addr <= "0000011100";
    d_in <= x"5555AAAA";
    wait until clk = '0';
    w_en <= '0';
    addr <= "0000011011";
    wait until clk = '1';
    assert d_out = x"AAAA5555"
        report "wrong data " & to_string(d_out) & "expected 0xAAAA5555"
        severity error;
    wait until clk = '0';
    addr <= "0000011100";
    wait until clk = '1';
    assert d_out = x"5555AAAA"
        report "wrong data " & to_string(d_out) & "expected 0x5555AAAA"
        severity error;
    wait until clk = '0';
    w_en <= '1';
    addr <= "0001010111";
    d_in <= x"FAADE210";
    wait until clk = '0';
    addr <= "1011000100";
    d_in <= x"46290EED";
    wait until clk = '0';
    w_en <= '0';
    addr <= "0001010111";
    wait until clk = '1';
    assert d_out = x"FAADE210"
        report "wrong data " & to_string(d_out) & "expected 0xFAADE210"
        severity error;
    wait until clk = '0';
    addr <= "1011000100";
    wait until clk = '1';
    assert d_out = x"46290EED"
        report "wrong data " & to_string(d_out) & "expected 0x46290EED"
        severity error;
    wait until clk = '0';
    w_en <= '1';
    addr <= "1101010011";
    d_in <= x"ADAECC43";
    wait until clk = '0';
    addr <= "0101110010";
    d_in <= x"CDC38F29";
    wait until clk = '0';
    w_en <= '0';
    addr <= "1101010011";
    wait until clk = '1';
    assert d_out = x"ADAECC43"
        report "wrong data " & to_string(d_out) & "expected 0xADAECC43"
        severity error;
    wait until clk = '0';
    addr <= "0101110010";
    wait until clk = '1';
    assert d_out = x"CDC38F29"
        report "wrong data " & to_string(d_out) & "expected 0xCDC38F29"
        severity error;
    assert false report "testing finished" severity failure;
end process;
end Behavioral;
