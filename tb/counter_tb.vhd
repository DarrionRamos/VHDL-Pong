LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY counter_tb IS
END counter_tb;

ARCHITECTURE behavior OF counter_tb IS
CONSTANT TEST_WIDTH : positive := 4;
CONSTANT TEST_MAX : positive := 10;

SIGNAL clk, rst : STD_LOGIC := '0';
SIGNAL count : STD_LOGIC_VECTOR(TEST_WIDTH-1 downto 0);

BEGIN
	UUT: entity work.counter
	GENERIC MAP(WIDTH => TEST_WIDTH,
					MAX => TEST_MAX)
	PORT MAP(clk => clk,
		rst => rst,
				count => count);

	clk <= not clk after 10ns;
	PROCESS
	BEGIN
		wait for 80 ns;
		rst <= '1';
		wait for 20 ns; 
		rst <= '0';
		
	END PROCESS;
END behavior;