library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.round;
use ieee.std_logic_unsigned.ALL;
  
entity counter is
GENERIC(WIDTH: positive;
		  MAX: positive := 1);
port (clk,rst  : in std_logic;
		count		: out std_logic_vector(WIDTH-1 downto 0));
end counter;
  
architecture behavior of counter is 
signal tmp : natural := 0;
begin
  
process(clk, rst)
begin
	if (rst = '1') then
		tmp <= 0;
		
	elsif(rising_edge(clk)) then
		if (tmp = MAX) then
			tmp <= 0;
		else
			tmp <= tmp + 1;
		end if;
	end if;
end process;
count <= std_logic_vector(to_signed(tmp, WIDTH));
end behavior;
