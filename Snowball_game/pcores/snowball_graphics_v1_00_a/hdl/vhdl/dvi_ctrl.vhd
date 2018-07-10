	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dvi_ctrl is
   port (
      -- General System Signals
      ClkxCI         : in     std_logic;
      RstxRBI        : in     std_logic;

      -- Component Input
      RGBxDI         : in std_logic_vector(23 downto 0);
      
      -- Component Output
      XPixelxDO      : out unsigned(10-1 downto 0);
      YPixelxDO      : out unsigned(10-1 downto 0);
      
      -- CH7301C DVI Signals
      DVI_ResetxRBO  : out    std_logic;      
      DVI_XCLKxCO    : out    std_logic;      
      DVI_XCLKxCBO   : out    std_logic;

      DVI_DExSO      : out    std_logic;
      DVI_VSyncxSO   : out    std_logic;
      DVI_HSyncxSO   : out    std_logic;
      DVI_DataxDO    : out    std_logic_vector(12-1 downto 0)
   );
end dvi_ctrl;



architecture rtl of dvi_ctrl is

   constant CLK_DIVISION               : integer := 4;
   constant CLK_DIVISION_W             : integer := 2;

   constant COLOR_DEPTH                : integer := 8;

	constant SCREEN_COUNTER_W           : integer := 10;

   constant SCREEN_WIDTH               : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(640, SCREEN_COUNTER_W);
   constant SCREEN_HEIGHT              : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(480, SCREEN_COUNTER_W);
   
   constant H_SYNC_COLS                : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(96, SCREEN_COUNTER_W);
   constant H_PRE_COLS                	: unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(48, SCREEN_COUNTER_W);
   constant H_POST_COLS                : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(16, SCREEN_COUNTER_W);
   constant V_SYNC_LINES               : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(2, SCREEN_COUNTER_W);
   constant V_PRE_LINES               	: unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(32, SCREEN_COUNTER_W);
   constant V_POST_LINES               : unsigned(SCREEN_COUNTER_W-1 downto 0) := to_unsigned(16, SCREEN_COUNTER_W);
	
	constant LINES_TOTAL						: unsigned(SCREEN_COUNTER_W-1 downto 0) := SCREEN_HEIGHT + V_SYNC_LINES + V_PRE_LINES + V_POST_LINES;
	constant COLS_TOTAL						: unsigned(SCREEN_COUNTER_W-1 downto 0) := SCREEN_WIDTH + H_SYNC_COLS + H_PRE_COLS + H_POST_COLS;

   signal DVI_XCLKxS                   : std_logic;
   signal ClkDivxDN, ClkDivxDP         : unsigned(CLK_DIVISION_W-1 downto 0);
	
	signal LineCntxDN, LineCntxDP			: unsigned(SCREEN_COUNTER_W-1 downto 0);
	signal ColCntxDN, ColCntxDP			: unsigned(SCREEN_COUNTER_W-1 downto 0);
	
	signal VDExS, HDExS, DExS				: std_logic;
	
	signal NewColxS, NewLinexS				: std_logic;
	
begin 
   --- Clock subdivison
	-- We use the overflow of ClkDivxDN to get a period of 4 
   ClkDivxDN <= ClkDivxDP + 1; 
   DVI_XCLKxS <= ClkDivxDP(1);
	
	--
	NewColxS <= ClkDivxDP(1) and ClkDivxDP(0);
	NewLinexS <=  	'1' when ColCntxDP = COLS_TOTAL-1 and ColCntxDP /= ColCntxDN else
						'0';
   
	
	--- Line/Column Count
	LineCntxDN <= 	LineCntxDP when NewLinexS = '0' else
						LineCntxDP + 1 when LineCntxDP < LINES_TOTAL -1 else
						(others => '0');
	ColCntxDN <= 	ColCntxDP when NewColxS = '0' else
						ColCntxDP + 1 when ColCntxDP < COLS_TOTAL -1 else
						(others => '0');
	
   
   --- Line/Frame Sync out
   DVI_VSyncxSO <= '1' when LineCntxDP < V_SYNC_LINES else
                  '0';
   DVI_HSyncxSO <= '1' when ColCntxDP < H_SYNC_COLS else
                  '0';
               
	--- Data Enabled signals
	VDExS <= '1' when LineCntxDP >= V_SYNC_LINES + V_PRE_LINES and LineCntxDP < LINES_TOTAL - V_POST_LINES else
				'0';
	HDExS <= '1' when ColCntxDP >= H_SYNC_COLS + H_PRE_COLS and ColCntxDP < COLS_TOTAL - H_POST_COLS else
				'0';
	DExS	<= VDExS and HDExS;
				
   
   --- Control output signals
   DVI_DExSO <= DExS;
   DVI_XCLKxCO <= DVI_XCLKxS;
   DVI_XCLKxCBO <= not DVI_XCLKxS;

   DVI_ResetxRBO <= '1';

	-- Data out
   DVI_DataxDO <= RGBxDI(3*COLOR_DEPTH/2 - 1 downto 0) when ClkDivxDP(0)/=ClkDivxDP(1) else
                  RGBxDI(3*COLOR_DEPTH-1 downto 3*COLOR_DEPTH/2);
						
						
   --- Component out
   XPixelxDO <= 	ColCntxDP - H_SYNC_COLS - H_PRE_COLS when DExS = '1' else
						(others => '0');
   YPixelxDO <= 	LineCntxDP - V_SYNC_LINES - V_PRE_LINES when VDExS = '1' else
						(others => '0');
   

   --- Registers 
   REG: process (ClkxCI, RstxRBI)
   begin
      if RstxRBI = '0' then
         ClkDivxDP <= to_unsigned(0, ClkDivxDP'length);
         LineCntxDP <= to_unsigned(0, LineCntxDP'length);
         ColCntxDP <= to_unsigned(0, ColCntxDP'length);
         
      elsif rising_edge(ClkxCI) then
         ClkDivxDP <= ClkDivxDN;
         LineCntxDP <= LineCntxDN;
         ColCntxDP <= ColCntxDN;
         
      end if;
   end process REG;

end architecture rtl;
