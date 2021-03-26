library ieee;
use ieee.std_logic_1164.all;

package tdc_pkg is

  constant NUM_TDC_BUFFERS : integer := 4;
  constant TDC_COARSE_WIDTH : integer := 6;

  type tdc_buffer_t is record
    tdc_time : std_logic_vector(TDC_COARSE_WIDTH-1 downto 0);
    tdc_phase : std_logic_vector(1 downto 0);
    tdc_valid : std_logic;
  end record tdc_buffer_t;

  type tdc_buffer_group_t is array (natural range <>) of tdc_buffer_t;

end package tdc_pkg;
