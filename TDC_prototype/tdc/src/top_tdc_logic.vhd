-- top_tdc_logic.vhd -- top-level logic for TDC
--
-- Instantiated in top_tdc to wire up signals to e.g. Baysys3 board for now


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.tdc_types.all;

entity top_tdc_logic is

  port (
    clk100  : in  std_logic;            -- 100MHz board clock
    reset   : in  std_logic;            -- BtnC for now
    trigger : in  std_logic;            -- readout trigger
    pulse   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- SiPM pulse
    daq     : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
    valid   : out std_logic);           -- output strobe


end entity top_tdc_logic;


architecture arch of top_tdc_logic is

  component clock250x4 is
    port (
      clk0      : out std_logic;
      clk1      : out std_logic;
      clk2      : out std_logic;
      clk3      : out std_logic;
      clkout100 : out std_logic;
      reset     : in  std_logic;
      locked    : out std_logic;
      clk_in1   : in  std_logic);
  end component clock250x4;

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

  component event_formatter is
    port (
      clk             : in  std_logic;
      rst             : in  std_logic;
      trig_data_in    : in  trigger_tdc_hit;
      trig_data_valid : in  std_logic;
      tdc_data_in     : in  tdc_output;
      tdc_data_valid  : in  std_logic;
      daq_out         : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
      daq_valid       : out std_logic);
  end component event_formatter;

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

  signal clk       : std_logic_vector(3 downto 0);
  signal clk_sys   : std_logic;
  signal rst       : std_logic;
  signal trigger_s : std_logic;

  signal empty, full, rd_ena : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
  signal s_pulse             : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);

  signal rd_data : tdc_output_array;

  signal trig_out              : trigger_tdc_hit;
  signal trig_empty, trig_full : std_logic;
  signal trig_rd_ena           : std_logic;

  signal trig_num_s : unsigned(TRIG_EVN_BITS-1 downto 0);

  signal trig_data_out_s : trigger_tdc_hit;
  signal trig_data_valid : std_logic;
  signal tdc_data_out_s  : tdc_output;
  signal tdc_data_valid  : std_logic;

  signal daq_out_s   : std_logic_vector(DAQ_OUT_BITS-1 downto 0);
  signal daq_valid_s : std_logic;

begin  -- architecture arch

  rst       <= reset;
  s_pulse   <= pulse;
  trigger_s <= trigger;
  daq       <= daq_out_s;
  valid     <= daq_valid_s;

  clock250x4_1 : clock250x4
    port map (
      clk0      => clk(0),
      clk1      => clk(1),
      clk2      => clk(2),
      clk3      => clk(3),
      clkout100 => clk_sys,
      reset     => rst,
      locked    => open,
      clk_in1   => clk100);

  event_builder_1 : entity work.event_builder
    port map (
      clk             => clk(0),
      rst             => rst,
      trig_hit_in     => trig_out,
      trig_empty      => trig_empty,
      trig_rd_ena     => trig_rd_ena,
      tdc_data        => rd_data,
      tdc_empty       => empty,
      tdc_full        => full,
      rd_ena          => rd_ena,
      trig_data_out   => trig_data_out_s,
      trig_data_valid => trig_data_valid,
      tdc_data_out    => tdc_data_out_s,
      tdc_data_valid  => tdc_data_valid);

  event_formatter_1 : entity work.event_formatter
    port map (
      clk             => clk(0),
      rst             => rst,
      trig_data_in    => trig_data_out_s,
      trig_data_valid => trig_data_valid,
      tdc_data_in     => tdc_data_out_s,
      tdc_data_valid  => tdc_data_valid,
      daq_out         => daq_out_s,
      daq_valid       => daq_valid_s);

  tdc_multi_chan_1 : entity work.tdc_multi_chan
    port map (
      clk      => clk,
      rst      => rst,
      trigger  => trigger_s,
      trig_num => trig_num_s(TDC_TRIG_BITS-1 downto 0),
      pulse    => s_pulse,
      rd_data  => rd_data,
      empty    => empty,
      full     => full,
      rd_ena   => rd_ena);

  trigger_tdc_with_fifo_1 : entity work.trigger_tdc_with_fifo
    port map (
      clk              => clk,
      rst              => rst,
      trigger          => trigger_s,
      empty            => trig_empty,
      event_number_out => trig_num_s,
      full             => trig_full,
      output           => trig_out,
      rd_ena           => trig_rd_ena);

end architecture arch;
