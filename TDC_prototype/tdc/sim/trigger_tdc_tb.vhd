--
-- simple testbench for multi-phase trigger TDC
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;
use work.tdc_types.all;
use work.my_textio.all;
use work.tdc_types_textio.all;

entity trigger_tdc_tb is
end entity trigger_tdc_tb;

architecture bench of trigger_tdc_tb is

  component trigger_tdc is
    port (
      clk          : in  std_logic_vector(3 downto 0);
      rst          : in  std_logic;
      trigger      : in  std_logic;
      output       : out trigger_tdc_hit;
      output_valid : out std_logic);
  end component trigger_tdc;

  signal clk : std_logic_vector(3 downto 0);  -- 4 phase clock
  signal rst : std_logic;

  signal pulse  : std_logic;
  signal sample : std_logic_vector(6 downto 0);

  signal phase : std_logic_vector(1 downto 0);

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean;

  signal trigger     : std_logic;

  signal output       : trigger_tdc_hit;
  signal buffer_valid : std_logic;

begin

  trigger_tdc_1: entity work.trigger_tdc
    port map (
      clk          => clk,
      rst          => rst,
      trigger      => trigger,
      output       => output,
      output_valid => buffer_valid);


  stimulus : process
  begin

    -- Put initialisation code here
    rst   <= '1';
    pulse <= '0';
    wait for clock_period*4;
    rst   <= '0';
    wait for clock_period*4;


    wait;

  end process;




  vec_writer : process is

    variable v_LINE : line;              -- line buffer
    variable v_SPC  : character := ' ';  -- for space parsing
    variable buff   : line;              -- for debug output
    variable temp   : integer;
    file file_out   : text;              -- file handle
    variable v_tyme : integer;

  begin

    file_open(file_out, "trigger_tdc_hit.txt", write_mode);

    while true loop

      wait until buffer_valid = '1';

      write(v_LINE, now / 1 ns);
      write(v_LINE, v_SPC);
      write(v_LINE, output);
      writeline(file_out, v_LINE);
      wait for clock_period;

    end loop;

    wait;

  end process vec_writer;



  -- generate (delayed) triggers at 100ns, 210ns, 320ns etc
  trig : process
  begin
    trigger <= '0';
    while true loop
      wait for clock_period*5;
      trigger     <= '1';
      wait for clock_period*2;
      trigger     <= '0';
      wait for clock_period*5;
      wait for 1 ns;
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

