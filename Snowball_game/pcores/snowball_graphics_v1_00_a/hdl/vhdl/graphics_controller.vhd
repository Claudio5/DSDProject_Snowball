----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:59:01 04/08/2015 
-- Design Name: 
-- Module Name:    graphics_controller - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity graphics_controller is
   port (
      -- General System Signals
      ClkxCI         : in     std_logic;
      RstxRBI        : in     std_logic;
      
      -- Component Input
      XPlayer1xDI       : in     std_logic_vector(10-1 downto 0);
		XPlayer2xDI			: in 		std_logic_vector(9 downto 0);
		Ball1xDI				: in     std_logic;
		Ball2xDI				: in     std_logic;
		XBall1xDI			: in		std_logic_vector(9 downto 0);
		XBall2xDI			: in		std_logic_vector(9 downto 0);
		YBall1xDI			: in		std_logic_vector(9 downto 0);
		YBall2xDI			: in		std_logic_vector(9 downto 0);
		arrowAngle1xDI		: in		std_logic_vector(7 downto 0);
		arrowAngle2xDI		: in		std_logic_vector(7 downto 0);
		healthPlayer1xDI	: in		std_logic_vector(3 downto 0);
		healthPlayer2xDI	: in		std_logic_vector(3 downto 0);

      
      -- CH7301C DVI Signals
      DVI_ResetxRBO  : out    std_logic;      
      DVI_XCLKxCO    : out    std_logic;      
      DVI_XCLKxCBO   : out    std_logic;

      DVI_DExSO      : out    std_logic;
      DVI_VSyncxSO   : out    std_logic;
      DVI_HSyncxSO   : out    std_logic;
      DVI_DataxDO    : out    std_logic_vector(12-1 downto 0)
   );
end graphics_controller;

