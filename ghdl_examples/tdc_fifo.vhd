------------------------------------------------------------------------
-- tdc_fifo.vhd -- Multi-hit TDC with output FIFO
--
------------------------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_pkg.all;

entity tdc_fifo is
  
  generic (
    FIFO_DEPTH : integer := 8);

  port (
    clk          : in  std_logic_vector(3 downto 0);  -- multi-phase clock
    rst          : in  std_logic;                     -- active high reset
    pulse        : in  std_logic;                     -- input pulse
    trigger      : in  std_logic;                     -- trigger input
    buffer_group : out tdc_buffer_group_t;            -- output data
    rd_enable    : in  std_logic;                     -- FIFO read enable
    empty        : out std_logic;                     -- FIFO empty flag
    full         : out std_logic);                    -- FIFO full flag

end entity tdc_fifo;

architecture arch of tdc_fifo is

  component tdc_chan is
    port (
      rst          : in  std_logic;
      clk          : in  std_logic_vector(3 downto 0);
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      buffer_valid : out std_logic;
      buffer_group : out tdc_buffer_group_t);
  end component tdc_chan;

  component buffer_fifo is
    generic (
      DEPTH : integer);
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  tdc_buffer_group_t;
      dout  : out tdc_buffer_group_t;
      ren   : in  std_logic;
      wen   : in  std_logic;
      empty : out std_logic;
      full  : out std_logic);
  end component buffer_fifo;

  -- interconnect signals
  signal buffer_valid : std_logic;
  signal tdc_data : tdc_buffer_group_t;
  signal clk4 : std_logic_vector(3 downto 0);

begin  -- architecture arch

  tdc_chan_1: entity work.tdc_chan
    port map (
      rst          => rst,
      clk          => clk4,
      pulse        => pulse,
      trigger      => trigger,
      buffer_valid => buffer_valid,
      buffer_group => tdc_data);

  buffer_fifo_1: entity work.buffer_fifo
    generic map (
      DEPTH => 8)
    port map (
      clk   => clk4(0),
      rst   => rst,
      din   => tdc_data,
      dout  => buffer_group,
      ren   => rd_enable,
      wen   => buffer_valid,
      empty => empty,
      full  => full);

end architecture arch;
