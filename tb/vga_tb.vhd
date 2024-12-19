-- Written by Dr. Stitt / Dr. Bobda and other TA's
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity vga_tb is
end vga_tb;

architecture TB of vga_tb is

    constant TIMEOUT            : time := 1 ms;
    constant MIN_ACCEPT_PERCENT : real := 0.8;
    constant MAX_ACCEPT_PERCENT : real := 1.2;

    signal clkEn            : std_logic := '1';
    signal clk              : std_logic := '0';
    signal red, green, blue : std_logic_vector(3 downto 0);
    signal rst, video_on    : std_logic;
    signal h_sync, v_sync   : std_logic;
    signal en               : std_logic;
    signal vga_clk	    : std_logic := '0';

begin  -- TB

    clk <= not clk and clkEn after 20 ns;

    U_CLK_DIV : entity work.clk_div
        generic map (
            clk_in_freq  => 2,
            clk_out_freq => 1)
        port map (
            clk_in  => clk,
			   --vga_clk = 25MHz clk
            clk_out => vga_clk,
            rst     => rst);

    U_VGA : entity work.vga port map(
        clk      => clk,
        rst      => rst,
        en       => en,
        red      => red,
        green    => green,
        blue     => blue,
        h_sync   => h_sync,
        v_sync   => v_sync,
        video_on => video_on);

    process
        variable ideal  : time;
        variable start  : time;
        variable stop   : time;
        variable width  : time;
        variable errors : integer := 0;

        variable width_p : time;
        variable width_q : time;
        variable width_r : time;
        variable width_s : time;
    begin

        --------------------------------------------------------------------------------
        -- Begin Timing Measurements
        --------------------------------------------------------------------------------
        rst     <= '1';
        en      <= '1';
        for i in 0 to 4 loop
            wait until rising_edge(clk);
        end loop;
        rst <= '0';

        ------------------------------
        -- MEASURE A --
        ------------------------------
        -- A = 31.77 us
        ideal := 31.77 us;
        wait until falling_edge(h_sync) for 10 * TIMEOUT;
        start := now;
        wait until falling_edge(h_sync) for (10 * ideal);
        stop  := now;
        width := (stop - start);

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "A distance too short" & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "A distance too long " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE B --
        ------------------------------
        -- B = 3.77 us
        ideal := 3.77 us;
        start := now;
        wait until rising_edge(h_sync) for (10 * ideal);
        stop  := now;
        width := (stop - start);

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "B distance too short" & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "B distance too long " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE C --
        ------------------------------
        -- C = 1.89 us
        ideal := 1.89 us;
        start := now;
        wait until rising_edge(video_on) for (10 * ideal);
        stop  := now;
        width := (stop - start);

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "C distance too short: " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "C distance too long:  " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE D --
        ------------------------------
        -- D = 25.17 us
        ideal := 25.17 us;
        start := now;
        wait until falling_edge(video_on) for (10 * ideal);
        stop  := now;
        width := (stop - start);

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "D distance too short: " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "D distance too long:  " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE E --
        ------------------------------
        -- E = 0.94 us
        ideal := 0.94 us;
        start := now;
        wait until falling_edge(h_sync) for (10 * ideal);
        stop  := now;
        width := (stop - start);

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "E distance too short: " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "E distance too long:  " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE P --
        ------------------------------
        -- P = 64 us
        ideal   := 64 us;
        wait until falling_edge(v_sync) for (100 * TIMEOUT);
        start   := now;
        wait until rising_edge(v_sync) for (10 * ideal);
        stop    := now;
        width_p := (stop - start);

        assert(width_p > MIN_ACCEPT_PERCENT * ideal) report "P distance too short: " & time'image(width_p) & ". Expected: " & time'image(ideal) severity warning;
        assert(width_p < MAX_ACCEPT_PERCENT * ideal) report "P distance too long:  " & time'image(width_p) & ". Expected: " & time'image(ideal) severity warning;
        assert((width_p > MIN_ACCEPT_PERCENT * ideal) and (width_p < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width_p < MIN_ACCEPT_PERCENT * ideal) or (width_p > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE Q --
        ------------------------------
        -- Q = 1.02 ms
        ideal   := 1.02 ms;
        start   := now;
        wait until rising_edge(video_on) for (10 * ideal);
        stop    := now;
        width_q := (stop - start);

        assert(width_q > MIN_ACCEPT_PERCENT * ideal) report "Q distance too short: " & time'image(width_q) & ". Expected: " & time'image(ideal) severity warning;
        assert(width_q < MAX_ACCEPT_PERCENT * ideal) report "Q distance too long:  " & time'image(width_q) & ". Expected: " & time'image(ideal) severity warning;
        assert((width_q > MIN_ACCEPT_PERCENT * ideal) and (width_q < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width_q < MIN_ACCEPT_PERCENT * ideal) or (width_q > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE R --
        ------------------------------
        -- R = 15.25 ms
        ideal := 15.25 ms;
        start := now;
        for i in 0 to 479 loop
            wait until falling_edge(video_on) for (ideal/48);
        end loop;
        stop    := now;
        width_r := (stop - start);

        assert(width_r > MIN_ACCEPT_PERCENT * ideal) report "R distance too short: " & time'image(width_r) & ". Expected: " & time'image(ideal) severity warning;
        assert(width_r < MAX_ACCEPT_PERCENT * ideal) report "R distance too long:  " & time'image(width_r) & ". Expected: " & time'image(ideal) severity warning;
        assert((width_r > MIN_ACCEPT_PERCENT * ideal) and (width_r < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width_r < MIN_ACCEPT_PERCENT * ideal) or (width_r > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE S --
        ------------------------------
        -- S = 0.35 ms
        ideal   := 0.35 ms;
        start   := now;
        wait until falling_edge(v_sync) for (10 * ideal);
        stop    := now;
        width_s := (stop - start);

        assert(width_s > MIN_ACCEPT_PERCENT * ideal) report "S distance too short: " & time'image(width_s) & ". Expected: " & time'image(ideal) severity warning;
        assert(width_s < MAX_ACCEPT_PERCENT * ideal) report "S distance too long:  " & time'image(width_s) & ". Expected: " & time'image(ideal) severity warning;
        assert((width_s > MIN_ACCEPT_PERCENT * ideal) and (width_s < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width_s < MIN_ACCEPT_PERCENT * ideal) or (width_s > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        ------------------------------
        -- MEASURE O --
        ------------------------------
        -- O = 16.6 ms
        ideal := 16.6 ms;
        width := width_p + width_q + width_r + width_s;

        assert(width > MIN_ACCEPT_PERCENT * ideal) report "O distance too short: " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert(width < MAX_ACCEPT_PERCENT * ideal) report "O distance too long:  " & time'image(width) & ". Expected: " & time'image(ideal) severity warning;
        assert((width > MIN_ACCEPT_PERCENT * ideal) and (width < MAX_ACCEPT_PERCENT * ideal)) report time'image(start) & " -- " & time'image(stop);

        if ((width < MIN_ACCEPT_PERCENT * ideal) or (width > MAX_ACCEPT_PERCENT * ideal)) then
            errors := errors + 1;
        end if;

        --------------------------------------------------------------------------------
        -- Begin Positioning Measurements
        --------------------------------------------------------------------------------

        -- Image movement enabled

        -- top left
        wait for 20 ns;
        en <= '1';

        wait for 200 ns;

	--new
	wait for 150 ms;
        clkEn <= '0';
        report "Simulation Finished" severity note;
        wait;

    end process;

    -- Saves "vga_output.txt" inside the modelsim folder
    -- Upload at https://ericeastwood.com/lab/vga-simulator/
    -- Works with chrome, don't know about other browsers
    -- Should show one picture in each position

    process (clk)
        file file_pointer : text is out "vga_output.txt";
        variable line_el  : line;
    begin

        if rising_edge(clk) then

            -- Write the time
            write(line_el, now);           -- write the line.
            write(line_el, string'(":"));  -- write the line.

            -- Write the hsync
            write(line_el, string'(" "));
            write(line_el, h_sync);     -- write the line.

            -- Write the vsync
            write(line_el, string'(" "));
            write(line_el, v_sync);     -- write the line.

            -- Write the red
            write(line_el, string'(" "));
            write(line_el, red);        -- write the line.

            -- Write the green
            write(line_el, string'(" "));
            write(line_el, green);      -- write the line.

            -- Write the blue
            write(line_el, string'(" "));
            write(line_el, blue);       -- write the line.

            writeline(file_pointer, line_el);  -- write the contents into the file.

        end if;
    end process;
end TB;
