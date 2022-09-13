library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_package.all;
use work.img_package.all;

entity vga_tb is
end vga_tb;

architecture tb of vga_tb is
  signal hsync, vsync, clk, hold_frame : std_logic := '1';
  signal red, grn : std_logic_vector(2 downto 0);
  signal blu : std_logic_vector(1 downto 0);
  signal frame : frame_type := rainbow_img;
begin
  clk <= not clk after 19.841 ns; --25.2MHz at picosecond resolution
  
  uut : entity work.vga
  	generic map(
  		SIM => true
  		)
  	port map(
  		clk => clk,
  		frame => frame,
  		hold_frame => hold_frame,
  		hsync => hsync,
  		vsync => vsync,
  		red => red,
  		grn => grn,
  		blu => blu
  	);
  	
  hsync_check_proc : process(hsync) is begin
  	if rising_edge(hsync) then
  		assert abs(hsync'delayed(0ns)'last_event - 3.811us) < 19ns
  			report "hsync pulse time was " & time'image(hsync'delayed(0ns)'last_event) & " but should be within " & time'image(19ns) & " (0.5%) of " & time'image(3.811us)
  			severity error;
  	end if;
  	if falling_edge(hsync) then
  		assert abs(hsync'delayed(0ns)'last_event - 27.949us) < 140ns
  			report "time between hsync pulses was " & time'image(hsync'delayed(0ns)'last_event) & " but should be within " & time'image(140ns) & " (0.5%) of " & time'image(27.949us)
			severity error;
	end if;
  end process;
  
  vsync_check_proc : process(vsync) is begin
  	if rising_edge(vsync) then
  		assert abs(vsync'delayed(0ns)'last_event - 63.52us) < 318ns
  			report "vsync pulse time was " & time'image(vsync'delayed(0ns)'last_event) & " but should be within " & time'image(318ns) & " (0.5%) of " & time'image(63.52us)
  			severity error;
  	end if;
  	if falling_edge(vsync) and now > 0ns then
  		assert abs(vsync'delayed(0ns)'last_event - 16.61048ms) < 83us
  			report "time between vsync pulses was " & time'image(vsync'delayed(0ns)'last_event) & " but should be within " & time'image(83us) & " (0.5%) of " & time'image(16.61048ms)
  			severity error;
  	end if;
  end process;
end;