architecture rtl of graphics_controller is
   constant BALL_HEIGHT             : unsigned(10-1 downto 0) := to_unsigned(20, 10);
   constant BALL_WIDTH              : unsigned(10-1 downto 0) := to_unsigned(20, 10);
   constant PLATE_HEIGHT            : unsigned(10-1 downto 0) := to_unsigned(10, 10);
   constant PLATE_WIDTH             : unsigned(10-1 downto 0) := to_unsigned(90, 10);
	
	constant SCREEN_HEIGHT				: integer := 480;
	constant SCREEN_WIDTH				: integer := 640;
	constant WALL_DOWN					: integer := 312;
			
	constant SPRITE_SIZE					: integer := 32;
   constant BALL_RGB                : std_logic_vector(23 downto 0) := x"FF0000";
   constant PLATE_RGB               : std_logic_vector(23 downto 0) := x"0000FF";
   constant BG_RGB		    			: std_logic_vector(23 downto 0) := x"00FF00";

   signal RGBxD                     : std_logic_vector(23 downto 0);
   signal XPixelxD, YPixelxD        : unsigned(10-1 downto 0);
	signal tileIDxS						: unsigned(2 downto 0);
	
	
	--LUT--
	type LUT is array(natural range 0 to 59,natural range 0 to 79) of unsigned(2 downto 0);
	
	type LUT_COLOR is array (natural range 0 to 7,natural range 0 to 7) of std_logic_vector(23 downto 0);
	
	type LUT_SPRITE is array (natural range 0 to SPRITE_SIZE-1, natural range 0 to SPRITE_SIZE-1) of std_logic_vector(23 downto 0);
	
	---------------INIT-SPRITE----------------------
	constant LUT_SPRITE_PLAYER1 : LUT_SPRITE := ((x"F7FFFA",x"FBFFFA",x"FFFEFD",x"FFFDFA",x"FFFFF6",x"FFFFF6",x"FEFFFF",x"FCFDFF",x"FFFFFA",x"FEFFF5",x"FDFEF6",x"FEFFF8",x"FFFFFB",x"FDFFFC",x"FEFFFF",x"FBFFFF",x"FCFFFB",x"FCFFF4",x"FFFFF2",x"FFFFF4",x"FFFDFE",x"FEFCFF",x"FFFEFB",x"FFFFF7",x"FEFFF8",x"FAFFF9",x"FCFDFF",x"FEFDFF",x"FFFCFF",x"FFFFFD",x"F7FFFA",x"F4FFFA"),
(x"FBFFFB",x"FEFFF6",x"FFFFED",x"FFFDE2",x"FFFFD7",x"FFFFD5",x"FFFFDD",x"FFFFDF",x"FFFFD7",x"FFFFD2",x"FFFFD6",x"FFFFD4",x"FFFFD4",x"FFFFD9",x"FFFFDE",x"FFFFDB",x"FFFFD7",x"FFFFD6",x"FFFFD4",x"FFFDCE",x"FFFFDC",x"FFFFDC",x"FFFAD3",x"FFFFD6",x"FFFECD",x"FFFFD1",x"FFFFDB",x"FFFFDD",x"FFFBD7",x"FFFDDD",x"FEFFED",x"F7FFF3"),
(x"FFFEFD",x"FFFFED",x"FFF8C4",x"FDF0A2",x"F5ED8A",x"F1ED7F",x"F4EE7E",x"F2EA7B",x"F6EC7B",x"F9EE7B",x"F0E772",x"F5EA74",x"FAEE78",x"F3E771",x"F2E773",x"F2E974",x"ECE571",x"EFE572",x"ECE16E",x"EFE470",x"EFE671",x"EBE06C",x"EADD6B",x"EDDE69",x"EADF61",x"ECE161",x"EADC5F",x"ECDE63",x"EADA60",x"F0E482",x"FEFACA",x"FFFFEA"),
(x"FFFBFB",x"FFFCE2",x"FBEEA0",x"F9EC7A",x"F8F06B",x"FAF462",x"FBF360",x"FAF05A",x"FBED58",x"FDED59",x"FEF05B",x"F8E952",x"F9E94E",x"FDED50",x"F7E94B",x"F8EB4F",x"F7E954",x"F5E752",x"F7E851",x"F5E64B",x"EEE143",x"F1E446",x"F7E64E",x"EEDE43",x"F2E33E",x"EFE138",x"EDDD32",x"EFDF34",x"EBD833",x"E8D552",x"F0E29B",x"FFFDD5"),
(x"FFFEFF",x"FFFEDE",x"F5ED8B",x"F7EF68",x"F7F062",x"F8F05F",x"F7ED5A",x"F7EB57",x"FCED56",x"FAEB54",x"F9EA59",x"FDEE5D",x"F7E851",x"F3E449",x"F9EC4E",x"F5E84E",x"F4E652",x"EEE04B",x"F6E84A",x"F3E642",x"F1E342",x"F3E546",x"EDDC44",x"F0E146",x"EDE13D",x"E8E035",x"EBE132",x"EFE234",x"F2E038",x"ECD64C",x"E7D37A",x"FFFFBE"),
(x"FEFFFA",x"FFFFD9",x"F2EE80",x"F8F25E",x"F8F25C",x"F7F05A",x"F8EE5B",x"FEF05C",x"FCED54",x"FAED53",x"F2E654",x"F2E759",x"F7EC5E",x"F4E85E",x"EFE562",x"EFE569",x"EFE470",x"EDE169",x"ECE058",x"F2E652",x"EFE246",x"ECDE3F",x"F4E449",x"EEDE41",x"EDE23B",x"EAE438",x"E9E333",x"E6DC2D",x"ECDB33",x"ECD748",x"E3CD68",x"FFFFB2"),
(x"FFFFF6",x"FFFFD6",x"F4EE7C",x"F9F25B",x"F7F057",x"F7EE55",x"F7EB57",x"F9ED59",x"F9EB54",x"F0E74C",x"F8F359",x"ECEA59",x"ECE769",x"E4DD73",x"ACA555",x"888343",x"827C42",x"898444",x"A9A14E",x"DBD064",x"F0E558",x"EDE044",x"F4E244",x"F0DC3B",x"E8DB34",x"E8E035",x"E4E036",x"E4DD34",x"E9DC35",x"E9DB47",x"E1D26B",x"FFFFB3"),
(x"FFFFF3",x"FFFFD6",x"F3EC78",x"F7ED57",x"F9EE54",x"FAEF55",x"FAEC57",x"F8EA55",x"F7EC52",x"F3EC53",x"EBEA54",x"EDED6B",x"AFAC4D",x"9D9856",x"F1ECC2",x"FFFFE3",x"FFFFEC",x"FFFFE8",x"EFEAC0",x"A39C56",x"ABA239",x"EDE15B",x"EEDA43",x"F1DE3A",x"EFDE38",x"ECDF38",x"E5DD34",x"E6DE35",x"E5DA30",x"E1D541",x"DFD46B",x"FFFFB1"),
(x"FFFFFA",x"FFFFD9",x"F5EB7C",x"FCEE59",x"FBEC53",x"FAEB52",x"FAEA56",x"F9EA53",x"F7EA4E",x"F1EA53",x"EAE861",x"B9B752",x"C3BC8E",x"FFFCE9",x"FFFFEA",x"FFFFEF",x"FFFFF8",x"FFFEF9",x"FFFFF3",x"FFFFE6",x"C4BD87",x"B5AA50",x"E9D94E",x"F1DD3C",x"F1DA3C",x"EDD938",x"E9D830",x"E6D92B",x"E9DB30",x"DFD43E",x"DDD66B",x"FFFFAE"),
(x"FFFEFB",x"FFFFD9",x"F3E97A",x"FAEC57",x"FAEB52",x"FAE951",x"FAE955",x"F7E753",x"F1E448",x"F2EC5A",x"E3E06B",x"918D44",x"FFFEED",x"FFFCFF",x"FFFFF8",x"FBFDF2",x"FFFFFF",x"FBFCFF",x"FFFEFF",x"FFFEF9",x"FFFFEC",x"9B9355",x"DFD154",x"ECDA3C",x"ECD537",x"ECD633",x"EBD92F",x"E7D729",x"E8D82A",x"DED33B",x"DBD469",x"FFFFB0"),
(x"FFFFFA",x"FFFFD8",x"F0E879",x"F7EC56",x"F9EA51",x"F8E950",x"F8E855",x"F5E655",x"F6EB53",x"F0E863",x"C0B95E",x"E1DBAB",x"FFFDF8",x"E8E0EB",x"979694",x"FFFFFB",x"FDFCFF",x"FEFFFF",x"979B9C",x"E2E4DF",x"FFFFF7",x"E3DFB2",x"B9AF40",x"E7DA40",x"F0DF37",x"E9D828",x"E7D729",x"E7D827",x"E7D827",x"E0D339",x"DDD269",x"FFFFB4"),
(x"FEFFFA",x"FFFFD7",x"F0E977",x"F6EB55",x"F8E950",x"F7E851",x"F8E855",x"F5E753",x"F3E84E",x"EBE35E",x"AFA858",x"F7EFCA",x"FFFAF9",x"A69EA9",x"262427",x"FFFDFE",x"FFFEFF",x"FFFEFF",x"272926",x"999E98",x"FFFFFB",x"FAF6D1",x"A39A31",x"E2D741",x"E2D227",x"E8D823",x"ECDD2C",x"E5D625",x"E2D320",x"E2D338",x"DFD269",x"FFFFB0"),
(x"FFFEFC",x"FFFFD8",x"F2E877",x"F8EA55",x"F9E755",x"F8E753",x"F9E852",x"F6E84A",x"F2E944",x"EEE759",x"A8A24E",x"FCF4CD",x"FFFAF4",x"FCF2FA",x"D8D3D9",x"FFFCFF",x"FFFDFF",x"FFFCFB",x"D9DAD5",x"F5F6F0",x"FFFCF7",x"FCF7D1",x"A2962A",x"E9DA43",x"F0DB34",x"EDD92A",x"E6D527",x"E5D426",x"E5D424",x"DFD035",x"DBCE5E",x"FFFFAB"),
(x"FFFEFC",x"FFFFD7",x"F2E974",x"F8EB51",x"F8E753",x"F7E650",x"F6E74C",x"F3E64C",x"F0E555",x"E7E06B",x"ACA55F",x"F2EECB",x"FFFEF4",x"F5F0F4",x"CDCBD0",x"FFFDFF",x"FFF9FD",x"FFFCFD",x"E5E1DE",x"F9FAF4",x"FEFFF9",x"F8F5D2",x"A89D43",x"DFCD4D",x"E3CF3C",x"EBD436",x"E1CF25",x"E5D426",x"E7D624",x"DFCF32",x"D9CC5C",x"FFFFAB"),
(x"FFFFFB",x"FFFFD5",x"F0E86C",x"F6EA48",x"F6E849",x"F5E748",x"F2E547",x"EBDF57",x"A79A3C",x"A69B5D",x"908D62",x"E5E5CD",x"FFFFF8",x"FAFCFB",x"A2A7A3",x"7C7B79",x"B09BA2",x"8F7A81",x"999093",x"FEFFFD",x"F9FFFD",x"E7ECD5",x"89864F",x"9F933F",x"A39125",x"DDC944",x"E8D636",x"E4D323",x"E2CF1B",x"DFCF31",x"DED063",x"FFFFAB"),
(x"FFFFFA",x"FFFFD2",x"EEE66A",x"F4E846",x"F6E945",x"F4E645",x"F0E345",x"E7DA57",x"988936",x"F4E8B4",x"E3E0BD",x"FFFFED",x"FAFDF6",x"FCFFFF",x"F9FFF9",x"FBFCF7",x"F6E3E9",x"B29EA7",x"FFFDFD",x"FAFFFB",x"F8FFFF",x"FAFFF0",x"E6E4B4",x"F5EC9F",x"A19026",x"D8C43F",x"E0CC2D",x"E6D223",x"E5D21E",x"DDCB2D",x"DACC5F",x"FFFFAD"),
(x"FFFCF6",x"FFFFD3",x"ECE16D",x"FAED51",x"F2E445",x"F2E342",x"F7E74A",x"EEDF50",x"DBCF59",x"9A933B",x"9C9A6A",x"FEFFEC",x"FEFFFA",x"FEFFFF",x"FDFFFA",x"FDFDFB",x"FFFDFF",x"FDF9FA",x"FEFFF8",x"FBFFF8",x"F6FFFC",x"FFFFED",x"A7A262",x"958A21",x"CFBF34",x"E3D12F",x"E3CE25",x"E7D123",x"E1CA1A",x"E3CE33",x"DCCC5D",x"FFFFAA"),
(x"FFFFF6",x"FFFDCF",x"F0E571",x"EFE246",x"F2E445",x"F4E544",x"F1DF41",x"F0E14A",x"E9DD53",x"E4DD73",x"8E8C59",x"F2F3E1",x"FDFEF9",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFEFF",x"FEFFFF",x"F9FFF3",x"FBFFF6",x"FCFFFF",x"FAF9E5",x"877E3D",x"D9CD5F",x"E2D338",x"E1D01E",x"E6D223",x"E3CD1F",x"E4CD1D",x"DFCA2F",x"D9C958",x"FFFFA6"),
(x"FEFFF3",x"FFFFD0",x"E8E266",x"F1E845",x"F2E443",x"F6E744",x"F2E33E",x"EDDF40",x"EFE454",x"DAD267",x"8B8757",x"FFFFF3",x"FEFDF9",x"FFFFFF",x"FEFDFF",x"FEFDFF",x"FFFEFF",x"FEFCFD",x"FFFFFB",x"FFFFFA",x"FDFCFA",x"FFFFEF",x"9D8F60",x"D1C162",x"D9CC2E",x"E4D61D",x"E1CE1C",x"DFCA19",x"E3CE19",x"DDCB2B",x"D6CB57",x"FFFFAA"),
(x"FFFFF8",x"FFFFD4",x"E8E266",x"F0E744",x"F2E443",x"F0E243",x"EADD41",x"EFE456",x"E5DB62",x"8B832E",x"F4F0CB",x"FFFFF6",x"FFFEFB",x"FFFEFF",x"FFFEFF",x"FFFEFF",x"FFFAFE",x"FFFEFF",x"FFFFFD",x"FDFCF8",x"FFFFFB",x"FFFEF2",x"F8EDCF",x"847530",x"D4C949",x"DFD331",x"DACA1F",x"E3CF20",x"E1CC17",x"D9CA27",x"D5CC57",x"FFFFA1"),
(x"FEFAF9",x"FFFCD4",x"EBE26B",x"EFE246",x"EBDE42",x"EBE14E",x"EBE263",x"D8D06D",x"89803F",x"E4DCB7",x"FFFFED",x"FFFFF5",x"FFFEFB",x"FFFFFD",x"FDFEF9",x"FFFFFD",x"FFFDFF",x"FFFDFF",x"FBFAF8",x"FFFFFA",x"FEFFFA",x"FFFFF8",x"FFFFF6",x"E9E0C3",x"827A32",x"CBC150",x"D5CA34",x"DECE21",x"DCC915",x"DECF2C",x"D2C952",x"FFFFA6"),
(x"FFFCFF",x"FFFFDB",x"E9DC69",x"F1E247",x"EFE244",x"DED647",x"958F1F",x"928C40",x"F8F0CC",x"FFFEF2",x"FFFEF7",x"FFFEFA",x"FFFEFD",x"FDFCFA",x"FFFFFB",x"FBFCF7",x"FFFEFF",x"FEF9FD",x"FFFEFF",x"FCFDF8",x"FEFFF8",x"FEFFFA",x"FFFDFE",x"FFFEF4",x"F8F1C5",x"968E39",x"948800",x"CCBE17",x"E3CE1B",x"D8C423",x"D2C650",x"FFFFA4"),
(x"FFF7F8",x"FFFCD6",x"F0DF69",x"ECDD3C",x"EDE03C",x"D7CF3C",x"888214",x"D4D089",x"F4EECC",x"FFF8EE",x"FFFEFD",x"FFFEFF",x"FFFAFF",x"FFFEFF",x"FDFEFF",x"FEFFFF",x"FFFDFF",x"FFFDFF",x"FFFDFF",x"FFFEFF",x"FDFEF8",x"FEFFFA",x"FFFEFC",x"FFFFF1",x"F6EFC1",x"DAD27F",x"8F8003",x"CAB51A",x"DFC516",x"E0C725",x"D5C353",x"FFFFAC"),
(x"FFFDFA",x"FFFDD2",x"EBDB61",x"F4E33E",x"F0E239",x"E7DC42",x"E2D960",x"C3BC62",x"8B8249",x"F2EAC5",x"FFFFE1",x"FFFFE7",x"FFFFEF",x"FFFFF6",x"FDFDFD",x"FEFFFF",x"FFFFFF",x"FFFDFE",x"FFFDFF",x"FFFDF7",x"FFFFE7",x"FFFFE1",x"FFFFE2",x"F7F0C2",x"847E30",x"B5AA3E",x"D9C73F",x"DDC527",x"E1C313",x"DDC422",x"D7C555",x"FFFFAA"),
(x"FFFFF4",x"FFFEC9",x"E9DC5A",x"F0DE34",x"F2E036",x"EEDD38",x"E9DB44",x"E6D956",x"D4C65B",x"837618",x"8B8223",x"857F29",x"928A4C",x"F3EDC9",x"FFFFF6",x"FEFEFF",x"FFFFFF",x"FFFBF8",x"FFFDF6",x"F6EFD2",x"918E4B",x"7F7D26",x"837C24",x"80770E",x"C1BA2C",x"D6CA26",x"DDCB21",x"DDC616",x"E0C611",x"DDC726",x"D4C755",x"FFFFA9"),
(x"FFFFF1",x"FFFFC9",x"E7DD5A",x"EFDF34",x"F0DB32",x"EBD62D",x"EAD830",x"EEDC3E",x"E7D447",x"E2D04A",x"E4D74D",x"DFD454",x"D9CE64",x"88802F",x"B7B17D",x"FFFCD7",x"FFFFDE",x"FFFAD2",x"C5BB88",x"877E31",x"C9C250",x"D5CE49",x"D3C741",x"D6C834",x"D7CC1C",x"DCCD10",x"DDC80D",x"DFC60A",x"E1C80C",x"D6C31F",x"CEC34F",x"FFFFAC"),
(x"FDFFF1",x"FFFFD0",x"E3D95D",x"E8D934",x"ECDA2E",x"EFDB2E",x"EDD82F",x"EBD531",x"EBD333",x"E9D234",x"E5D335",x"DFCF32",x"E2D33C",x"DDD141",x"C8BF3E",x"8E8712",x"817811",x"968B1F",x"BCAF2F",x"DED03C",x"DACF27",x"D9CC1D",x"DAC81E",x"DDC91C",x"DFCA15",x"DBC50D",x"E1C70E",x"E2C90C",x"E0C806",x"D7C519",x"D1C650",x"FFFFA7"),
(x"FCFCF4",x"FFFFD2",x"E4DC60",x"E9DE37",x"E9DD2F",x"EDDD2F",x"EBD92F",x"EED92E",x"ECD628",x"EBD527",x"E7D227",x"E7D628",x"E4D323",x"E0D120",x"DFD126",x"DBCE2A",x"DDCE37",x"DAC931",x"E0CE24",x"DCCA12",x"E1D00E",x"E0CE0A",x"E6CE12",x"E0C60F",x"E0C712",x"DFC70F",x"E1C80C",x"DDC503",x"DEC600",x"D7C316",x"D0C54F",x"FFFFAA"),
(x"FFFCFF",x"FFFDD7",x"DFDA5C",x"E4DE32",x"E4DE30",x"E2DA2D",x"DFD42A",x"E4D729",x"E4D520",x"E9DB22",x"E1D51F",x"DDD11B",x"E6D820",x"E0D01B",x"E4D321",x"E3CF20",x"E2CB1D",x"E4CA1D",x"E3CA18",x"E5CD15",x"E1CD0C",x"DDC908",x"DEC40B",x"E3C612",x"DEC310",x"E0C810",x"DDC606",x"DAC400",x"E1CB06",x"D3BE15",x"D1C24F",x"FFFFAD"),
(x"FFFCFF",x"FFFCE0",x"EAE27D",x"DED94A",x"DCD843",x"E2DC46",x"E0D845",x"E1D640",x"E1D335",x"E0D233",x"DFD535",x"DDD333",x"DCD030",x"E3D335",x"D7C428",x"E0CB30",x"E1C92B",x"E1C929",x"E1C92B",x"DAC625",x"D8C721",x"DAC722",x"E0C72C",x"E0C52C",x"DDC62A",x"D7C420",x"D8C81D",x"D6C619",x"D2C11B",x"D2C036",x"E3D57C",x"FFFFBF"),
(x"FFFCFD",x"FFFFEF",x"FFF9C9",x"ECE094",x"DCD374",x"DDD66C",x"DED26C",x"DFD06B",x"E6D470",x"DDCB65",x"DBD064",x"D7CF60",x"D8CE5F",x"DACE62",x"DFD069",x"DCCA64",x"D9CB62",x"DBCF63",x"D4C85A",x"D4CA5B",x"D5CE5C",x"D7CB5D",x"D3C059",x"D8C35A",x"D6C454",x"CFC34D",x"D1C84F",x"CFC853",x"CEC65B",x"E1D988",x"FCF7CF",x"FFFFED"),
(x"FFFFFB",x"FFFCF1",x"FFFDE8",x"FFFED3",x"FFFFBF",x"FFFFB3",x"FFFFB5",x"FFFFB6",x"FFFFB8",x"FFFFB5",x"FFFFB3",x"FFFFAE",x"FFFFAF",x"FFFFB1",x"FFFFB6",x"FFFFB8",x"FFFFB6",x"FFFFAF",x"FFFFB2",x"FFFFB1",x"FFFFAC",x"FFFFB0",x"FFFFB5",x"FFFFB1",x"FFFFA9",x"FFFFA8",x"FFFFA5",x"FFFFA9",x"FFFFB8",x"FFFFCD",x"FFFFF0",x"FEFFFF"));



constant LUT_SPRITE_PLAYER2 : LUT_SPRITE := ((x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"6B83B2",x"B5C1D8",x"DAE0EC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"E6EAF2",x"A9B7D2",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"A9B7D2",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"8498BF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"F3F5F9",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"6B83B2",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"CED6E5",x"A9B7D2",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"8498BF",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"E6EAF2",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"A9B7D2",x"CED6E5",x"CED6E5",x"CED6E5",x"E6EAF2",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"F3F5F9",x"CED6E5",x"CED6E5",x"CED6E5",x"CED6E5",x"9DADCC",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"CED6E5",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"9DADCC",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"CED6E5",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"90A2C5",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"CED6E5",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"6B83B2",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"CED6E5",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"536FA5",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"5F79AB",x"6B83B2",x"6B83B2",x"6B83B2",x"B5C1D8",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"DAE0EC",x"6B83B2",x"6B83B2",x"6B83B2",x"6B83B2",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"9DADCC",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"FFFFFF",x"CED6E5",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"),
(x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"8498BF",x"CED6E5",x"CED6E5",x"CED6E5",x"CED6E5",x"A9B7D2",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98",x"3A5A98"));

	
	----------------MAP--------------------
	function init_LUT_BG return LUT is 
		variable temp : LUT;
	begin

	for i in 0 to 59 loop
		for j in 0 to 79 loop
			if i < 36 then
				temp(i,j) := "000";	
			else
				if j<35 then
					if(((i+j)mod 2) =0) then
						temp(i,j) := "010";
					else
						temp(i,j) := "100";
					end if;
				elsif(j>44 and j<80)then
					if(((i+j)mod 2) = 0) then
						temp(i,j) := "011";
					else
						temp(i,j) := "101";
					end if;
				else
					temp(i,j) :="000";
				end if;
			end if;
			
			--SPIKES
			if(i=59 and j>34 and j<45) then
				temp(i,j) := "110";
			end if;
				
			--BLACK WALL----
			if(i > 31 and i < 40) then
				if((j>32 and j < 35) or (j>44 and j< 47)) then
					temp(i,j) := "001";
				else
					temp(i,j) := "000";
				end if;
			end if;
		end loop;
	end loop;
	
	return temp;
	
	end function init_LUT_BG;
	------------------------------------------------------
	
	-------------------INIT-TILES------------------------
	
	--BASE1 TILES--------------------------------
	function init_LUT_COLOR1_BASE1 return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				if (i>1 and i<6 and j>1 and j<6) then
					temp(i,j) := x"FF9966";
				else
					temp(i,j) := x"FF6600";
				end if;
			end loop;
		end loop;
		return temp;
	end function init_LUT_COLOR1_BASE1;
		
	function init_LUT_COLOR2_BASE1 return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				if (i>1 and i<6 and j>1 and j<6) then
					temp(i,j) := x"FF6600";
				else
					temp(i,j) := x"FF9966";
				end if;
			end loop;
		end loop;
		return temp;
	end function init_LUT_COLOR2_BASE1;
	--------------------------------------------
	
	--BASE2 TILES--------------------------------
	function init_LUT_COLOR1_BASE2 return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				if (i>1 and i<6 and j>1 and j<6) then
					temp(i,j) := x"00FF99";
				else
					temp(i,j) := x"339966";
				end if;
			end loop;
		end loop;
		return temp;
	end function init_LUT_COLOR1_BASE2;
		
	function init_LUT_COLOR2_BASE2 return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				if (i>1 and i<6 and j>1 and j<6) then
					temp(i,j) := x"339966";
				else
					temp(i,j) := x"00FF99";
				end if;
			end loop;
		end loop;
		return temp;
	end function init_LUT_COLOR2_BASE2;
	--------------------------------------------
	

	
	--WALLS
	function init_LUT_COLOR_BLACK return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				temp(i,j) := x"000000";
			end loop;
		end loop;
		
	return temp;
	end function init_LUT_COLOR_BLACK;
	
	--BG
	function init_LUT_COLOR_BG return LUT_COLOR is
		variable temp : LUT_COLOR;
	begin
		for i in 0 to 7 loop
			for j in 0 to 7 loop
				temp(i,j) := x"99CCFF";
			end loop;
		end loop;
		
	return temp;
	end function init_LUT_COLOR_BG;
	-----------------------------------------------------
	
	constant LUT_SPIKE : LUT_COLOR :=  ((x"99CCFF",x"99CCFF",x"99CCFF",x"6B6B6B",x"6B6B6B",x"99CCFF",x"99CCFF",x"99CCFF"),
													(x"99CCFF",x"99CCFF",x"99CCFF",x"6B6B6B",x"6B6B6B",x"99CCFF",x"99CCFF",x"99CCFF"),
													(x"99CCFF",x"99CCFF",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"99CCFF",x"99CCFF"),
													(x"99CCFF",x"99CCFF",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"99CCFF",x"99CCFF"),
													(x"99CCFF",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"99CCFF"),
													(x"99CCFF",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"99CCFF"),
													(x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B"),
													(x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B",x"6B6B6B"));
	
	
	-----------------------------------------------------
	constant LUT_BG : LUT := init_LUT_BG;

	constant LUT_BACKG : LUT_COLOR:= init_LUT_COLOR_BG;
	constant LUT_BLACK : LUT_COLOR:= init_LUT_COLOR_BLACK;
	
	constant LUT_BASE11 :LUT_COLOR:= init_LUT_COLOR1_BASE1;
	constant LUT_BASE21 :LUT_COLOR:= init_LUT_COLOR2_BASE1;
	
	constant LUT_BASE12 :LUT_COLOR:= init_LUT_COLOR1_BASE2;
	constant LUT_BASE22 :LUT_COLOR:= init_LUT_COLOR2_BASE2;
	
	
	
begin



   GPU: process(XPixelxD, YPixelxD, tileIDxS,XBall1xDI,YBall1xDI,XBall2xDI,YBall2xDI,Ball1xDI,Ball2xDI,arrowAngle1xDI,arrowAngle2xDI,healthPlayer1xDI,healthPlayer2xDI)
   begin
    
	tileIDxS<=LUT_BG(to_integer(YPixelxD(9 downto 3)),to_integer(XPixelxD(9 downto 3)));
	
	if(((to_integer(XPixelxD)-to_integer(unsigned(XPlayer1xDI)))> 0) and ((to_integer(XPixelxD)-to_integer(unsigned(XPlayer1xDI)))< SPRITE_SIZE) and 
	((to_integer(YPixelxD)-288)> 0) and ((to_integer(YPixelxD)-288)< SPRITE_SIZE)) then
		RGBxD <= LUT_SPRITE_PLAYER1(to_integer(YPixelxD)-288,to_integer(XPixelxD)-to_integer(unsigned(XPlayer1xDI)));
		
	elsif(((to_integer(XPixelxD)-to_integer(unsigned(XPlayer2xDI)))> 0) and ((to_integer(XPixelxD)-to_integer(unsigned(XPlayer2xDI)))< SPRITE_SIZE) and 
			((to_integer(YPixelxD)-288)> 0) and ((to_integer(YPixelxD)-288)< SPRITE_SIZE)) then
		RGBxD <= LUT_SPRITE_PLAYER2(to_integer(YPixelxD)-288,to_integer(XPixelxD)-to_integer(unsigned(XPlayer2xDI)));
		

	else
	
		if(tileIDxS = "000") then
			RGBxD <= std_logic_vector(LUT_BACKG(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "001") then
			RGBxD <= std_logic_vector(LUT_BLACK(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "010") then
			RGBxD <= std_logic_vector(LUT_BASE11(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "011") then
			RGBxD <= std_logic_vector(LUT_BASE12(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "100") then
			RGBxD <= std_logic_vector(LUT_BASE21(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "101") then
			RGBxD <= std_logic_vector(LUT_BASE22(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		elsif(tileIDxS = "110") then
			RGBxD <= std_logic_vector(LUT_SPIKE(to_integer(YPixelxD(2 downto 0)), to_integer(XPixelxD(2 downto 0))));
		end if;
	end if;
	
	if(Ball1xDI = '1' and ((to_integer(XPixelxD)-to_integer(unsigned(XBall1xDI)))*(to_integer(XPixelxD)-to_integer(unsigned(XBall1xDI)))
								+(to_integer(YPixelxD)-to_integer(unsigned(YBall1xDI)))*(to_integer(YPixelxD)-to_integer(unsigned(YBall1xDI))))<82) then
		RGBxD <= x"E8A727";
	end if;
	if(Ball2xDI = '1' and ((to_integer(XPixelxD)-to_integer(unsigned(XBall2xDI)))*(to_integer(XPixelxD)-to_integer(unsigned(XBall2xDI)))
								+(to_integer(YPixelxD)-to_integer(unsigned(YBall2xDI)))*(to_integer(YPixelxD)-to_integer(unsigned(YBall2xDI))))<82) then
		RGBxD <= x"7D3FDB";
	end if;
	
	if(((280-to_integer(YPixelxD)) > (to_integer(XPixelxD))*(to_integer(unsigned(arrowAngle1xDI)))-(to_integer(unsigned(XPlayer1xDI)))*(to_integer(unsigned(arrowAngle1xDI))) -32*(to_integer(unsigned(arrowAngle1xDI))) -12-(to_integer(unsigned(arrowAngle1xDI)))) and ((280-to_integer(YPixelxD)) <  (to_integer(XPixelxD))*(to_integer(unsigned(arrowAngle1xDI)))-(to_integer(unsigned(XPlayer1xDI)))*(to_integer(unsigned(arrowAngle1xDI))) -32*(to_integer(unsigned(arrowAngle1xDI))) - 6 +(to_integer(unsigned(arrowAngle1xDI))))  and
    to_integer(XPixelxD) > (to_integer(unsigned(XPlayer1xDI)) + 32-1) and to_integer(YPixelxD) < 290 and
    ((to_integer(XPixelxD)-to_integer(unsigned(XPlayer1xDI))-32)*(to_integer(XPixelxD)-to_integer(unsigned(XPlayer1xDI))-32)+(-to_integer(YPixelxD)+ 312 - 32)*(-to_integer(YPixelxD)+312 - 32))<1000) then
         RGBxD <= x"000000"; 
		end if;
		
		
	if((280-to_integer(YPixelxD)) < ((to_integer(unsigned(XPlayer2xDI)))*(to_integer(unsigned(arrowAngle2xDI)))-(to_integer(XPixelxD))*(to_integer(unsigned(arrowAngle2xDI))) -6 +(to_integer(unsigned(arrowAngle1xDI))) ) and 
		((280-to_integer(YPixelxD)) >  ((to_integer(unsigned(XPlayer2xDI)))*(to_integer(unsigned(arrowAngle2xDI)))-(to_integer(XPixelxD))*(to_integer(unsigned(arrowAngle2xDI))) - 12 -(to_integer(unsigned(arrowAngle1xDI)))))  and
		to_integer(XPixelxD) < (to_integer(unsigned(XPlayer2xDI))  +1) and to_integer(YPixelxD) < 290 and
    ((to_integer(XPixelxD)-to_integer(unsigned(XPlayer2xDI)))*(to_integer(XPixelxD)-to_integer(unsigned(XPlayer2xDI)))+(-to_integer(YPixelxD)+ 312 - 32)*(-to_integer(YPixelxD)+312 - 32))<1000) then
         RGBxD <= x"000000"; 
		end if;
	
	if(to_integer(unsigned(healthPlayer1xDI))/=0) then
		if(to_integer(XPixelxD) > 15 and to_integer(XPixelxD) < 256 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer1xDI))=5) then
			RGBxD <= x"CDAB05";
		end if;

		if(to_integer(XPixelxD) > 15 and to_integer(XPixelxD) < 208 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer1xDI))=4) then
			RGBxD <= x"CDAB05";
		end if;

		if(to_integer(XPixelxD) > 15 and to_integer(XPixelxD) < 160 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer1xDI))=3) then
			RGBxD <= x"CDAB05";
		end if;
		
		if(to_integer(XPixelxD) > 15 and to_integer(XPixelxD) < 112 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer1xDI))=2) then
			RGBxD <= x"CDAB05";
		end if;

		if(to_integer(XPixelxD) > 15 and to_integer(XPixelxD) < 64 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer1xDI))=1) then
			RGBxD <= x"CDAB05";
		end if;
	end if;
	
	if(to_integer(unsigned(healthPlayer2xDI))/=0) then
		if(to_integer(XPixelxD) < SCREEN_WIDTH-15 and to_integer(XPixelxD) > SCREEN_WIDTH-256 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer2xDI))=5) then
			RGBxD<= x"0000CC";
		end if;
			if(to_integer(XPixelxD) < SCREEN_WIDTH-15 and to_integer(XPixelxD) > SCREEN_WIDTH-208 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer2xDI))=4) then
			RGBxD<= x"0000CC";
		end if;
		
		if(to_integer(XPixelxD) < SCREEN_WIDTH-15 and to_integer(XPixelxD) > SCREEN_WIDTH-160 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer2xDI))=3) then
			RGBxD<= x"0000CC";
		end if;
			if(to_integer(XPixelxD) < SCREEN_WIDTH-15 and to_integer(XPixelxD) > SCREEN_WIDTH-112 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer2xDI))=2) then
			RGBxD<= x"0000CC";
		end if;
		
		if(to_integer(XPixelxD) < SCREEN_WIDTH-15 and to_integer(XPixelxD) > SCREEN_WIDTH-64 and to_integer(YPixelxD) > 15 and to_integer(YPixelxD) < 32 and to_integer(unsigned(healthPlayer2xDI))=1) then
			RGBxD<= x"0000CC";
		end if;
	end if;
	
   end process;

   DVI: entity snowball_graphics_v1_00_a.dvi_ctrl(rtl)
      port map(
         -- General System Signals
         ClkxCI         => ClkxCI,
         RstxRBI        => RstxRBI,
         RGBxDI         => RGBxD,
         XPixelxDO      => XPixelxD,
         YPixelxDO      => YPixelxD,
         DVI_ResetxRBO  => DVI_ResetxRBO,
         DVI_XCLKxCO    => DVI_XCLKxCO,    
         DVI_XCLKxCBO   => DVI_XCLKxCBO,
         DVI_DExSO      => DVI_DExSO,
         DVI_VSyncxSO   => DVI_VSyncxSO,
         DVI_HSyncxSO   => DVI_HSyncxSO,
         DVI_DataxDO    => DVI_DataxDO
      );

end rtl;

