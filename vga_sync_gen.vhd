library ieee;
use ieee.std_logic_1164.all;
use work.vga_lib.all;
use ieee.numeric_std.all;

entity vga_sync_gen is
	port (clk, rst							: in std_logic;
			h_count, v_count				: out std_logic_vector(COUNT_RANGE);
			h_sync, v_sync, video_on	: out std_logic := '1');
end vga_sync_gen;

architecture behavior of vga_sync_gen is
signal h_tmp, v_tmp : natural := 0;

begin
	process(clk, rst)
	begin
		if (rst = '1') then
			v_tmp <= 0;
			h_tmp <= 0;
			
		elsif(rising_edge(clk)) then
			-- increment horizontal counter
			if (h_tmp >= H_MAX) then
				h_tmp <= 0;
			else
				h_tmp <= h_tmp + 1;
			end if;
			
			-- increment the vertical counter based on the horizontal pos
			if (v_tmp >= V_MAX) then
				v_tmp <= 0;
			elsif (h_tmp = H_VERT_INC) then
				v_tmp <= v_tmp + 1;
			end if;
			
			-- toggle h_sync
			if (h_tmp = HSYNC_BEGIN) then
				h_sync <= '0';
			elsif (h_tmp = HSYNC_END) then
				h_sync <= '1';
			end if;
			
			-- toggle v_sync
			if (v_tmp = VSYNC_BEGIN) then
				v_sync <= '0';
			elsif (v_tmp = VSYNC_END+1) then
				v_sync <= '1';
			end if;
			
			-- toggle video_on
			if ((h_tmp > H_DISPLAY_END) OR (v_tmp > V_DISPLAY_END+1)) then
				video_on <= '0';
			else
				video_on <= '1';
			end if;
		end if;
	end process;
	h_count <= std_logic_vector(to_unsigned(h_tmp, COUNT_WIDTH));
	v_count <= std_logic_vector(to_unsigned(v_tmp, COUNT_WIDTH));

end behavior;