-- event_builder2_tb.vhd - testbench for event builder
--
-- initial version with actual event builder


library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.tdc_types.all;
use work.my_textio.all;
use work.tdc_types_textio.all;

entity event_builder2_tb is
end entity event_builder2_tb;

architecture sim of event_builder2_tb is

  component event_builder is
    port (
      clk             : in  std_logic;
      rst             : in  std_logic;
      trig_hit_in     : in  trigger_tdc_hit;
      trig_empty      : in  std_logic;
      trig_rd_ena     : out std_logic;
      tdc_data        : in  tdc_output_array;
      tdc_empty       : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      tdc_full        : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      rd_ena          : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      trig_num        : out unsigned(TDC_TRIG_BITS-1 downto 0);
      trig_data_out   : out trigger_tdc_hit;
      trig_data_valid : out std_logic;
      tdc_data_out    : out tdc_output;
      tdc_data_valid  : out std_logic);
  end component event_builder;


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

  component trigger_tdc_with_fifo is
    port (
      clk         : in  std_logic_vector(3 downto 0);
      rst         : in  std_logic;
      trigger     : in  std_logic;
      empty, full : out std_logic;
      output      : out trigger_tdc_hit;
      rd_ena      : in  std_logic);
  end component trigger_tdc_with_fifo;

  signal clk     : std_logic_vector(3 downto 0);
  signal rst     : std_logic;
  signal trigger : std_logic;

  signal empty, full, rd_ena : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
  signal s_pulse             : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);

  constant clock_period : time    := 4 ns;
  signal stop_the_clock : boolean := false;

  signal data_out   : std_logic_vector(DAQ_OUT_BITS-1 downto 0);
  signal data_valid : std_logic;

  signal rd_data : tdc_output_array;

  signal trig_out              : trigger_tdc_hit;
  signal trig_empty, trig_full : std_logic;
  signal trig_rd_ena           : std_logic;

  signal trig_num : unsigned(TDC_TRIG_BITS-1 downto 0);

  signal trig_data_out_s   : trigger_tdc_hit;
  signal trig_data_valid : std_logic;
  signal tdc_data_out_s    : tdc_output;
  signal tdc_data_valid  : std_logic;

begin  -- architecture sim

  event_builder_1 : entity work.event_builder
    port map (
      clk         => clk(0),
      rst         => rst,
      trig_hit_in => trig_out,
      trig_empty  => trig_empty,
      trig_rd_ena => trig_rd_ena,
      tdc_data    => rd_data,
      tdc_empty   => empty,
      tdc_full    => full,
      rd_ena      => rd_ena,
      trig_num    => trig_num,
--      data_out    => data_out,
--      data_valid  => data_valid);

      trig_data_out   => trig_data_out_s,
      trig_data_valid => trig_data_valid,
      tdc_data_out    => tdc_data_out_s,
      tdc_data_valid  => tdc_data_valid);

  tdc_multi_chan_1 : entity work.tdc_multi_chan
    port map (
      clk      => clk,
      rst      => rst,
      trigger  => trigger,
      trig_num => trig_out.trig_event(TDC_TRIG_BITS-1 downto 0),
      pulse    => s_pulse,
      rd_data  => rd_data,
      empty    => empty,
      full     => full,
      rd_ena   => rd_ena);

  trigger_tdc_with_fifo_1 : entity work.trigger_tdc_with_fifo
    port map (
      clk     => clk,
      rst     => rst,
      trigger => trigger,
      empty   => trig_empty,
      full    => trig_full,
      output  => trig_out,
      rd_ena  => trig_rd_ena);

  pulse_sim : process

    file file_handler            : text open read_mode is "random_data/testbench.dat";
    variable row                 : line;
    variable bufr                : line;
    variable flag                : character;
    variable stime, ptime, width : real;
    variable chanID              : integer;

  begin

    -- Put initialisation code here
    rst     <= '1';
    s_pulse <= (others => '0');
--    rd_ena  <= (others => '0');
    trigger <= '0';
    wait for clock_period*4;
    rst     <= '0';
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
        s_pulse(chanID) <= '1';
        s_pulse(chanID) <= transport '0' after (width * 1 ns);
      elsif(flag = 'T') then
        trigger <= '1';
        trigger <= transport '0' after 8 ns;
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
--    rd_ena      <= (others => '0');
--    trig_rd_ena <= '0';

    -- wait for reset
    wait for clock_period*8;

--    while not stop_the_clock loop

    while not stop_the_clock loop

      wait for clock_period;

      if trig_data_valid = '1' then
        write(v_LINE, 'T');
        write(v_LINE, v_SPC);
        write(v_LINE, now / 1 ns);
        write(v_LINE, v_SPC);
        write(v_LINE, trig_data_out_s);
        writeline(file_out, v_LINE);
      end if;

      if tdc_data_valid = '1' then
        write(v_LINE, 'S');
        write(v_LINE, v_SPC);
        write(v_LINE, now / 1 ns);
        write(v_LINE, v_SPC);
        write(v_LINE, tdc_data_out_s);
        writeline(file_out, v_LINE);
      end if;

    end loop;

    wait;

  end process vec_writer;




  g_multiphase : for i in 0 to 3 generate
    clocking : process
    begin
      wait for clock_period/4*i;
      while not stop_the_clock loop
        clk(i) <= '1', '0' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;
  end generate g_multiphase;





end architecture sim;
