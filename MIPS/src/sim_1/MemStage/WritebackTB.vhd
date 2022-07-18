library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

--use IEEE.NUMERIC_STD.ALL;

entity WritebackTB is
--  Port ( );
end WritebackTB;

architecture Behavioral of WritebackTB is

signal MemtoReg : std_logic;
signal ALUResult, ReadData : std_logic_vector (BIT_DEPTH - 1 downto 0);
signal Result   : std_logic_vector (BIT_DEPTH - 1 downto 0);


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
                MemtoReg => MemtoReg,
                ALUResult => ALUResult,
                ReadData => ReadData,
                Result => Result
            );

stim_proc : process is begin
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
    assert false 
    	report "End of testbench"
    	severity failure;
end process;

end Behavioral;
