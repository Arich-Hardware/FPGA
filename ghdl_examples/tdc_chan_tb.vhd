--
-- simple testbench for multi-phase TDC front-end with decoder
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_pkg.all;


entity tdc_chan_tb is
end;

architecture bench of tdc_chan_tb is

  component tdc_chan is
    generic (
      NCHAN : integer);
    port (
      rst          : in  std_logic;
      clk          : in  std_logic_vector(3 downto 0);
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      buffer_group : out tdc_buffer_group_t);
  end component tdc_chan;

  signal clk : std_logic_vector(3 downto 0);  -- 4 phase clock
  signal rst : std_logic;

  signal pulse  : std_logic;
  signal sample : std_logic_vector(6 downto 0);

  signal rise, fall, high, low, glitch : std_logic;
  signal phase                         : std_logic_vector(1 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal trigger : std_logic;

  signal buffers : tdc_buffer_group_t;

begin

  tdc_chan_1 : entity work.tdc_chan

    port map (
      rst          => rst,
      clk          => clk,
      pulse        => pulse,
      trigger      => trigger,
      buffer_group => buffers);


  stimulus : process
  begin

    -- Put initialisation code here
    rst     <= '1';
    pulse   <= '0';
--    trigger <= '0';
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

end;

