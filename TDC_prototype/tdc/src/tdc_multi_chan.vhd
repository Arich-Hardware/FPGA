------------------------------------------------------------------------
-- tdc_multi_chan.vhd
--
-- Multi-channel TDC with FIFOs on each
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity tdc_multi_chan is

  generic (
    NUM_CHAN : integer := 4);           -- number of channels

  port (
    clk        : in  std_logic_vector(3 downto 0);  -- external 4-phase clk
    rst        : in  std_logic;         -- active high rst
    trigger    : in  std_logic;         -- common (delayed) trigger
    trig_num   : in  unsigned(TDC_TRIG_BITS-1 downto 0);  -- trigger no.
    pulse      : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- SiPM inputs
    rd_data    : out tdc_output_array;  -- output data
    empty      : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    full       : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    rd_ena     : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0)  -- FIFO read
    );

end entity tdc_multi_chan;

architecture arch of tdc_multi_chan is

  component tdc_with_fifo is
    port (
      clk        : in  std_logic_vector(3 downto 0);
      rst        : in  std_logic;
      trigger    : in  std_logic;
      pulse      : in  std_logic;
      trig_num   : in  unsigned(TDC_TRIG_BITS-1 downto 0);
      empty      : out std_logic;
      full       : out std_logic;
      rd_data    : out tdc_output;
      rd_ena     : in  std_logic);
  end component tdc_with_fifo;

  type fill_count_a is array (NUM_TDC_CHANNELS-1 downto 0) of integer;
  signal fill_count : fill_count_a;

begin  -- architecture arch

  tdcs : for i in NUM_TDC_CHANNELS-1 downto 0 generate

    tdc_with_fifo_2 : entity work.tdc_with_fifo
      generic map (
        CHANNEL => i)
      port map (
        clk        => clk,
        rst        => rst,
        trigger    => trigger,
        pulse      => pulse(i),
        trig_num   => trig_num,
        empty      => empty(i),
        full       => full(i),
        fill_count => fill_count(i),
        rd_data    => rd_data(i),
        rd_ena     => rd_ena(i));

  end generate tdcs;

end architecture arch;
