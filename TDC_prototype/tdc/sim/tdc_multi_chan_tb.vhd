--
-- tdc_multi_chan_tb.vhd:  multi-channel TDC testbench
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_types.all;

entity tdc_with_fifo_tb is
end entity tdc_with_fifo_tb;

architecture sim of tdc_with_fifo_tb is

  component tdc_multi_chan is
    generic (
      NUM_CHAN : integer);
    port (
      clk      : in  std_logic_vector(3 downto 0);
      rst      : in  std_logic;
      trigger  : in  std_logic;
      trig_num : in  unsigned(TDC_TRIG_BITS-1 downto 0);
      pulse    : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      rd_data  : out tdc_output_array;
      empty    : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      full     : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      rd_ena   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0));
  end component tdc_multi_chan;

  signal clk                 : std_logic_vector(3 downto 0);
  signal rst                 : std_logic;
  signal trigger, pulse      : std_logic;
  signal empty, full, rd_ena : std_logic;

  signal fifo_out_rec        : tdc_output;

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal trig_num : unsigned(TDC_TRIG_BITS-1 downto 0);

begin  -- architecture sim

  tdc_multi_chan_1: entity work.tdc_multi_chan
    port map (
      clk      => clk,
      rst      => rst,
      trigger  => trigger,
      trig_num => trig_num,
      pulse    => pulse,
      rd_data  => rd_data,
      empty    => empty,
      full     => full,
      rd_ena   => rd_ena);

  stimulus : process
  begin

    -- Put initialisation code here
    rst    <= '1';
    pulse  <= '0';
    rd_ena <= '0';
    wait for clock_period;
    rst    <= '0';
    wait for clock_period;

    -- now at 8ns
    -- two pulses within trigger
    wait for 1.5 ns;
    wait for clock_period*5;
    pulse <= '1';
    wait for clock_period*3;
    pulse <= '0';

    wait for 1.5 ns;
    wait for clock_period*7;
    pulse <= '1';
    wait for clock_period*3;
    pulse <= '0';

    -- now at 17 clocks
    -- pulse after trigger
    wait for clock_period*5;
    pulse <= '1';
    wait for clock_period*10;
    pulse <= '0';

    wait for clock_period*30;
    rd_ena <= '1';
    wait for clock_period;
    rd_ena <= '0';

    wait for clock_period*2;
    rd_ena <= '1';
    wait for clock_period;
    rd_ena <= '0';



    wait;

  end process;

  -- generate (delayed) triggers at 100ns, 210ns, 320ns etc
  trig : process
  begin
    trigger <= '0';
    while true loop
      wait for clock_period*25;
      trigger <= '1';
      wait for clock_period*2;
      trigger <= '0';
      wait for clock_period*25;
    end loop;
  end process;

  g_multiphase : for i in 0 to 3 generate
    clocking : process
    begin
      wait for clock_period/4*i;
      while not stop_the_clock loop
        clk(i) <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;
  end generate g_multiphase;





end architecture sim;
