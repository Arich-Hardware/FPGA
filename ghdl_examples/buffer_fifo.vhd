------------------------------------------------------------------------
-- buffer_fifo.vhd - FIFO for TDC buffers
--
-- Hopefully this will infer a simple dual-port block RAM
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_pkg.all;

entity buffer_fifo is

  generic (
    DEPTH : integer := 128);

  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    din   : in  tdc_buffer_group_t;
    dout  : out tdc_buffer_group_t;
    ren   : in  std_logic;
    wen   : in  std_logic;
    empty : out std_logic;
    full  : out std_logic);

end entity buffer_fifo;



architecture arch of buffer_fifo is

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

  signal fill_count : integer range DEPTH-1 downto 0;
  signal rd_valid : std_logic;

  signal datain : std_logic_vector( BUFFER_GROUP_SIZE-1 downto 0);
  signal dataout : std_logic_vector( BUFFER_GROUP_SIZE-1 downto 0);

begin  -- architecture arch

  datain <= tbtg2slv( din);
  dout <= slv2tbtg( dataout);

  web_fifo_1 : entity work.web_fifo
    generic map (
      RAM_WIDTH => BUFFER_GROUP_SIZE,
      RAM_DEPTH => DEPTH)
    port map (
      clk        => clk,
      rst        => rst,
      wr_en      => wen,
      wr_data    => datain,
      rd_en      => ren,
      rd_valid   => rd_valid,
      rd_data    => dataout,
      empty      => empty,
      empty_next => open,
      full       => full,
      full_next  => open,
      fill_count => fill_count);

end architecture arch;
