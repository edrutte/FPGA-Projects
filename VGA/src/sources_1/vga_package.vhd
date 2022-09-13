library ieee;
use ieee.std_logic_1164.all;

package vga_package is
  type pixel_type is record
  	red : std_logic_vector(2 downto 0); 
  	grn : std_logic_vector(2 downto 0);
  	blu : std_logic_vector(1 downto 0);
  end record pixel_type;
  type line_type is array(0 to 639) of pixel_type;
  type frame_type is array(0 to 479) of line_type;
end package vga_package;
