------------------------------------------------------------------------
-- trig_tdc.vhd
--
-- trigger input TDC
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity trigger_tdc_with_fifo is

  port (
    clk              : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    rst              : in  std_logic;   -- active high asynch
    trigger          : in  std_logic;   -- rising edge
    empty, full      : out std_logic;
    event_number_out : out unsigned(TRIG_EVN_BITS-1 downto 0);
    output           : out trigger_tdc_hit;  -- hit (time, phase, evn)
    rd_ena           : in  std_logic);

end entity trigger_tdc_with_fifo;

architecture synth of trigger_tdc_with_fifo is

  component trigger_tdc is
    port (
      clk              : in  std_logic_vector(3 downto 0);
      rst              : in  std_logic;
      trigger          : in  std_logic;
      event_number_out : out unsigned(TRIG_EVN_BITS-1 downto 0);
      output           : out trigger_tdc_hit;
      output_valid     : out std_logic);
  end component trigger_tdc;

  component fifo_512x36 is
    port (
      clk        : in  std_logic;
      srst       : in  std_logic;
      din        : in  std_logic_vector(35 downto 0);
      wr_en      : in  std_logic;
      rd_en      : in  std_logic;
      dout       : out std_logic_vector(35 downto 0);
      full       : out std_logic;
      empty      : out std_logic;
      valid      : out std_logic;
      data_count : out std_logic_vector(8 downto 0));
  end component fifo_512x36;

--   component web_fifo is
--     generic (
--       RAM_WIDTH : natural;
--       RAM_DEPTH : natural);
--     port (
--       clk        : in  std_logic;
--       rst        : in  std_logic;
--       wr_en      : in  std_logic;
--       wr_data    : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
--       rd_en      : in  std_logic;
--       rd_valid   : out std_logic;
--       rd_data    : out std_logic_vector(RAM_WIDTH - 1 downto 0);
--       empty      : out std_logic;
--       empty_next : out std_logic;
--       full       : out std_logic;
--       full_next  : out std_logic;
--       fill_count : out integer range RAM_DEPTH - 1 downto 0);
--   end component web_fifo;

  signal trigger_data   : trigger_tdc_hit;
  signal trigger_data_v : std_logic_vector(len(trigger_data)-1 downto 0);
  signal trigger_valid  : std_logic;

  signal output_data   : trigger_tdc_hit;
  signal output_data_v : std_logic_vector(len(output_data)-1 downto 0);

  signal fifo_in, fifo_out : std_logic_vector(35 downto 0);

begin  -- architecture synth

  trigger_tdc_2 : entity work.trigger_tdc
    port map (
      clk              => clk,
      rst              => rst,
      trigger          => trigger,
      event_number_out => event_number_out,
      output           => trigger_data,
      output_valid     => trigger_valid);

  fifo_512x36_1 : entity work.fifo_512x36
    port map (
      clk        => clk(0),
      srst       => rst,
      din        => fifo_in,
      wr_en      => trigger_valid,
      rd_en      => rd_ena,
      dout       => fifo_out,
      full       => full,
      empty      => empty,
      valid      => open,
      data_count => open);

--  web_fifo_1 : entity work.web_fifo
--    generic map (
--      RAM_WIDTH => len(output_data_v),
--      RAM_DEPTH => 16)
--    port map (
--      clk        => clk(0),
--      rst        => rst,
--      wr_en      => trigger_valid,
--      wr_data    => trigger_data_v,
--      rd_en      => rd_ena,
--      rd_valid   => open,
--      rd_data    => output_data_v,
--      empty      => empty,
--      empty_next => open,
--      full       => full,
--      full_next  => open,
--      fill_count => open);

  fifo_in     <= vectorify(trigger_data, fifo_in);
  output_data <= structify(fifo_out, output_data);

  output <= output_data;

end architecture synth;
