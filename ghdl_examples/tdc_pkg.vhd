library ieee;
use ieee.std_logic_1164.all;

package tdc_pkg is

--  constant TDC_T_WIDE : integer := 12;
--  constant TDC_W_WIDE : integer := 8;

-- short values for simulation  
  constant TDC_T_WIDE : integer := 4;
  constant TDC_W_WIDE : integer := 3;

  type t_tdc_out is record
    tdc_time  : std_logic_vector(TDC_T_WIDE-1 downto 0);
    tdc_width : std_logic_vector(TDC_W_WIDE-1 downto 0);
    tdc_valid : std_logic;
  end record t_tdc_out;
  

end package tdc_pkg;
