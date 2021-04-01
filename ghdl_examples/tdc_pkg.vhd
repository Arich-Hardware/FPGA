--
-- configuration and custom types for TDC
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tdc_pkg is

  constant NUM_TDC_BUFFERS  : integer := 4;  -- number of buffers
  constant TDC_COARSE_BITS : integer := 6;  -- coarse time counter width
  constant TDC_PHASE_BITS : integer := 2;   -- phase measurement bits

  constant TRIGGER_WINDOW : integer := 25;  -- trig window in clk0 cycles

  -- size of buffer group
  constant BUFFER_SIZE       : integer := (TDC_COARSE_WIDTH + 2 + 1);
  constant BUFFER_GROUP_SIZE : integer := NUM_TDC_BUFFERS * BUFFER_SIZE;

  -- TDC buffer type and support functions
  type tdc_buffer_rt is record
    window : unsigned(TDC_COARSE_BITS-1 downto 0);
    leading_edge_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);
    trailing_edge_time : unsigned(TDC_COARSE_BITS-1 downto 0);
    trailing_edge_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);
    time_out : unsigned( TDC_COARSE_BITS-1 downto 0);
    live : std_logic;
    busy : std_logic;
    valid : std_logic;
  end record tdc_buffer_rt;
  -- hand update the constant below!
  constant TDC_BUFFER_LEN : integer := (TDC_COARSE_BITS*3+TDC_PHASE_BITS*2+3);
  subtype tdc_buffer_rvt is std_logic_vector(TDC_BUFFER_LEN-1 downto 0);
  function vectorify(x: tdc_buffer_rt) return tdc_buffer_rvt;
  function structify(x: tdc_buffer_rvt) return tdc_buffer_rt;
  function nullify(x: tdc_buffer_rt) return tdc_buffer_rt;

  

  -- group of buffers
  type tdc_buffer_group_t is array (0 to NUM_TDC_BUFFERS-1) of tdc_buffer_t;

  -- conversion functions to/from SLV (I hate VHDL!)
  function vectorify( x: tdc_buffer_t) return 

  function tbt2slv (tbt   : tdc_buffer_t) return std_logic_vector;
  function tbtg2slv (tbtg : tdc_buffer_group_t) return std_logic_vector;

  function slv2tbt (slv  : std_logic_vector(BUFFER_SIZE-1 downto 0)) return tdc_buffer_t;
  function slv2tbtg (slv : std_logic_vector(BUFFER_GROUP_SIZE-1 downto 0))
    return tdc_buffer_group_t;

  -- constant type used to reset a buffer
  constant zero_buffer : tdc_buffer_t := (
    tdc_time  => to_unsigned(0, TDC_COARSE_BITS),
    tdc_phase => (others => '0'),
    tdc_valid => '0'
    );

  -- constant types used for simulation testing
  constant test_buffer : tdc_buffer_t := (
    tdc_time  => to_unsigned(57, TDC_COARSE_BITS),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test1 : tdc_buffer_t := (
    tdc_time  => to_unsigned(1, TDC_COARSE_BITS),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test2 : tdc_buffer_t := (
    tdc_time  => to_unsigned(2, TDC_COARSE_BITS),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test3 : tdc_buffer_t := (
    tdc_time  => to_unsigned(3, TDC_COARSE_BITS),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test4 : tdc_buffer_t := (
    tdc_time  => to_unsigned(4, TDC_COARSE_BITS),
    tdc_phase => "10",
    tdc_valid => '0'
    );

end package tdc_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_pkg.all;

package body tdc_pkg is

  -- convert one TDC buffer type to SLV
  function vectorify(x: tdc_buffer_rt) return tdc_buffer_rvt is
    variable s : tdc_buffer_rvt;
  begin
    s := std_logic_vector(x.window) & x.leading_edge_phse &
         std_logic_vector(x.trailing_edge_time) & x.trailing_edge_phase &
         std_logic_vector(x.time_out) & x.live & x.busy & x.valid;
    return s;
  end function vectorify;

  -- convert one TDC buffer type to record
  function structify(x: tdc_buffer_rvt) return tdc_buffer_rt is
    variable r : tdc_buffer_rt;
  begin
    r.window 
  end function structify;
  
  function nullify(x: tdc_buffer_rt) return tdc_buffer_rt;



  function tbt2slv (tbt : tdc_buffer_t) return std_logic_vector is
    variable slv : std_logic_vector(TDC_COARSE_BITS+2+1 -1 downto 0);
  begin
    slv := std_logic_vector(tbt.tdc_time) & tbt.tdc_phase & tbt.tdc_valid;
    return slv;
  end;

  -- convert a group (array) of TDC buffers to SLV
  function tbtg2slv (tbtg : tdc_buffer_group_t) return std_logic_vector is
    variable slv : std_logic_vector(BUFFER_GROUP_SIZE-1 downto 0);
  begin
    for i in tdc_buffer_group_t'range loop
      slv(((i+1)*BUFFER_SIZE-1) downto i*BUFFER_SIZE) := tbt2slv(tbtg(i));
    end loop;
    return slv;
  end;

  -- convert an SLV to one TDC buffer
  function slv2tbt (slv : std_logic_vector(BUFFER_SIZE-1 downto 0)) return tdc_buffer_t is
    variable tbt : tdc_buffer_t;
  begin
    tbt.tdc_time  := unsigned(slv(BUFFER_SIZE-1 downto BUFFER_SIZE-TDC_COARSE_BITS));
    tbt.tdc_phase := slv(2 downto 1);
    tbt.tdc_valid := slv(0);
    return tbt;
  end;

  -- convert an SLV to a group of TDC buffers
  function slv2tbtg (slv : std_logic_vector(BUFFER_GROUP_SIZE-1 downto 0)) return tdc_buffer_group_t is
    variable tbtg : tdc_buffer_group_t;
  begin
    for i in tdc_buffer_group_t'range loop
      tbtg(i) := slv2tbt(slv(((i+1)*BUFFER_SIZE-1) downto i*BUFFER_SIZE));
    end loop;
    return tbtg;
  end;

end package body tdc_pkg;

