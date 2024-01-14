library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity chrono is
    port (clk     : in std_logic;
          rst     : in std_logic;
          start   : in std_logic;
          seconds : out std_logic_vector(7 downto 0);
          minutes : out std_logic_vector(7 downto 0)
    );
end chrono;

architecture behavioral of chrono is
    signal clk_max    : std_logic;
    signal sec_max    : std_logic;
    signal min_enable : std_logic;
    signal sec_i      : std_logic_vector(7 downto 0);
begin
    seconds <= sec_i;

    clk_to_sec : entity work.compteur_N(behavioral)
            generic map(C_NB_BIT_COUNTER => 27,
			            C_MODULO => 100000000)
            port map(clk       => clk,
                     rst       => rst,
                     enable    => start,
                     max       => clk_max,
                     out_count => open);
    sec_to_min : entity work.compteur_N(behavioral)
            generic map(C_NB_BIT_COUNTER => 8,
			            C_MODULO => 60)
            port map(clk       => clk,
                     rst       => rst,
                     enable    => clk_max,
                     max       => sec_max,
                     out_count => sec_i);

    -- since sec_max won't be updated until the next clk_max,
    -- if we just enable on sec_max, while being updated by the
    -- global clock, we'd update on every clk until sec_max is set
    -- back to 0
    -- by using `clk_max and sec_max`, we make sure that it'll be
    -- updated only on the rising edge of sec_max (no, we can't
    -- just use rising_edge)
    min_enable <= clk_max and sec_max;
    min_counter : entity work.compteur_N(behavioral)
        generic map(C_NB_BIT_COUNTER => 8,
                    C_MODULO => 60)
            port map(clk       => clk,
                     rst       => rst,
                     enable    => min_enable,
                     max       => open,
                     out_count => minutes);
end behavioral;
