--
-- simple testbench for multi-phase TDC front-end with decoder
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
      trig_num     : in  unsigned(TDC_TRIG_BITS-1 downto 0);  -- trigger no.
      buffer_valid : out std_logic;                           -- valid output
      output       : out tdc_output);
  end component tdc_chan;

  signal clk : std_logic_vector(3 downto 0);  -- 4 phase clock
  signal rst : std_logic;

  signal clk0 : std_logic;              -- for simulation display

  signal pulse  : std_logic;
  signal sample : std_logic_vector(6 downto 0);

  signal phase : std_logic_vector(1 downto 0);

  constant clock_pi     : real := 4.0;
  constant clock_period : time := clock_pi * 1 ns;
  signal stop_the_clock : boolean;

  signal trigger      : std_logic;
  signal trig_number  : unsigned(TDC_TRIG_BITS-1 downto 0) := (others => '0');
  signal buffer_valid : std_logic;

  signal s_output : tdc_output;

-- Declare and Open file in read mode:

begin

  clk0 <= clk(0);

  tdc_chan_1 : entity work.tdc_chan

    port map (
      rst          => rst,
      clk          => clk,
      pulse        => pulse,
      trigger      => trigger,
      trig_num     => trig_number,
      buffer_valid => buffer_valid,
      output       => s_output);

  pulse_sim : process

    file file_handler            : text open read_mode is "test_data_1ms.txt";
    variable row                 : line;
    variable bufr                : line;
    variable flag                : string(1 to 1);
    variable stime, ptime, width : real;
    variable chanID              : integer;

  begin

    -- Put initialisation code here
    rst   <= '1';
    pulse <= '0';
    wait for clock_period*4;
    rst   <= '0';
    wait for clock_period*4;

    -- account for reset time before starting
    ptime := clock_pi * 8.0;

    while not endfile(file_handler) loop
      -- Read line from file
      readline(file_handler, row);
      -- Read value from line
      read(row, flag);
      if(flag = "S") then
        read(row, stime);
        read(row, chanID);
        read(row, width);

--         -- turning on pulse, report output
--         write(bufr, string'("Now: "));
--         write(bufr, now);
--         write(bufr, string'(" Stime: "));
--         write(bufr, stime);
--         write(bufr, string'(" Ptime: "));
--         write(bufr, ptime);
--         write(bufr, string'(" wait for: "));
--         write(bufr, stime-ptime);
--         writeline(output, bufr);

        wait for (stime-ptime) * 1 ns;

--         write(bufr, string'("after wait now: "));
--         write(bufr, now);
--         writeline(output, bufr);

        pulse <= '1';
        wait for width* 1 ns;
        pulse <= '0';
        ptime := stime + width;
      end if;
    end loop;

    wait;

  end process;

  trig_sim : process

    file file_handler     : text open read_mode is "test_data_1ms.txt";
    variable row          : line;
    variable flag         : string(1 to 1);
    variable stime, ptime : real;

  begin

    ptime   := 0.0;
    trigger <= '0';

    while not endfile(file_handler) loop
      -- Read line from file
      readline(file_handler, row);
      -- Read value from line
      read(row, flag);
      if(flag = "T") then
        read(row, stime);
        wait for (stime-ptime)* 1 ns;
        trigger     <= '1';
        trig_number <= trig_number + 1;
        wait for clock_period*2;
        trigger     <= '0';
        ptime       := stime + clock_pi*2.0;
      end if;
    end loop;

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

    file_open(file_out, "tdc_output.txt", write_mode);

    while true loop

      wait until buffer_valid = '1';

      write(v_LINE, now / 1 ns);
      write(v_LINE, v_SPC);
      write(v_LINE, s_output);
      writeline(file_out, v_LINE);
      wait for clock_period;

    end loop;

    wait;

  end process vec_writer;

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

