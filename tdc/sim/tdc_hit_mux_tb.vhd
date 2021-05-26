
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity tdc_hit_mux_tb is
end entity tdc_hit_mux_tb;

architecture sim of tdc_hit_mux_tb is

  component tdc_hit_mux is
    port (
      rst     : in  std_logic;
      clk     : in  std_logic;
      rise    : in  std_logic;
      fall    : in  std_logic;
      phase   : in  std_logic_vector(TDC_PHASE_BITS-1 downto 0);
      m_rise  : out std_logic_vector(NUM_TDC_BUFFERS-1 downto 0);
      m_fall  : out std_logic_vector(NUM_TDC_BUFFERS-1 downto 0);
      m_phase : out std_logic_vector(TDC_PHASE_BITS-1 downto 0));
  end component tdc_hit_mux;

  signal rst, clk, rise, fall : std_logic;
  signal phase, m_phase       : std_logic_vector(TDC_PHASE_BITS-1 downto 0);
  signal m_rise, m_fall       : std_logic_vector(NUM_TDC_BUFFERS-1 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

begin  -- architecture sim

  tdc_hit_mux_1 : entity work.tdc_hit_mux
    port map (
      rst     => rst,
      clk     => clk,
      rise    => rise,
      fall    => fall,
      phase   => phase,
      m_rise  => m_rise,
      m_fall  => m_fall,
      m_phase => m_phase);

  stimulus : process
  begin

    rst   <= '1';
    rise  <= '0';
    fall  <= '0';
    phase <= "01";

    wait for clock_period*2;
    rst <= '0';

    for i in 0 to 5 loop

      phase <= phase(0) & phase(1);

      wait for clock_period*5;
      rise <= '1';
      wait for clock_period;
      rise <= '0';

      wait for clock_period*5;
      fall <= '1';
      wait for clock_period;
      fall <= '0';

      wait for clock_period*5;

    end loop;  -- i

    wait;

  end process;


  g_clk : process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
  end process;

end architecture sim;
