library ieee;
use ieee.std_logic_1164.all;
use work.vga_lib.all;
use ieee.numeric_std.all;

entity vga is
	 port (clk : in std_logic;
			 rst : in std_logic;
			 en  : in std_logic;
			 B1, B2, SW1, SW2, SW8, SW9  : in std_logic;
			 red, green, blue : out std_logic_vector(3 downto 0);
			 h_sync, v_sync : out std_logic;
			 video_on : out std_logic);
end vga;

architecture behavior of vga is
CONSTANT SCALER : integer := 12;
SIGNAL h_count, v_count : STD_LOGIC_VECTOR(COUNT_RANGE);
SIGNAL P2_MAX_H : integer := 374;
SIGNAL P2_MIN_H : integer := 266;
SIGNAL P2_MAX_V : integer := 30;
SIGNAL P2_MIN_V : integer := 0;
SIGNAL P1_MAX_H : integer := 374;
SIGNAL P1_MIN_H : integer := 266;
SIGNAL P1_MAX_V : integer := 480;
SIGNAL P1_MIN_V : integer := 450;
SIGNAL BALL_MAX_H : integer := 335;
SIGNAL BALL_MIN_H : integer := 305;
SIGNAL BALL_MAX_V : integer := 255;
SIGNAL BALL_MIN_V : integer := 225;
SIGNAL H_MID   : integer := 320 - 3*SCALER;
SIGNAL V_MID   : integer := 240 - 3*SCALER;
SIGNAL score_1 : integer := 9;
SIGNAL score_2 : integer := 0;
SIGNAL clk_slow : std_logic := '0';
SIGNAL dir   : std_logic := '0';
SIGNAL ball_v_dir : std_logic := '0';
SIGNAL v_int, h_int, ball_h_dir, p1_dir, p2_dir : integer := 0;

TYPE bitmap is array (0 to 4, 0 to 2) of std_logic;
SIGNAL bitmapG : bitmap;
SIGNAL bitmapA : bitmap;
SIGNAL bitmapM : bitmap;
SIGNAL bitmapE : bitmap;
SIGNAL bitmapO : bitmap;
SIGNAL bitmapV : bitmap;
SIGNAL bitmapR : bitmap;
SIGNAL bitmapP : bitmap;
SIGNAL bitmapL : bitmap;
SIGNAL bitmapY : bitmap;
SIGNAL bitmapN : bitmap;
SIGNAL bitmapS : bitmap;
SIGNAL bitmapB : bitmap;
SIGNAL bitmapW : bitmap;
SIGNAL bitmapI : bitmap;
SIGNAL bitmapExclaim : bitmap;
SIGNAL score1_bm : bitmap;
SIGNAL score2_bm : bitmap;

SIGNAL bitmap0 : bitmap;
SIGNAL bitmap1 : bitmap;
SIGNAL bitmap2 : bitmap;
SIGNAL bitmap3 : bitmap;
SIGNAL bitmap4 : bitmap;
SIGNAL bitmap5 : bitmap;
SIGNAL bitmap6 : bitmap;
SIGNAL bitmap7 : bitmap;
SIGNAL bitmap8 : bitmap;
SIGNAL bitmap9 : bitmap;
SIGNAL bitmapWinner : bitmap;

TYPE state_t IS (state0, state1, state2, state3, state4, state5);
SIGNAL state_r : state_t;
	
