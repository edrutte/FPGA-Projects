library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

--use ieee.numeric_std.all;

entity Multiplier is
	Port ( 
		A       : in  std_logic_vector ( ( BIT_DEPTH / 2 ) - 1 downto 0 );
		B       : in  std_logic_vector ( ( BIT_DEPTH / 2 ) - 1 downto 0 );
		Product : out std_logic_vector ( BIT_DEPTH - 1 downto 0 )
	);
end Multiplier;

architecture SomeRandomName of Multiplier is

type array_type is array(BIT_DEPTH - 1 downto 0) of std_logic_vector (BIT_DEPTH - 1 downto 0);

signal and_array   : array_type := (others => (others => '0'));
signal add_array   : array_type := (others => (others => '0'));
signal carry_array : array_type := (others => (others => '0'));

begin
	rows: for row in 0 to (BIT_DEPTH / 2) - 1 generate
		cols: for col in 0 to BIT_DEPTH - 1 generate
			and_gates: if col < (BIT_DEPTH / 2) generate
				and_array(row)(col) <=
					A(row) AND B(col);
			end generate and_gates;
			row_1_col_1: if row = 1 AND col = 1 generate
				adder_1: entity work.FullAdder
					port map (A => and_array(1)(0), B => and_array(0)(1), Cin => '0', Cout => carry_array(row)(col), Sum => add_array(row)(col));	
			 end generate row_1_col_1;
			 row_1_col_n: if row = 1 AND col > 1 AND col < (BIT_DEPTH / 2) generate
				adder_row_1_col_n: entity work.FullAdder
					port map (A => and_array(col)(0), B => and_array(col - row)(row), Cin => carry_array(row)(col - 1), Cout => carry_array(row)(col), Sum => add_array(row)(col));
			 end generate row_1_col_n;
			 row_1_col_last: if row = 1 AND col = (BIT_DEPTH / 2) generate
				adder_row_1_col_last: entity work.FullAdder
					port map (A => '0', B => and_array(col - row)(row), Cin => carry_array(row)(col - 1), Cout => carry_array(row)(col), Sum => add_array(row)(col));
			 end generate row_1_col_last;
			 row_n_col_1: if row > 1 AND row = col generate
				adder_row_n_col_1: entity work.FullAdder
					port map (A => add_array(row - 1)(col), B => and_array(col - row)(row), Cin => '0', Cout => carry_array(row)(col), Sum => add_array(row)(col));
			 end generate row_n_col_1;
			 row_n_col_n: if row > 1 AND col > row  AND col < (((BIT_DEPTH / 2) + row) - 1) generate
				adder_row_n_col_n: entity work.FullAdder
					port map (A => add_array(row - 1)(col), B => and_array(col - row)(row), Cin => carry_array(row)(col - 1), Cout => carry_array(row)(col), Sum => add_array(row)(col));
			 end generate row_n_col_n;
			 row_n_col_last: if row > 1 AND col = (((BIT_DEPTH / 2) + row) - 1) generate
				adder_row_n_col_last: entity work.FullAdder
					port map (A => carry_array(row - 1)(col - 1), B => and_array(col - row)(row), Cin => carry_array(row)(col - 1), Cout => carry_array(row)(col), Sum => add_array(row)(col));
			 end generate row_n_col_last;
		end generate cols;
	end generate rows;
	
	Product_proc: process (all) is begin
		for i in 0 to BIT_DEPTH - 1 loop
			if i = 0 then
				Product(i) <= and_array(0)(0);
			elsif i = BIT_DEPTH - 1 then
				Product(i) <= carry_array((BIT_DEPTH / 2) - 1)(BIT_DEPTH - 2);
			elsif i < (BIT_DEPTH / 2) - 1 then
				Product(i) <= add_array(i)(i);
			else
				Product(i) <= add_array((BIT_DEPTH / 2) - 1)(i);
			end if;
		end loop;
	end process;
end SomeRandomName;
