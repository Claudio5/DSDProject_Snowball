-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    fpga_0_RS232_Uart_1_RX_pin : in std_logic;
    fpga_0_RS232_Uart_1_TX_pin : out std_logic;
    fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    fpga_0_Push_Buttons_5Bit_GPIO_IO_pin : inout std_logic_vector(0 to 4);
    fpga_0_DIP_Switches_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    fpga_0_clk_1_sys_clk_pin : in std_logic;
    fpga_0_rst_1_sys_rst_pin : in std_logic;
    fit_timer_0_Interrupt_pin : out std_logic;
    dvi_iic_init_0_iic_sda_pin : inout std_logic;
    dvi_iic_init_0_iic_scl_pin : inout std_logic;
    snowball_graphics_0_DVI_ResetxRBO_pin : out std_logic;
    snowball_graphics_0_DVI_XCLKxCO_pin : out std_logic;
    snowball_graphics_0_DVI_XCLKxCBO_pin : out std_logic;
    snowball_graphics_0_DVI_DExSO_pin : out std_logic;
    snowball_graphics_0_DVI_VSyncxSO_pin : out std_logic;
    snowball_graphics_0_DVI_HSyncxSO_pin : out std_logic;
    snowball_graphics_0_DVI_DataxDO_pin : out std_logic_vector(11 downto 0);
    ps2_keyboard_0_PS2_ClockxDI_pin : in std_logic;
    ps2_keyboard_0_PS2_DataxDI_pin : in std_logic;
    buzzer_sound_0_BuzzerSoundxDO_pin : out std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      fpga_0_RS232_Uart_1_RX_pin : in std_logic;
      fpga_0_RS232_Uart_1_TX_pin : out std_logic;
      fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
      fpga_0_Push_Buttons_5Bit_GPIO_IO_pin : inout std_logic_vector(0 to 4);
      fpga_0_DIP_Switches_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
      fpga_0_clk_1_sys_clk_pin : in std_logic;
      fpga_0_rst_1_sys_rst_pin : in std_logic;
      fit_timer_0_Interrupt_pin : out std_logic;
      dvi_iic_init_0_iic_sda_pin : inout std_logic;
      dvi_iic_init_0_iic_scl_pin : inout std_logic;
      snowball_graphics_0_DVI_ResetxRBO_pin : out std_logic;
      snowball_graphics_0_DVI_XCLKxCO_pin : out std_logic;
      snowball_graphics_0_DVI_XCLKxCBO_pin : out std_logic;
      snowball_graphics_0_DVI_DExSO_pin : out std_logic;
      snowball_graphics_0_DVI_VSyncxSO_pin : out std_logic;
      snowball_graphics_0_DVI_HSyncxSO_pin : out std_logic;
      snowball_graphics_0_DVI_DataxDO_pin : out std_logic_vector(11 downto 0);
      ps2_keyboard_0_PS2_ClockxDI_pin : in std_logic;
      ps2_keyboard_0_PS2_DataxDI_pin : in std_logic;
      buzzer_sound_0_BuzzerSoundxDO_pin : out std_logic
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      fpga_0_RS232_Uart_1_RX_pin => fpga_0_RS232_Uart_1_RX_pin,
      fpga_0_RS232_Uart_1_TX_pin => fpga_0_RS232_Uart_1_TX_pin,
      fpga_0_LEDs_8Bit_GPIO_IO_pin => fpga_0_LEDs_8Bit_GPIO_IO_pin,
      fpga_0_Push_Buttons_5Bit_GPIO_IO_pin => fpga_0_Push_Buttons_5Bit_GPIO_IO_pin,
      fpga_0_DIP_Switches_8Bit_GPIO_IO_pin => fpga_0_DIP_Switches_8Bit_GPIO_IO_pin,
      fpga_0_clk_1_sys_clk_pin => fpga_0_clk_1_sys_clk_pin,
      fpga_0_rst_1_sys_rst_pin => fpga_0_rst_1_sys_rst_pin,
      fit_timer_0_Interrupt_pin => fit_timer_0_Interrupt_pin,
      dvi_iic_init_0_iic_sda_pin => dvi_iic_init_0_iic_sda_pin,
      dvi_iic_init_0_iic_scl_pin => dvi_iic_init_0_iic_scl_pin,
      snowball_graphics_0_DVI_ResetxRBO_pin => snowball_graphics_0_DVI_ResetxRBO_pin,
      snowball_graphics_0_DVI_XCLKxCO_pin => snowball_graphics_0_DVI_XCLKxCO_pin,
      snowball_graphics_0_DVI_XCLKxCBO_pin => snowball_graphics_0_DVI_XCLKxCBO_pin,
      snowball_graphics_0_DVI_DExSO_pin => snowball_graphics_0_DVI_DExSO_pin,
      snowball_graphics_0_DVI_VSyncxSO_pin => snowball_graphics_0_DVI_VSyncxSO_pin,
      snowball_graphics_0_DVI_HSyncxSO_pin => snowball_graphics_0_DVI_HSyncxSO_pin,
      snowball_graphics_0_DVI_DataxDO_pin => snowball_graphics_0_DVI_DataxDO_pin,
      ps2_keyboard_0_PS2_ClockxDI_pin => ps2_keyboard_0_PS2_ClockxDI_pin,
      ps2_keyboard_0_PS2_DataxDI_pin => ps2_keyboard_0_PS2_DataxDI_pin,
      buzzer_sound_0_BuzzerSoundxDO_pin => buzzer_sound_0_BuzzerSoundxDO_pin
    );

end architecture STRUCTURE;

