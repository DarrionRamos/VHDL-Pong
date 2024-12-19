-- Greg Stitt
-- University of Florida

-- The following entity is the top-level entity for lab 6. No changes are
-- required, but you need to map the I/O to the appropriate pins on the
-- board and add your own clock divider entity to the project.

-- I/O Explanation (assumes the switches are on side of the
--                  board that is closest to you)
-- switch(9) is the leftmost switch
-- button_n(1) is the top button
-- led5 is the leftmost 7-segment LED
-- ledx_dp is the decimal point on the 7-segment LED for LED x

-- Note: this code will cause a harmless synthesis warning because 
-- some output pins are always '0' or '1'.

library ieee;
use ieee.std_logic_1164.all;

entity top_level is
    port (
        clk50MHz         : in  std_logic;
        switch           : in  std_logic_vector(9 downto 0);
        button_n         : in  std_logic_vector(1 downto 0);
        red, green, blue : out std_logic_vector(3 downto 0);
        h_sync, v_sync   : out std_logic;
        led0             : out std_logic_vector(6 downto 0);
        led0_dp          : out std_logic;
        led1             : out std_logic_vector(6 downto 0);
        led1_dp          : out std_logic;
        led2             : out std_logic_vector(6 downto 0);
        led2_dp          : out std_logic;
        led3             : out std_logic_vector(6 downto 0);
        led3_dp          : out std_logic;
        led4             : out std_logic_vector(6 downto 0);
        led4_dp          : out std_logic;
        led5             : out std_logic_vector(6 downto 0);
        led5_dp          : out std_logic
        );
end top_level;

architecture STR of top_level is

    constant C0    : std_logic_vector(3 downto 0) := (others => '0');
    signal rst     : std_logic;
    signal vga_clk : std_logic;

begin  -- STR

    rst <= not switch(4);

    U_VGA : entity work.vga port map (
		  --vga_clk = 25MHz clk
        clk     => vga_clk,
        rst     => rst,
        en      => switch(5),
		  B1		 => button_n(0),
		  B2		 => button_n(1),
		  SW1		 => switch(1),
		  SW2		 => switch(2),
		  --SW5		 => switch(5),
		  SW8		 => switch(8),
		  SW9		 => switch(9),
        red     => red,
        green   => green,
        blue    => blue,
        h_sync  => h_sync,
        v_sync  => v_sync,
		-- "open" tells synthesis tool you want to leave it open so you dont get a warning
        video_on => open);

    U_CLK_DIV : entity work.clk_div
        generic map (
            clk_in_freq  => 2,
            clk_out_freq => 1)
        port map (
            clk_in  => clk50MHz,
			   --vga_clk = 25MHz clk
            clk_out => vga_clk,
            rst     => rst);

    U_LED5 : entity work.decode7seg port map (
        input  => C0,
        output => led5);

    U_LED4 : entity work.decode7seg port map (
        input  => C0,
        output => led4);

    U_LED3 : entity work.decode7seg port map (
        input  => C0,
        output => led3);

    U_LED2 : entity work.decode7seg port map (
        input  => C0,
        output => led2);

    U_LED1 : entity work.decode7seg port map (
        input  => C0,
        output => led1);

    U_LED0 : entity work.decode7seg port map (
        input  => C0,
        output => led0);

    led5_dp <= '1';
    led4_dp <= '1';
    led3_dp <= '1';
    led2_dp <= '1';
    led1_dp <= '1';
    led0_dp <= '1';

end STR;
