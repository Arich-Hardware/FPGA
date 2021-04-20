------------------------------------------------------------------------
-- tdc_with_fifo.vhd
--
-- One channel multi-hit TDC with output FIFO
-- for now, use an implied FIFO so ghdl simulation works
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity tdc_with_fifo is

  port (
    clk     : in  std_logic_vector(3 downto 0);   -- external 4-phase clk
    rst     : in  std_logic;                      -- active high synch
    trigger : in  std_logic;                      -- readout trigger
    pulse   : in  std_logic;                      -- SiPM pulse
    empty   : out std_logic;                      -- FIFO empty
    full    : out std_logic;                      -- FIFO full
    rd_data : out std_logic_vector(31 downto 0);  -- output hits
    rd_ena  : in  std_logic);                     -- output strobe

end entity tdc_with_fifo;


architecture arch of tdc_with_fifo is

  component tdc_chan is
    port (
      rst          : in  std_logic;
      clk          : in  std_logic_vector(3 downto 0);
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      buffer_valid : out std_logic;
      output       : out tdc_output);
  end component tdc_chan;

  component web_fifo is
    generic (
      RAM_WIDTH : natural;
      RAM_DEPTH : natural);
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      wr_en      : in  std_logic;
      wr_data    : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      rd_en      : in  std_logic;
      rd_valid   : out std_logic;
      rd_data    : out std_logic_vector(RAM_WIDTH - 1 downto 0);
      empty      : out std_logic;
      empty_next : out std_logic;
      full       : out std_logic;
      full_next  : out std_logic;
      fill_count : out integer range RAM_DEPTH - 1 downto 0);
  end component web_fifo;

  signal tdc  : tdc_output;
  signal tdc_vec : std_logic_vector(31 downto 0);
  signal valid   : std_logic;
  signal rd_valid : std_logic;

begin  -- architecture arch

  tdc_vec <= vectorify(tdc, tdc_vec);

  tdc_chan_1 : entity work.tdc_chan
    port map (
      rst          => rst,
      clk          => clk,
      pulse        => pulse,
      trigger      => trigger,
      buffer_valid => valid,
      output       => tdc);

  web_fifo_1 : entity work.web_fifo
    generic map (
      RAM_WIDTH => 32,
      RAM_DEPTH => 128)
    port map (
      clk        => clk(0),
      rst        => rst,
      wr_en      => valid,
      wr_data    => tdc_vec,
      rd_en      => rd_ena,
      rd_valid   => rd_valid,
      rd_data    => rd_data,
      empty      => empty,
      empty_next => open,
      full       => full,
      full_next  => open,
      fill_count => open);

end architecture arch;
