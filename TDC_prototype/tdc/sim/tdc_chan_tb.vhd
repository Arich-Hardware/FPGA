--
-- simple testbench for multi-phase TDC front-end with decoder
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_types.all;


entity tdc_chan_tb is
end;

architecture bench of tdc_chan_tb is

  component tdc_chan is
    generic (
      NCHAN : integer);
    port (
      rst      : in  std_logic;
      clk      : in  std_logic_vector(3 downto 0);
      pulse    : in  std_logic;
      trigger  : in  std_logic;
      trig_num : in  unsigned(TDC_TRIG_BITS-1 downto 0);  -- trigger no.
      output   : out tdc_output_rt);
  end component tdc_chan;

  signal clk : std_logic_vector(3 downto 0);  -- 4 phase clock
  signal rst : std_logic;

  signal pulse  : std_logic;
  signal sample : std_logic_vector(6 downto 0);

  signal phase : std_logic_vector(1 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal trigger     : std_logic;
  signal trig_number : unsigned(TDC_TRIG_BITS-1 downto 0) := (others => '0');

  signal output : tdc_output_rt;

begin

  tdc_chan_1 : entity work.tdc_chan

    port map (
      rst      => rst,
      clk      => clk,
      pulse    => pulse,
      trigger  => trigger,
      trig_num => trig_number,
      output   => output);


  stimulus : process
  begin

    -- Put initialisation code here
    rst   <= '1';
    pulse <= '0';
    wait for clock_period*4;
    rst   <= '0';
    wait for clock_period*4;

    for i in 0 to 7 loop
      -- make pulses every 50 ns or so
      pulse <= '1';
      wait for clock_period*(3+i);
      pulse <= '0';
      wait for clock_period*(10-i);

    end loop;  -- i

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
      trigger     <= '1';
      wait for clock_period*2;
      trigger     <= '0';
      wait for clock_period*25;
      trig_number <= trig_number + 1;
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

