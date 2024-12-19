-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

package VGA_LIB is

    -----------------------------------------------------------------------------
    -- COUNTER VALUES FOR GENERATING H_SYNC AND V_SYNC (Feel free to adjust, to make more accurate)

    constant H_DISPLAY_END : integer := 639;
    constant HSYNC_BEGIN   : integer := 659;
    constant H_VERT_INC    : integer := 699;
    constant HSYNC_END     : integer := 755;
    constant H_MAX         : integer := 799+2;

    constant V_DISPLAY_END : integer := 479;
    constant VSYNC_BEGIN   : integer := 493;
    constant VSYNC_END     : integer := 494;
    constant V_MAX         : integer := 524+2;

    -----------------------------------------------------------------------------
    -- CONSTANTS FOR SIGNAL WIDTHS

    constant COUNT_WIDTH : integer := 10;
    subtype COUNT_RANGE is natural range COUNT_WIDTH-1 downto 0;

    -----------------------------------------------------------------------------
    -- CONSTANTS DEFINING PIXEL BOUNDARIES OF THE IMAGE FOR EACH IMAGE LOCATION

    constant CENTERED_X_START : integer := 256;
    constant CENTERED_X_END   : integer := 383;
    constant CENTERED_Y_START : integer := 176;
    constant CENTERED_Y_END   : integer := 303;


end VGA_LIB;