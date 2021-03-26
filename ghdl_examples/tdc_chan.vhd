------------------------------------------------------------------------
-- tdc_chan.vhd
--
-- One TDC channel with n-pulse buffer
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_pkg.all;


entity tdc_chan is

  generic (
    NCHAN : integer := 4);              -- number of buffers

  port (
    rst          : in  std_logic;
    clk          : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    pulse        : in  std_logic;                     -- signal input
    trigger      : in  std_logic;                     -- trigger (capture data)
    buffer_group : out tdc_buffer_group_t             -- output buffers
    );
end entity tdc_chan;


architecture arch of tdc_chan is

  component multi_sample is
    port (
      clk   : in  std_logic_vector(3 downto 0);
      pulse : in  std_logic;
      outp  : out std_logic_vector(6 downto 0));
  end component multi_sample;

  component decode is
    port (
      code                          : in  std_logic_vector(6 downto 0);
      rise, fall, high, low, glitch : out std_logic;
      phase                         : out std_logic_vector(1 downto 0));
  end component decode;

  signal buffers : tdc_buffer_group_t;

  signal clk    : std_logic_vector(3 downto 0);  -- 4 phase clock
  signal sample : std_logic_vector(6 downto 0);

  signal pulse : std_logic;

  signal rise, fall, high, low, glitch : std_logic;

  signal phase : std_logic_vector(1 downto 0);

  -- count buffers in use
  --NOTE: change if #buffers changes!
  signal next_buffer : unsigned(1 downto 0) := "00";

begin  -- architecture arch

  -- just one sampler and decoder

  multi_sample_1 : entity work.multi_sample
    port map (
      clk   => clk,
      pulse => pulse,
      outp  => sample);

  decode_1 : entity work.decode
    port map (
      code   => sample,
      rise   => rise,
      fall   => fall,
      high   => high,
      low    => low,
      glitch => glitch,
      phase  => phase);

  process (clk(0), rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)

    elsif clk(0)'event and clk(0) = '1' then  -- rising clock edge

      if rise = '1' then

        buffers(next_buffer).tdc_phase <= phase;
        buffers(next_buffer).tdc_value <= '1';

        next_buffer <= next_buffer + 1;

      end if;

    end if;
  end process;

end architecture arch;
