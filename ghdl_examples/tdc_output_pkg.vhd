--
-- this is currently just for documentation
--


package tdc_output is

  constant TDC_COARSE_BITS : integer := 6;  -- coarse time counter width
  constant TDC_PHASE_BITS : integer := 2;   -- phase measurement bits
  constant TDC_TRIG_BITS : integer := 3;    -- trigger no. bits in TDC record

  -- TDC output (as written to FIFO)
  type tdc_output_rt is record
    leading_edge_time : unsigned(TDC_COARSE_BITS-1 downto 0);
    leading_edge_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);
    trailing_edge_time : unsigned(TDC_COARSE_BITS-1 downto 0);
    trailing_edge_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);
    trigger_number : std_logic_vector(TDC_TRIG_BITS-1 downto 0);
    glitch : std_logic;
    error : std_logic;
  end record tdc_output_rt;
  

end package;
