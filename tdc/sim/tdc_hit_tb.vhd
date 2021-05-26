--
-- simple testbench for multi-phase TDC front-end with decoder and FIFO
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_types.all;

entity tdc_hit_tb is
end entity tdc_hit_tb;

architecture sim of tdc_hit_tb is

  component tdc_hit is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      rise     : in  std_logic;
      fall     : in  std_logic;
      phase    : in  std_logic_vector(TDC_PHASE_BITS-1 downto 0);  -- measured phase for rise/fall
      del_trig : in  std_logic;
      readme   : out std_logic;
      hit      : out tdc_hit_data);
  end component tdc_hit;

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal rise, fall : std_logic;
  signal del_trig   : std_logic;
  signal readme     : std_logic;

  signal hit : tdc_hit_data;

  signal phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);  -- measured phase for rise/fall

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

begin  -- architecture sim

  tdc_hit_1 : entity work.tdc_hit
    port map (
      clk      => clk,
      rst      => rst,
      rise     => rise,
      phase    => phase,
      fall     => fall,
      del_trig => del_trig,
      readme   => readme,
      hit      => hit);


  stimulus : process
  begin

    -- Put initialisation code here
    rise     <= '0';
    fall     <= '0';
    del_trig <= '0';
    phase    <= "11";

    rst <= '1';
    wait for clock_period*4;
    rst <= '0';
    wait for clock_period*4;

    rise <= '1';
    wait for clock_period;
    rise <= '0';
    wait for clock_period;

    wait for clock_period*10;
    fall <= '1';
    wait for clock_period;
    fall <= '0';
    wait for clock_period;

    wait for clock_period*3;
    del_trig <= '1';
    wait for clock_period;
    del_trig <= '0';

    wait for clock_period*30;

    phase <= "01";
    
    rise <= '1';
    wait for clock_period;
    rise <= '0';
    wait for clock_period;

    phase <= "10";

    wait for clock_period*8;
    fall <= '1';
    wait for clock_period;
    fall <= '0';
    wait for clock_period;



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
