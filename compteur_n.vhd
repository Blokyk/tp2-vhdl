library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compteur_N is
    generic(C_NB_BIT_COUNTER : integer;
	        C_MODULO         : integer
    );
    port(clk       : in std_logic;
         rst       : in std_logic;
         enable    : in std_logic;
         max       : out std_logic;
         out_count : out std_logic_vector(C_NB_BIT_COUNTER - 1 downto 0)
    );
end entity;

architecture behavioral of compteur_N is
    signal count_i : unsigned(C_NB_BIT_COUNTER - 1 downto 0);
begin
    out_count <= std_logic_vector(count_i);

    count : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_i <= (others => '0');
                max <= '0';
            elsif enable = '1' then
                -- set max when the value we're about to set will be C_MODULO - 1
                if (count_i + 1) = to_unsigned(C_MODULO - 1, count_i'length) then
                    count_i <= count_i + 1;
                    max <= '1';
                -- when we're actually at max
                elsif count_i = to_unsigned(C_MODULO - 1, count_i'length) then
                    count_i <= (others => '0');
                    max <= '0';
                else
                    count_i <= count_i + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
