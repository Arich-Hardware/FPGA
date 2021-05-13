-- top_tdc_logic_tb.vhd - testbench for top-level TDC logic
--
-- NOTE:  this TB set up for Xilinx simulator only

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.tdc_types.all;
use work.my_textio.all;
use work.tdc_types_textio.all;

entity top_tdc_logic_tb is
end entity top_tdc_logic_tb;

architecture sim of top_tdc_logic_tb is

  component top_tdc_logic is
    port (
      clk100  : in  std_logic;
      reset   : in  std_logic;
      trigger : in  std_logic;
      pulse   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      daq     : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
      valid   : out std_logic);
  end component top_tdc_logic;

  -- TDC clock period
  constant clock_period : time := 4 ns;

  -- Input clock period
  constant clk100_period : time    := 10 ns;
  signal stop_the_clock : boolean := false;

  signal reset_s : std_logic;
  signal trigger_s : std_logic;
  signal pulse_s : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
  signal daq_s : std_logic_vector(DAQ_OUT_BITS-1 downto 0);
  signal valid_s : std_logic;
  signal clk100 : std_logic;

begin  -- architecture sim

  top_tdc_logic_1: entity work.top_tdc_logic
    port map (
      clk100  => clk100,
      reset   => reset_s,
      trigger => trigger_s,
      pulse   => pulse_s,
      daq     => daq_s,
      valid   => valid_s);

  pulse_sim: process

    -- ugh!  what path name should I be using?
--    file file_handler            : text open read_mode is "/home/hazen/work/FPGA/TDC_prototype/Projects/temp/testbench.dat";
    file file_handler            : text open read_mode is "/tmp/testbench.dat";
    variable row                 : line;
    variable bufr                : line;
    variable flag                : character;
    variable stime, ptime, width : real;
    variable chanID              : integer;

  begin

    -- Put initialisation code here
    reset_s     <= '1';
    pulse_s <= (others => '0');
--    rd_ena  <= (others => '0');
    trigger_s <= '0';
    wait for clock_period*4;
    reset_s     <= '0';
    wait for clock_period*4;

    while not endfile(file_handler) loop
      -- Read line from file
      readline(file_handler, row);
      -- Read value from line
      read(row, flag);
      read(row, stime);
      wait for (stime * 1 ns) - now;

      if(flag = 'S') then
        read(row, chanID);
        read(row, width);
        pulse_s(chanID) <= '1';
        pulse_s(chanID) <= transport '0' after (width * 1 ns);
      elsif(flag = 'T') then
        trigger_s <= '1';
        trigger_s <= transport '0' after 8 ns;
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

    file_open(file_out, "/tmp/tdc_daq.txt", write_mode);

    wait for clock_period*8;

    while not stop_the_clock loop

      wait for clock_period;

      if valid_s = '1' then
        write(v_LINE, 'E');
        write(v_LINE, v_SPC);
        write(v_LINE, now);
        write(v_LINE, v_SPC);
        hwrite(v_LINE, daq_s);
        writeline(file_out, v_LINE);
      end if;

    end loop;

    wait;

  end process vec_writer;





  clocking : process
  begin
    wait for clk100_period/2;
    while not stop_the_clock loop
      clk100 <= '1', '0' after clk100_period / 2;
      wait for clk100_period;
    end loop;
    wait;
  end process;





end architecture sim;
