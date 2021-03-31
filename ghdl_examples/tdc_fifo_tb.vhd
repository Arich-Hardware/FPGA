library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_pkg.all;

entity tdc_fifo_tb is
end entity tdc_fifo_tb;

architecture bench of tdc_fifo_tb is

  component tdc_fifo is
    generic (
      FIFO_DEPTH : integer);
    port (
      clk          : in  std_logic_vector(3 downto 0);
      rst          : in  std_logic;
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      buffer_group : out tdc_buffer_group_t;
      rd_enable    : in  std_logic;
      empty        : out std_logic;
      full         : out std_logic);
  end component tdc_fifo;

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal rst, pulse        : std_logic;
  signal rd_enable, empty, full : std_logic;
  signal trigger                : std_logic;
  signal clk : std_logic_vector(3 downto 0);

  signal dout : tdc_buffer_group_t;

begin  -- architecture bench

  tdc_fifo_1 : entity work.tdc_fifo
    generic map (
      FIFO_DEPTH => 128)
    port map (
      clk          => clk,
      rst          => rst,
      pulse        => pulse,
      trigger      => trigger,
      buffer_group => dout,
      rd_enable    => rd_enable,
      empty        => empty,
      full         => full);


  stimulus : process
  begin

    -- Put initialisation code here
    rst     <= '1';
    pulse   <= '0';

    wait for 4 ns;
    rst     <= '0';
    wait for 4 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;

    pulse <= '1';
    wait for 10 ns;
    pulse <= '0';
    wait for 21 ns;


    wait;

  end process;
  


  -- generate triggers every 110 ns
  trig : process
  begin
    trigger <= '0';
    while true loop
      wait for 100 ns;
      trigger <= '1';
      wait for 10 ns;
      trigger <= '0';
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



end architecture bench;
