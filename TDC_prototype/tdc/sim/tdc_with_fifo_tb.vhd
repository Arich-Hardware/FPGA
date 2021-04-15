--
-- simple testbench for multi-phase TDC front-end with decoder and FIFO
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

  component tdc_with_fifo is
    port (
      clk      : in  std_logic_vector(3 downto 0);
      rst      : in  std_logic;
      trigger  : in  std_logic;
      pulse    : in  std_logic;
      trig_num : in  unsigned(TDC_TRIG_BITS-1 downto 0);
      empty    : out std_logic;
      full     : out std_logic;
      rd_data  : out std_logic_vector(35 downto 0);
      rd_ena   : in  std_logic);
  end component tdc_with_fifo;

  signal clk                 : std_logic_vector(3 downto 0);
  signal trigger, pulse      : std_logic;
  signal empty, full, rd_ena : std_logic;
  signal fifo_out_rec        : tdc_output;
  signal fifo_out_data       : std_logic_vector(35 downto 0);
  signal rst                 : std_logic;

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal trig_num : unsigned(TDC_TRIG_BITS-1 downto 0);

begin  -- architecture sim

  tdc_with_fifo_1 : entity work.tdc_with_fifo
    port map (
      clk      => clk,
      rst      => rst,
      trigger  => trigger,
      pulse    => pulse,
      trig_num => trig_num,
      empty    => empty,
      full     => full,
      rd_data  => fifo_out_data,
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
