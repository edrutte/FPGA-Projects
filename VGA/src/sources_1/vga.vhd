library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_package.all;

entity vga is
  generic (
	SIM : boolean := false
	);
  port (
    clk        : in  std_logic; --50MHz clock from mercury 2
    frame      : in  frame_type;
    hold_frame : out std_logic;
    hsync      : out std_logic;
    vsync      : out std_logic;
    red        : out std_logic_vector(2 downto 0);
    grn        : out std_logic_vector(2 downto 0);
    blu        : out std_logic_vector(1 downto 0)
    );
end entity vga;

architecture someRandomName of vga is
  signal line_num, line_num_meta, line_num_sysclk : signed(10 downto 0) := to_signed(-33, 11);
  signal pix_num  : signed(10 downto 0) := to_signed(-48, 11);
  signal hsync_tmp, vsync_tmp, pix_clk : std_logic := '1';
  signal frame_tmp : frame_type;
  signal line_tmp : line_type;
  component clk_wiz_0
	port (
		sys_clk : in  std_logic;
		pix_clk : out std_logic
		);
  end component;
  
begin
	gen_pix : if not SIM generate
		pix_clk_gen : clk_wiz_0
			port map (
				sys_clk => clk,
				pix_clk => pix_clk
			);
	else generate
		pix_clk <= clk;
	end generate;

  clk_dom_sync_proc : process(clk) is begin
	if rising_edge(clk) then
		line_num_meta <= line_num;
		line_num_sysclk <= line_num_meta;
	end if;
  end process;

  hold_frame_proc : process(clk) is begin
	if rising_edge(clk) then
		if line_num_sysclk < to_signed(-2, 11) or line_num_sysclk > 11x"1DF" then
			hold_frame <= '0';
		else
			hold_frame <= '1';
		end if;
	end if;
  end process;

  pix_line_num_proc : process(pix_clk) is begin
	if rising_edge(pix_clk) then
		if pix_num = 11x"2EF" then -- 639 line + 16 end + 96 sync + 48 blank starting at -48
			pix_num <= to_signed(-48, 11);
			if line_num = 11x"1EB" then -- 479 frame + 10 end + 2 sync + 33 blank starting at -33
				line_num <= to_signed(-33, 11);
			else
				line_num <= line_num + 1;
			end if;
		else
			pix_num <= pix_num + 1;
		end if;
	end if;
  end process;

  line_tmp_proc : process(line_num, frame_tmp) is begin
	if line_num >= 11x"0" and line_num < 11x"1E0" then
		line_tmp <= frame(to_integer(line_num));
	else
		line_tmp <= frame(0);
	end if;
  end process;
  		
  vsync_proc : process(line_num) is begin
	if line_num > 11x"1E9" then
		vsync_tmp <= '0';
	else
		vsync_tmp <= '1';
	end if;
  end process;
  
  hsync_proc : process(pix_num) is begin
	if pix_num > 11x"28F" then
		hsync_tmp <= '0';
	else
		hsync_tmp <= '1';
	end if;
  end process;

  rgb_proc : process (line_num, pix_num, line_tmp) is begin
	if line_num >= 11x"0" and line_num < 11x"1E0" and pix_num >= 11x"0" and pix_num < 11x"280" then
		red <= line_tmp(to_integer(pix_num)).red;
		grn <= line_tmp(to_integer(pix_num)).grn;
		blu <= line_tmp(to_integer(pix_num)).blu;
	else
		red <= "000";
		grn <= "000";
		blu <= "00";
	end if;
  end process;

  vsync <= vsync_tmp;
  hsync <= hsync_tmp;
end;
