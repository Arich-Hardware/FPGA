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
      clk     : in  std_logic_vector(3 downto 0);
      trigger : in  std_logic;
      pulse   : in  std_logic;
      empty   : out std_logic;
      full    : out std_logic;
      rd_data : out std_logic_vector(31 downto 0);
      rd_ena  : out std_logic);
  end component tdc_with_fifo;

  signal clk                 : std_logic_vector(3 downto 0);
  signal trigger, pulse      : std_logic;
  signal empty, full, rd_ena : std_logic;
  signal data : std_logic_vector(31 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

begin  -- architecture sim

  tdc_with_fifo_1 : entity work.tdc_with_fifo
    port map (
      clk     => clk,
      trigger => trigger,
      pulse   => pulse,
      empty   => empty,
      full    => full,
      data => rd_data,
      rd_ena  => rd_ena);



  stimulus : process
  begin

    -- Put initialisation code here
    rst   <= '1';
    pulse <= '0';
    wait for clock_period;
    rst   <= '0';
    wait for clock_period;

    -- now at 8ns
    -- pulse within trigger
    wait for 1.5 ns;
    wait for clock_period*5;
    pulse <= '1';
    wait for clock_period*10;
    pulse <= '0';


    -- now at 17 clocks
    -- pulse after trigger
    wait for clock_period*10;
    pulse <= '1';
    wait for clock_period*10;
    pulse <= '0';


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
