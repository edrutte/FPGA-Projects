library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.globals.all;

--use IEEE.NUMERIC_STD.ALL;

entity WritebackTB is
--  Port ( );
end WritebackTB;

architecture Behavioral of WritebackTB is

signal WriteReg : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
signal RegWrite, MemtoReg : std_logic;
signal ALUResult, ReadData : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal Result : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal WriteRegOut : std_logic_vector (LOG_PORT_DEPTH - 1 downto 0);
signal RegWriteOut : std_logic;

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

wb : entity work.Writeback
    port map(
                WriteReg => WriteReg,
                RegWrite => RegWrite,
                MemtoReg => MemtoReg,
                ALUResult => ALUResult,
                ReadData => ReadData,
                Result => Result,
                WriteRegOut => WriteRegOut,
                RegWriteOut => RegWriteOut
            );

stim_proc : process is begin
    WriteReg <= "00000";
    wait for 50 ns;
    assert WriteRegOut = "00000"
        report "WriteRegOut failure: Expected 00000 got " & to_string(WriteRegOut)
        severity error;
    WriteReg <= "11111";
    wait for 50 ns;
    assert WriteRegOut = "11111"
        report "WriteRegOut failure: Expected 11111 got " & to_string(WriteRegOut)
        severity error;
    RegWrite <= '0';
    wait for 50 ns;
    assert RegWrite = '0'
        report "RegWrite failure expected 0 got " & std_logic'image(RegWrite)
        severity error;
    RegWrite <= '1';
    wait for 50 ns;
    assert RegWrite = '1'
        report "RegWrite failure expected 1 got " & std_logic'image(RegWrite)
        severity error;
    MemtoReg <= '0';
    ALUResult <= x"00000000";
    ReadData <= x"FFFFFFFF";
    wait for 50 ns;
    assert Result = x"00000000"
        report "Wrong data source"
        severity error;
    MemtoReg <= '1';
    wait for 50 ns;
    assert Result = x"FFFFFFFF"
        report "Wrong data source"
        severity error;
    MemtoReg <= '0';
    ALUResult <= x"55555555";
    ReadData <= x"AAAAAAAA";
    wait for 50 ns;
    assert Result = x"55555555"
        report "Wrong data source"
        severity error;
    MemtoReg <= '1';
    wait for 50 ns;
    assert Result = x"AAAAAAAA"
        report "Wrong data source"
        severity error;
    assert false severity failure;
end process;

end Behavioral;
