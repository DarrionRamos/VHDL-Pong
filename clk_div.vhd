library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.round;
use ieee.std_logic_unsigned.ALL;
  
entity clk_div is
GENERIC(clk_in_freq: integer := 2;
		  clk_out_freq: integer := 1);
port (clk_in, rst   : in std_logic;
		clk_out: out std_logic);
end clk_div;
  
architecture bhv of clk_div is
  
signal count: integer := 0;
signal tmp : std_logic := '0';
constant ratio : integer := (clk_in_freq/clk_out_freq)/2;
  
begin
  
process(clk_in, rst)
begin
	if(falling_edge(clk_in)) then
		if (count = (ratio - 1)) then
			tmp <= NOT tmp;
			count <= 0;
		else
			count <= count + 1;
		end if;
	end if;
end process;
clk_out <= tmp;
end bhv;
