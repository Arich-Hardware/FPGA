--
-- simple testbench for multi-phase TDC front-end with decoder
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity multi_tb is
end;

architecture bench of multi_tb is

  component multi_sample is
    port (
      clk   : in  std_logic_vector(3 downto 0);
      pulse : in  std_logic;
      outp  : out std_logic_vector(6 downto 0);
      edge_d  : out std_logic);
  end component multi_sample;

  component decode is
    port (
      code                          : in  std_logic_vector(6 downto 0);
      rise, fall, high, low, glitch : out std_logic;
      phase                         : out std_logic_vector(1 downto 0));
  end component decode;

  signal clk   : std_logic_vector(3 downto 0); -- 4 phase clock
  signal pulse : std_logic;
  signal sample  : std_logic_vector(6 downto 0);

  signal rise, fall, high, low, glitch : std_logic;
  signal phase : std_logic_vector(1 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal result : integer := 0;

begin

  multi_sample_1 : entity work.multi_sample
    port map (
      clk   => clk,
      pulse => pulse,
      outp  => sample);

  decode_2: entity work.decode
    port map (
      code   => sample,
      rise   => rise,
      fall   => fall,
      high   => high,
      low    => low,
      glitch => glitch,
      phase  => phase);

  stimulus : process
  begin

    -- Put initialisation code here
    pulse <= '0';
    wait for 4 ns;

    -- walk a pulse by 0.5ns ticks
    for i in 0 to 10 loop
      pulse <= '1';
      wait for 20 ns;
      pulse <= '0';
      wait for 20 ns;
      wait for 0.5 ns;
    end loop;  -- i

    wait for 20 ns;
    stop_the_clock <= true;
    wait;
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

