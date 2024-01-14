library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    port ( clk      : in std_logic;
           running  : in std_logic;
           rst_btn  : in std_logic;
           seg      : out std_logic_vector(6 downto 0);
           dp       : out std_logic;
           an       : out std_logic_vector(3 downto 0));
end display;

architecture display_arch of display is

  component hex2led is
    port ( HEX : in std_logic_vector(3 downto 0);
           LED : out std_logic_vector(6 downto 0));
  end component;

  component led_control is
    Port ( CLK : in std_logic;
         DISP0 : in std_logic_vector(6 downto 0);
         DISP1 : in std_logic_vector(6 downto 0);
         DISP2 : in std_logic_vector(6 downto 0);
         DISP3 : in std_logic_vector(6 downto 0);
         AN : out std_logic_vector(3 downto 0);
         DP : out std_logic;
         SEVEN_SEG : out std_logic_vector(6 downto 0));
  end component;

  signal DISP0, DISP1, DISP2, DISP3 : std_logic_vector (6 downto 0);
  signal hex2led_int1, hex2led_int2, hex2led_int3 : std_logic_vector (3 downto 0);
  signal hex2led_int4 : std_logic_vector (3 downto 0);
  signal seconds, minutes : std_logic_vector(7 downto 0);

begin

    seconds_separator : entity work.digit_separator(behavioral)
        port map(
                value => seconds,
                ones => hex2led_int1,
                tens => hex2led_int2
        );
    minutes_separator : entity work.digit_separator(behavioral)
        port map(
                value => minutes,
                ones => hex2led_int3,
                tens => hex2led_int4
        );

  chrono : entity work.chrono(behavioral)
        port map(
            clk => clk,
            rst => rst_btn,
            start => running,
            seconds => seconds,
            minutes => minutes
        );

  HEX2LED_1 : hex2led port map (
    HEX => hex2led_int1,
    LED => DISP0);

  HEX2LED_2 : hex2led port map (
    HEX => hex2led_int2,
    LED => DISP1);

  HEX2LED_3 : hex2led port map (
    HEX => hex2led_int3,
    LED => DISP2);

  HEX2LED_4 : hex2led port map (
    HEX => hex2led_int4,
    LED => DISP3);

   LEDCONTROL_1 : led_control port map (
    CLK => clk,
    DISP0 => DISP0,
    DISP1 => DISP1,
    DISP2 => DISP2,
    DISP3 => DISP3,
    AN => AN,
    SEVEN_SEG => seg,
    dp => dp);

end display_arch;
