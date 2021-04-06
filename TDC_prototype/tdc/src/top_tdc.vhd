library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity top_tdc is

  port (
--    clk100  : in  std_logic;                      -- 100MHz external clock
    clk : in std_logic_vector(3 downto 0);       -- magic external 4-phase clk
    trigger : in  std_logic;                      -- readout trigger
    pulse   : in  std_logic;                      -- SiPM pulse
    hits    : out std_logic_vector(31 downto 0);  -- output hit
    valid   : out std_logic);                     -- output strobe

end entity top_tdc;


architecture arch of top_tdc is

  component tdc_chan is
    port (
      rst          : in  std_logic;
      clk          : in  std_logic_vector(3 downto 0);
      pulse        : in  std_logic;
      trigger      : in  std_logic;
      buffer_valid : out std_logic;
      output       : out tdc_output_rt);
  end component tdc_chan;

  signal rst : std_logic;
  signal out_rt : tdc_output_rt;
  signal out_vec : std_logic_vector(31 downto 0);

begin  -- architecture arch

  rst <= '0';                           -- no reset for now

  out_vec <= vectorify( out_rt, out_vec);

  hits <= out_vec;

  tdc_chan_1: entity work.tdc_chan
    port map (
      rst          => rst,
      clk          => clk,
      pulse        => pulse,
      trigger      => trigger,
      buffer_valid => valid,
      output       => out_rt);

end architecture arch;
