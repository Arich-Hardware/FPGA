library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tdc_tb is
end entity tdc_tb;

architecture arch of tdc_tb is

  constant T_WIDTH : integer := 4;
  constant W_WIDTH : integer := 3;
  constant PERIOD : time := 10 ns;

  signal clk, rst : std_logic;
  signal start, pulse : std_logic;
  signal dv : std_logic;

  signal tdc_time : std_logic_vector( T_WIDTH-1 downto 0);
  signal tdc_width : std_logic_vector( W_WIDTH-1 downto 0);

begin  -- architecture arch

  tdc_1: entity work.tdc
    generic map (
      T_WIDE => T_WIDTH,
      W_WIDE => W_WIDTH)
    port map (
      clk   => clk,
      rst   => rst,
      start => start,
      pulse => pulse,
      dv    => dv,
      tyme  => tdc_time,
      width => tdc_width);

  clok: process is
  begin  -- process clk
    clk <= '0';
    wait for PERIOD/2;
    clk <= '1';
    wait for PERIOD/2;
  end process clok;

  tb: process is
  begin  -- process tb

    -- input signals to default values, asser reset for 1 clock
    rst <= '1';
    start <= '0';
    pulse <= '0';
    wait for PERIOD;

    rst <= '0';                         --remove reset
    wait for PERIOD*4;

    start <= '1';                       --make a trigger
    wait for PERIOD;
    start <= '0';                       --wait
    wait for PERIOD*5;

    pulse <= '1';                       --make a pulse
    wait for PERIOD*6;
    pulse <= '0';
    wait for PERIOD*10;

    pulse <= '1';                       --make a pulse
    wait for PERIOD*6;
    pulse <= '0';
    wait for PERIOD*10;

    start <= '1';                       --make a trigger
    wait for PERIOD;
    start <= '0';                       --wait
    wait for PERIOD*5;

    pulse <= '1';                       --make a pulse
    wait for PERIOD*6;
    pulse <= '0';
    wait for PERIOD*10;

    pulse <= '1';                       --make a pulse
    wait for PERIOD*6;
    pulse <= '0';
    wait for PERIOD*10;

    

    wait;

  end process tb;

end architecture arch;
