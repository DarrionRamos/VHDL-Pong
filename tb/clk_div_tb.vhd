LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY clk_div_tb IS
END clk_div_tb;

ARCHITECTURE behavior OF clk_div_tb IS
CONSTANT TEST_IN : positive := 4;
CONSTANT TEST_OUT : positive := 1;

SIGNAL clk, clk_out : STD_LOGIC := '0';

BEGIN
	UUT: entity work.clk_div
	GENERIC MAP(INPUT_FREQ => TEST_IN,
					OUTPUT_FREQ => TEST_OUT)
	PORT MAP(clk_in => clk,
				clk_out => clk_out);

	clk <= not clk after 10ns;
	PROCESS
	BEGIN
		wait for 80 ns;
		
	END PROCESS;
END behavior;