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

  generic (
    CHANNEL : integer := 0);

  port (
    clk      : in  std_logic_vector(3 downto 0);  -- external 4-phase clk
--    clk100   : in  std_logic;
    rst      : in  std_logic;                     -- active high synch
    trigger  : in  std_logic;                     -- readout trigger
    pulse    : in  std_logic;                     -- SiPM pulse
    trig_num : in  unsigned(TDC_TRIG_BITS-1 downto 0);
    empty    : out std_logic;                     -- FIFO empty
    full     : out std_logic;                     -- FIFO full
    rd_data  : out tdc_output;
--    fill_count : out integer;
    rd_ena   : in  std_logic);                    -- output strobe

end entity tdc_with_fifo;


architecture arch of tdc_with_fifo is

  component tdc_chan is
    generic (
      CHANNEL : integer := 0);
    port (
      rst          : in  std_logic;
      clk          : in  std_logic_vector(3 downto 0);
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      trig_num     : in  unsigned(TDC_TRIG_BITS-1 downto 0);  -- trigger no.
      buffer_valid : out std_logic;
      output       : out tdc_output);
  end component tdc_chan;

  component fifo_512x36
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
      data_count : out std_logic_vector(8 downto 0)
      );
  end component;


--  component web_fifo is
--    generic (
--      RAM_WIDTH : natural;
--      RAM_DEPTH : natural);
--    port (
--      clk        : in  std_logic;
--      rst        : in  std_logic;
--      wr_en      : in  std_logic;
--      wr_data    : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
--      rd_en      : in  std_logic;
--      rd_valid   : out std_logic;
--      rd_data    : out std_logic_vector(RAM_WIDTH - 1 downto 0);
--      empty      : out std_logic;
--      empty_next : out std_logic;
--      full       : out std_logic;
--      full_next  : out std_logic;
--      fill_count : out integer range RAM_DEPTH - 1 downto 0);
--  end component web_fifo;

  signal tdc     : tdc_output;
--  signal tdc_vec  : std_logic_vector(len(tdc)-1 downto 0);
  signal fifo_in : std_logic_vector(35 downto 0);

  signal valid    : std_logic;
  signal rd_valid : std_logic;


  signal s_trig_num : unsigned(TDC_TRIG_BITS-1 downto 0);

  signal rd_data_rec : tdc_output;
--  signal rd_data_vec : std_logic_vector(len(rd_data_rec)-1 downto 0);
  signal fifo_out    : std_logic_vector(35 downto 0);

  signal fill_count : std_logic_vector(8 downto 0);

begin  -- architecture arch

  -- tdc_vec     <= vectorify(tdc, tdc_vec);
  fifo_in <= vectorify(tdc, fifo_in);

  -- rd_data_rec <= structify(rd_data_vec, rd_data_rec);
  rd_data_rec <= structify(fifo_out, rd_data_rec);

  rd_data <= rd_data_rec;

  s_trig_num <= trig_num;

  tdc_chan_1 : entity work.tdc_chan
    generic map (
      CHANNEL => CHANNEL)
    port map (
      rst          => rst,
      clk          => clk,
      pulse        => pulse,
      trigger      => trigger,
      trig_num     => s_trig_num,
      buffer_valid => valid,
      output       => tdc);

  fifo_512x36_1 : fifo_512x36
    port map (
      clk        => clk(0),
      srst       => rst,
      din        => fifo_in,
      wr_en      => valid,
      rd_en      => rd_ena,
      dout       => fifo_out,
      full       => full,
      empty      => empty,
      valid      => rd_valid,
      data_count => fill_count);

--  web_fifo_1 : entity work.web_fifo
--    generic map (
--      RAM_WIDTH => tdc_width,
--      RAM_DEPTH => TDC_FIFO_DEPTH)
--    port map (
--      clk        => clk(0),
--      rst        => rst,
--      wr_en      => valid,
--      wr_data    => tdc_vec,
--      rd_en      => rd_ena,
--      rd_valid   => rd_valid,
--      rd_data    => rd_data_vec,
--      empty      => empty,
--      empty_next => open,
--      full       => full,
--      full_next  => open,
--      fill_count => fill_count);

end architecture arch;
