LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use work.vga_lib.all;

ENTITY vga_sync_gen_tb IS
END vga_sync_gen_tb;

ARCHITECTURE behavior OF vga_sync_gen_tb IS
SIGNAL clk, rst : STD_LOGIC := '0';
SIGNAL h_sync, v_sync, video_on : STD_LOGIC := '1';
SIGNAL h_count, v_count : STD_LOGIC_VECTOR(COUNT_RANGE);

BEGIN
	UUT: entity work.vga_sync_gen
	PORT MAP(clk => clk,
				rst => rst,
				h_sync => h_sync,
				v_sync => v_sync,
				video_on => video_on,
				h_count => h_count,
				v_count => v_count);

	clk <= not clk after 5ns;
	PROCESS
	BEGIN
		wait for 10000 ns;
		wait for 20 ns; 
		
	END PROCESS;
END behavior;