begin
	sync_gen: entity work.vga_sync_gen
	PORT MAP(clk => clk,
				rst => rst,
				h_sync => h_sync,
				v_sync => v_sync,
				video_on => video_on,
				h_count => h_count,
				v_count => v_count);
				
	U_CLK_DIV : entity work.clk_div
        generic map (
            clk_in_freq  => 100000,
            clk_out_freq => 1)
        port map (
            clk_in  => clk,
            clk_out => clk_slow,
            rst     => rst);
	
	-- Init arrays
	bitmap1 <= ( ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0') );
					 
	bitmap2 <= ( ('1', '1', '1'), 
					 ('0', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '1', '1') );
					 
	bitmap3 <= ( ('1', '1', '1'), 
					 ('0', '0', '1'), 
					 ('0', '1', '1'), 
					 ('0', '0', '1'), 
					 ('1', '1', '1') );
	
	bitmap4 <= ( ('0', '0', '1'), 
					 ('0', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('0', '0', '1') );
					 
   bitmap5 <= ( ('1', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '1', '1'), 
					 ('0', '0', '1'), 
					 ('1', '1', '1') );
	
	bitmap6 <= ( ('0', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1') );
	
	bitmap7 <= ( ('1', '1', '1'), 
					 ('0', '0', '1'), 
					 ('0', '1', '0'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0') );
					 
	bitmap8 <= ( ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('0', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1') );
					 
	bitmap9 <= ( ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('0', '0', '1'), 
					 ('1', '1', '0') );
	
	bitmap0 <= ( ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1') );
					 
	bitmapP <= ( ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0') );
	
	bitmapO <= ( ('0', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('0', '1', '0') );
	
	bitmapN <= ( ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '1', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '1') );
	
	bitmapG <= ( ('1', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1') );
	
	bitmapR <= ( ('1', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '1', '0'), 
					 ('1', '0', '1') );
	
	bitmapE <= ( ('1', '1', '1'), 
					 ('1', '0', '0'), 
					 ('1', '1', '0'), 
					 ('1', '0', '0'), 
					 ('1', '1', '1') );
	
	bitmapS <= ( ('0', '1', '1'), 
					 ('1', '0', '0'), 
					 ('0', '1', '0'), 
					 ('0', '0', '1'), 
					 ('1', '1', '0') );
	
	bitmapB <= ( ('1', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '0') );
	
	bitmapA <= ( ('0', '1', '0'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1') );
					 
	bitmapM <= ( ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1') );
					 
	bitmapV <= ( ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('0', '1', '0') );
					 
	bitmapL <= ( ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('1', '1', '1') );
					
	bitmapY <= ( ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0') );	
					 
	bitmapW <= ( ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '0', '1'), 
					 ('1', '1', '1'), 
					 ('1', '0', '1') );	
					 
	bitmapI <= ( ('1', '1', '1'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('0', '1', '0'), 
					 ('1', '1', '1') );	
	
	bitmapExclaim <= ( ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('1', '0', '0'), 
					 ('0', '0', '0'), 
					 ('1', '0', '0') );
	
	process(h_count, v_count)
	begin
		v_int <= TO_INTEGER(UNSIGNED(v_count));
		h_int <= TO_INTEGER(UNSIGNED(h_count));
		case state_r is
			when state0 => --start menu
				-- P
				if ((unsigned(h_count) > (H_MID - (18 * SCALER))) AND (unsigned(h_count) < (H_MID - (15 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapP((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 18*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- O
				elsif ((unsigned(h_count) > (H_MID - (15 * SCALER))) AND (unsigned(h_count) < (H_MID - (12 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapO((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 15*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- N
				elsif ((unsigned(h_count) > (H_MID - (12 * SCALER))) AND (unsigned(h_count) < (H_MID - (9 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapN((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 12*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- G
				elsif ((unsigned(h_count) > (H_MID - (9 * SCALER))) AND (unsigned(h_count) < (H_MID - (6 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapG((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- !
				elsif ((unsigned(h_count) > (H_MID - (6 * SCALER))) AND (unsigned(h_count) < (H_MID - (3 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapExclaim((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 6*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- P
				elsif ((unsigned(h_count) > (H_MID)) AND (unsigned(h_count) < (H_MID + (3 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapP((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - H_MID)/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- R
				elsif ((unsigned(h_count) > (H_MID + 3*SCALER)) AND (unsigned(h_count) < (H_MID + (6 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapR((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 3*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- E
				elsif ((unsigned(h_count) > (H_MID + 6*SCALER)) AND (unsigned(h_count) < (H_MID + (9 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapE((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 6*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- S
				elsif ((unsigned(h_count) > (H_MID + 9*SCALER)) AND (unsigned(h_count) < (H_MID + (12 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapS((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- S
				elsif ((unsigned(h_count) > (H_MID + 12*SCALER)) AND (unsigned(h_count) < (H_MID + (15 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapS((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 12*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- B
				elsif ((unsigned(h_count) > (H_MID + 18*SCALER)) AND (unsigned(h_count) < (H_MID + (21 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapB((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 18*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- 1
				elsif ((unsigned(h_count) > (H_MID + 21*SCALER)) AND (unsigned(h_count) < (H_MID + (24 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmap1((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 21*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				else 
					red <= "0000";
					green <= "0000";
					blue <= "0000";
				end if;
				
				
			when state1 => -- Gameplay
				-- P1 paddle
				if ((unsigned(h_count) > P1_MIN_H) AND (unsigned(v_count) > P1_MIN_V) AND (unsigned(h_count) < P1_MAX_H) AND (unsigned(v_count) < P1_MAX_V)) then
					red <= "0000";
					green <= "1111";
					blue <= "0000";
				-- P2 paddle
				elsif ((unsigned(h_count) > P2_MIN_H) AND (unsigned(v_count) > P2_MIN_V) AND (unsigned(h_count) < P2_MAX_H) AND (unsigned(v_count) < P2_MAX_V)) then
					red <= "0000";
					green <= "0000";
					blue <= "1111";
				-- Ball
				elsif ((unsigned(h_count) > BALL_MIN_H) AND (unsigned(v_count) > BALL_MIN_V) AND (unsigned(h_count) < BALL_MAX_H) AND (unsigned(v_count) < BALL_MAX_V)) then
					red <= "1111";
					green <= "0000";
					blue <= "0000";
				-- P1 score
				elsif ((unsigned(h_count) > (640 - 3*SCALER)) AND (unsigned(h_count) < 640) AND (unsigned(v_count) < (480) AND (unsigned(v_count) > 480 - (5 * SCALER)))) then
					case score_1 is
						when 0 =>
							score1_bm <= bitmap0;
						when 1 =>
							score1_bm <= bitmap1;
						when 2 =>
							score1_bm <= bitmap2;
						when 3 =>
							score1_bm <= bitmap3;
						when 4 =>
							score1_bm <= bitmap4;
						when 5 =>
							score1_bm <= bitmap5;
						when 6 =>
							score1_bm <= bitmap6;
						when 7 =>
							score1_bm <= bitmap7;
						when 8 =>
							score1_bm <= bitmap8;
						when 9 =>
							score1_bm <= bitmap9;
						when others =>
							score1_bm <= bitmap0;
					end case;
					if (score1_bm((v_int - (480 - 5*SCALER))/SCALER, (h_int - (640 - 3*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- P2 score
				elsif ((unsigned(h_count) > (640 - 3*SCALER)) AND (unsigned(h_count) < 640) AND (unsigned(v_count) < (5 * SCALER) AND (unsigned(v_count) > 0))) then
					case score_2 is
						when 0 =>
							score2_bm <= bitmap0;
						when 1 =>
							score2_bm <= bitmap1;
						when 2 =>
							score2_bm <= bitmap2;
						when 3 =>
							score2_bm <= bitmap3;
						when 4 =>
							score2_bm <= bitmap4;
						when 5 =>
							score2_bm <= bitmap5;
						when 6 =>
							score2_bm <= bitmap6;
						when 7 =>
							score2_bm <= bitmap7;
						when 8 =>
							score2_bm <= bitmap8;
						when 9 =>
							score2_bm <= bitmap9;
						when others =>
							score2_bm <= bitmap0;
					end case;
					if (score2_bm((v_int)/SCALER, (h_int - (640 - 3*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				else 
					red <= "0000";
					green <= "0000";
					blue <= "0000";
				end if;
				
				
			when state2 => -- Game over
				-- Draw GAME OVER
				-- G
				if ((unsigned(h_count) > (H_MID - (9 * SCALER))) AND (unsigned(h_count) < (H_MID - (6 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapG((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- A
				elsif ((unsigned(h_count) > (H_MID - (6 * SCALER))) AND (unsigned(h_count) < (H_MID - (3 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapA((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 6*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- M
				elsif ((unsigned(h_count) > (H_MID - (3 * SCALER))) AND (unsigned(h_count) < (H_MID - (0 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapM((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID - 3*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- E
				elsif ((unsigned(h_count) > (H_MID)) AND (unsigned(h_count) < (H_MID + (3 * SCALER))) AND (unsigned(v_count) < V_MID) AND (unsigned(v_count) > (V_MID - (5 * SCALER)))) then
					if (bitmapE((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - H_MID)/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- O
				elsif ((unsigned(h_count) > (H_MID + 9*SCALER)) AND (unsigned(h_count) < (H_MID + (12 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapO((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- V
				elsif ((unsigned(h_count) > (H_MID + 12*SCALER)) AND (unsigned(h_count) < (H_MID + (15 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapV((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 12*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- E
				elsif ((unsigned(h_count) > (H_MID + 15*SCALER)) AND (unsigned(h_count) < (H_MID + (18 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapE((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 15*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- R
				elsif ((unsigned(h_count) > (H_MID + 18*SCALER)) AND (unsigned(h_count) < (H_MID + (21 * SCALER))) AND (unsigned(v_count) < (V_MID) AND (unsigned(v_count) > V_MID - (5 * SCALER)))) then
					if (bitmapR((v_int - (V_MID - 5*SCALER))/SCALER, (h_int - (H_MID + 18*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
					
				-- Draw PLAYER X WINS
				-- P
				elsif ((unsigned(h_count) > (H_MID - (18 * SCALER))) AND (unsigned(h_count) < (H_MID - (15 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapP((v_int - V_MID)/SCALER, (h_int - (H_MID - 18*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- L
				elsif ((unsigned(h_count) > (H_MID - (15 * SCALER))) AND (unsigned(h_count) < (H_MID - (12 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapL((v_int - V_MID)/SCALER, (h_int - (H_MID - 15*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- A
				elsif ((unsigned(h_count) > (H_MID - (12 * SCALER))) AND (unsigned(h_count) < (H_MID - (9 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapA((v_int - V_MID)/SCALER, (h_int - (H_MID - 12*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- Y
				elsif ((unsigned(h_count) > (H_MID - (9 * SCALER))) AND (unsigned(h_count) < (H_MID - (6 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapY((v_int - V_MID)/SCALER, (h_int - (H_MID - 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- E
				elsif ((unsigned(h_count) > (H_MID - (6 * SCALER))) AND (unsigned(h_count) < (H_MID - (3 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapE((v_int - V_MID)/SCALER, (h_int - (H_MID - 6*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- R
				elsif ((unsigned(h_count) > (H_MID - (3 * SCALER))) AND (unsigned(h_count) < (H_MID - (0 * SCALER))) AND (unsigned(v_count) > V_MID) AND (unsigned(v_count) < (V_MID + (5 * SCALER)))) then
					if (bitmapR((v_int - V_MID)/SCALER, (h_int - (H_MID - 3*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- PLAYER NUMBER
				elsif ((unsigned(h_count) > (H_MID + 3*SCALER)) AND (unsigned(h_count) < (H_MID + (6 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (score_1 >= 10) then
						if (bitmap1((v_int - V_MID)/SCALER, (h_int - (H_MID + 3*SCALER))/SCALER) = '1') then
							red <= "0000";
							green <= "1111";
							blue <= "0000";
						else
							red <= "0000";
							green <= "0000";
							blue <= "0000";
						end if;
					else
						if (bitmap2((v_int - V_MID)/SCALER, (h_int - (H_MID + 3*SCALER))/SCALER) = '1') then
							red <= "0000";
							green <= "0000";
							blue <= "1111";
						else
							red <= "0000";
							green <= "0000";
							blue <= "0000";
						end if;
					end if;
				-- W
				elsif ((unsigned(h_count) > (H_MID + 9*SCALER)) AND (unsigned(h_count) < (H_MID + (12 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (bitmapW((v_int - V_MID)/SCALER, (h_int - (H_MID + 9*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- I
				elsif ((unsigned(h_count) > (H_MID + 12*SCALER)) AND (unsigned(h_count) < (H_MID + (15 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (bitmapI((v_int - V_MID)/SCALER, (h_int - (H_MID + 12*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- N
				elsif ((unsigned(h_count) > (H_MID + 15*SCALER)) AND (unsigned(h_count) < (H_MID + (18 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (bitmapN((v_int - V_MID)/SCALER, (h_int - (H_MID + 15*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- S
				elsif ((unsigned(h_count) > (H_MID + 18*SCALER)) AND (unsigned(h_count) < (H_MID + (21 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (bitmapS((v_int - V_MID)/SCALER, (h_int - (H_MID + 18*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				-- !
				elsif ((unsigned(h_count) > (H_MID + 21*SCALER)) AND (unsigned(h_count) < (H_MID + (24 * SCALER))) AND (unsigned(v_count) > (V_MID) AND (unsigned(v_count) < V_MID + (5 * SCALER)))) then
					if (bitmapExclaim((v_int - V_MID)/SCALER, (h_int - (H_MID + 21*SCALER))/SCALER) = '1') then
						red <= "1111";
						green <= "1111";
						blue <= "1111";
					else
						red <= "0000";
						green <= "0000";
						blue <= "0000";
					end if;
				else 
					red <= "0000";
					green <= "0000";
					blue <= "0000";
				end if;
			when others =>
				red <= "0000";
				green <= "0000";
				blue <= "0000";
		end case;
	end process;
	
	-- slowed graphics process
	process(state_r, en, clk_slow, SW1, SW2, SW8, SW9, B1, B2)
	begin
		-- reset values in state0
		if (state_r = state0) then
			score_1 <= 0;
			score_2 <= 0;
			BALL_MAX_H <= 335;
			BALL_MIN_H <= 305;
			BALL_MAX_V <= 255;
			BALL_MIN_V <= 225;
			P2_MAX_H <= 374;
			P2_MIN_H <= 266;
			P2_MAX_V <= 30;
			P2_MIN_V <= 0;
			P1_MAX_H <= 374;
			P1_MIN_H <= 266;
			P1_MAX_V <= 480;
			P1_MIN_V <= 450;
		else
			if ((en = '1') AND (rising_edge(clk_slow)) AND state_r = state1) then
				-- paddle movement
				if (SW1 = '1' AND P1_MAX_H < 640 - 3*SCALER) then
					-- p1 right
					P1_MIN_H <= P1_MIN_H + 1;
					P1_MAX_H <= P1_MAX_H + 1;
					p1_dir <= 1;
				elsif (SW2 = '1' AND P1_MIN_H > 1) then
					-- p1 left
					P1_MIN_H <= P1_MIN_H - 1;
					P1_MAX_H <= P1_MAX_H - 1;
					p1_dir <= 2;
				else
					p1_dir <= 0;
				end if;
				
				if (SW8 = '1' AND P2_MAX_H < 640 - 3*SCALER) then
					-- p2 right
					P2_MIN_H <= P2_MIN_H + 1;
					P2_MAX_H <= P2_MAX_H + 1;
					p2_dir <= 1;
				elsif (SW9 = '1' AND P2_MIN_H > 1) then
					-- p2 left
					P2_MIN_H <= P2_MIN_H - 1;
					P2_MAX_H <= P2_MAX_H - 1;
					p2_dir <= 2;
				else
					p2_dir <= 0;
				end if;
				
				-- ball movement
				if (ball_v_dir = '1' AND BALL_MIN_V > 0) then
					-- move ball up
					BALL_MIN_V <= BALL_MIN_V - 1;
					BALL_MAX_V <= BALL_MAX_V - 1;
				elsif (ball_v_dir = '0' AND BALL_MAX_V < 480) then
					-- move ball down
					BALL_MIN_V <= BALL_MIN_V + 1;
					BALL_MAX_V <= BALL_MAX_V + 1;
				end if;
				
				if (ball_h_dir = 1 AND BALL_MIN_H > 0) then
					-- move ball right
					BALL_MIN_H <= BALL_MIN_H + 1;
					BALL_MAX_H <= BALL_MAX_H + 1;
				elsif (ball_h_dir = 2 AND BALL_MAX_H < 640) then
					-- move ball left
					BALL_MIN_H <= BALL_MIN_H - 1;
					BALL_MAX_H <= BALL_MAX_H - 1;
				end if;
				
				-- check paddle collision
				if (BALL_MIN_V <= 30 AND (BALL_MAX_H >= P2_MIN_H OR BALL_MIN_H <= P2_MAX_H)) then
					ball_v_dir <= '0';
					case p2_dir is
						when 0 => -- when paddle from p2 is not moving
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 2;
								when 2 =>
									ball_h_dir <= 1;
								when others =>
									ball_h_dir <= 0;
							end case;
						when 1 => -- paddle moving right
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 1;
								when 2 =>
									ball_h_dir <= 0;
								when others =>
									ball_h_dir <= 1;
							end case;
						when 2 => -- paddle moving left
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 0;
								when 2 =>
									ball_h_dir <= 2;
								when others =>
									ball_h_dir <= 2;
							end case;
						when others =>
							ball_h_dir <= 0;
					end case;
				elsif (BALL_MAX_V >= 450 AND (BALL_MIN_H >= P1_MAX_H OR BALL_MIN_H <= P1_MAX_H)) then
					ball_v_dir <= '1';
					case p1_dir is
						when 0 => -- when paddle from p2 is not moving
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 2;
								when 2 =>
									ball_h_dir <= 1;
								when others =>
									ball_h_dir <= 0;
							end case;
						when 1 => -- paddle moving right
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 1;
								when 2 =>
									ball_h_dir <= 0;
								when others =>
									ball_h_dir <= 1;
							end case;
						when 2 => -- paddle moving left
							case ball_h_dir is 
								when 1 =>
									ball_h_dir <= 0;
								when 2 =>
									ball_h_dir <= 2;
								when others =>
									ball_h_dir <= 2;
							end case;
						when others => 
							ball_h_dir <= 0;
					end case;
				end if;
				
				-- check wall collision
				if (BALL_MIN_H <= 5) then
					ball_h_dir <= 1;
				elsif (BALL_MAX_H >= 600) then
					ball_h_dir <= 2;
				end if;
				
				-- check goal
				if (BALL_MIN_V <= 30 AND (BALL_MAX_H < P2_MIN_H OR BALL_MIN_H > P2_MAX_H)) then
					BALL_MAX_H <= 335;
					BALL_MIN_H <= 305;
					BALL_MAX_V <= 255;
					BALL_MIN_V <= 225;
					ball_v_dir <= '0';
					ball_h_dir <= 0;
					score_1 <= score_1 + 1;
				elsif (BALL_MAX_V >= 450 AND (BALL_MAX_H < P1_MIN_H OR BALL_MIN_H > P1_MAX_H)) then
					BALL_MAX_H <= 335;
					BALL_MIN_H <= 305;
					BALL_MAX_V <= 255;
					BALL_MIN_V <= 225;
					ball_v_dir <= '1';
					ball_h_dir <= 0;
					score_2 <= score_2 + 1;
				end if;
				
			end if;
		end if;
	end process;
	
	--fsm
	PROCESS(clk, rst, score_1, score_2)
	BEGIN
		if (rising_edge(clk)) then
			if (rst = '1') then
				state_r <= state0;
			end if;
			
			case state_r is
				when state0 => -- start menu 
					if (B1 = '0') then
						state_r       <= state1;
					end if;
					
				when state1 => -- in game
					if ((score_1 >= 10) OR (score_2 >= 10)) then
						state_r <= state2;
					end if;
					
				when state2 => -- GAME OVER
					if (B2 = '0') then
						state_r       <= state0;
					end if;
				when others => 
					-- reset for unexpected values
					state_r    <= state0;
			end case;
		end if;
	end PROCESS;
end behavior;
