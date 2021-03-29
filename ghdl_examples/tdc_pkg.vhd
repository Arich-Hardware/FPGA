library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tdc_pkg is

  constant NUM_TDC_BUFFERS : integer := 4;
  constant TDC_COARSE_WIDTH : integer := 6;

  -- this should be 100ns or 25 counts
  constant TRIGGER_WINDOW : integer := 25;

  type tdc_buffer_t is record
    tdc_time : unsigned(TDC_COARSE_WIDTH-1 downto 0);
    tdc_phase : std_logic_vector(1 downto 0);
    tdc_valid : std_logic;
  end record tdc_buffer_t;

  type tdc_buffer_group_t is array (0 to NUM_TDC_BUFFERS-1) of tdc_buffer_t;

  constant zero_buffer : tdc_buffer_t := (
    tdc_time => to_unsigned(0, TDC_COARSE_WIDTH ),
    tdc_phase => (others => '0'),
    tdc_valid => '0'
    );

end package tdc_pkg;
