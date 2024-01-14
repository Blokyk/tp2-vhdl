library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity digit_separator is
    port(value : in STD_LOGIC_VECTOR (7 downto 0);
         ones  : out STD_LOGIC_VECTOR (3 downto 0);
         tens  : out STD_LOGIC_VECTOR (3 downto 0));
end digit_separator;

architecture behavioral of digit_separator is
    signal tens_i : std_logic_vector(7 downto 0);
    signal ones_i : std_logic_vector(7 downto 0);
begin
    ones_i <= std_logic_vector(unsigned(value) mod 10);
    tens_i <= std_logic_vector(unsigned(value) / 10);

    ones <= ones_i(3 downto 0);
    tens <= tens_i(3 downto 0);
end behavioral;