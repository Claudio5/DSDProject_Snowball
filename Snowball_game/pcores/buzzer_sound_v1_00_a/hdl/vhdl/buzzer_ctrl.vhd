library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

entity buzzer_ctrl is
  port(
    ResetxRB : in std_logic;
    ClockxCI  : in std_logic;
    BuzzerEnxDI : in std_logic;
    BuzzerCounterxDI : in std_logic_vector(31 downto 0);
    BuzzerSoundxDO  : out std_logic
  );
end entity buzzer_ctrl;

architecture RTL of buzzer_ctrl is

signal buzzerCount_reg, buzzerCount_next : unsigned(31 downto 0);
signal buzzerSpeaker_reg, buzzerSpeaker_next : std_logic;

begin
  REG : process(ClockxCI,ResetxRB) is
  begin
    if(ResetxRB = '1') then
      buzzerCount_reg <= (others => '0');
      buzzerSpeaker_reg <= '0';
    elsif rising_edge(ClockxCI) then
      buzzerCount_reg <= buzzerCount_next;
      buzzerSpeaker_reg <= buzzerSpeaker_next;
    end if;
  end process REG;

  SOUND : process(buzzerCount_reg, BuzzerEnxDI, BuzzerCounterxDI) is
  begin
    if BuzzerEnxDI = '1' then
      if buzzerCount_reg >= unsigned(BuzzerCounterxDI) then
        buzzerSpeaker_next <= not buzzerSpeaker_reg;
        buzzerCount_next <= (others => '0');
      else
        buzzerCount_next <= buzzerCount_reg + 1;
        buzzerSpeaker_next <= buzzerSpeaker_reg;
      end if;
    else
      buzzerCount_next <= buzzerCount_reg;
      buzzerSpeaker_next <= buzzerSpeaker_reg;
    end if;
  end process SOUND;

  BuzzerSoundxDO <= buzzerSpeaker_reg;

end architecture RTL;
