--
-- configuration and custom types for TDC
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tdc_pkg is

  constant NUM_TDC_BUFFERS : integer := 4;      -- number of buffers
  constant TDC_COARSE_WIDTH : integer := 6;     -- coarse time counter width

  constant TRIGGER_WINDOW : integer := 25;      -- trig window in clk0 cycles

  -- size of buffer group
  constant BUFFER_SIZE : integer := (TDC_COARSE_WIDTH + 2 + 1);
  constant BUFFER_GROUP_SIZE : integer := NUM_TDC_BUFFERS * BUFFER_SIZE;

  -- one TDC output buffer
  type tdc_buffer_t is record
    tdc_time : unsigned(TDC_COARSE_WIDTH-1 downto 0);
    tdc_phase : std_logic_vector(1 downto 0);
    tdc_valid : std_logic;
  end record tdc_buffer_t;

  -- group of buffers
  type tdc_buffer_group_t is array (0 to NUM_TDC_BUFFERS-1) of tdc_buffer_t;

  -- conversion functions to/from SLV (I hate VHDL!)
  function tbt2slv (tbt : tdc_buffer_t) return std_logic_vector;
  function tbtg2slv ( tbtg : tdc_buffer_group_t) return std_logic_vector;

  function slv2tbt (slv : std_logic_vector(BUFFER_SIZE-1 downto 0)) return tdc_buffer_t;
  function slv2tbtg (slv : std_logic_vector(BUFFER_GROUP_SIZE-1 downto 0))
    return tdc_buffer_group_t;

  -- constant type used to reset a buffer
  constant zero_buffer : tdc_buffer_t := (
    tdc_time => to_unsigned(0, TDC_COARSE_WIDTH ),
    tdc_phase => (others => '0'),
    tdc_valid => '0'
    );

  -- constant types used for simulation testing
  constant test_buffer : tdc_buffer_t := (
    tdc_time => to_unsigned( 57, TDC_COARSE_WIDTH),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test1 : tdc_buffer_t := (
    tdc_time => to_unsigned( 1, TDC_COARSE_WIDTH),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test2 : tdc_buffer_t := (
    tdc_time => to_unsigned( 2, TDC_COARSE_WIDTH),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test3 : tdc_buffer_t := (
    tdc_time => to_unsigned( 3, TDC_COARSE_WIDTH),
    tdc_phase => "10",
    tdc_valid => '0'
    );

  constant test4 : tdc_buffer_t := (
    tdc_time => to_unsigned( 4, TDC_COARSE_WIDTH),
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
  function tbt2slv (tbt : tdc_buffer_t) return std_logic_vector is
    variable slv : std_logic_vector( TDC_COARSE_WIDTH+2+1 -1 downto 0);
  begin
    slv := std_logic_vector(tbt.tdc_time) & tbt.tdc_phase & tbt.tdc_valid;
    return slv;
  end;

  -- convert a group (array) of TDC buffers to SLV
  function tbtg2slv ( tbtg : tdc_buffer_group_t) return std_logic_vector is
    variable slv : std_logic_vector( BUFFER_GROUP_SIZE-1 downto 0);
  begin
    for i in tdc_buffer_group_t'range loop
      slv( ((i+1)*BUFFER_SIZE-1) downto i*BUFFER_SIZE) := tbt2slv(tbtg(i));
    end loop;
    return slv;
  end;

  -- convert an SLV to one TDC buffer
  function slv2tbt (slv : std_logic_vector(BUFFER_SIZE-1 downto 0)) return tdc_buffer_t is
    variable tbt : tdc_buffer_t;
  begin
    tbt.tdc_time := unsigned(slv(BUFFER_SIZE-1 downto BUFFER_SIZE-TDC_COARSE_WIDTH));
    tbt.tdc_phase := slv(2 downto 1);
    tbt.tdc_valid := slv(0);
    return tbt;
  end;
  
  -- convert an SLV to a group of TDC buffers
  function slv2tbtg (slv : std_logic_vector(BUFFER_GROUP_SIZE-1 downto 0)) return tdc_buffer_group_t is
    variable tbtg : tdc_buffer_group_t;
  begin
    for i in tdc_buffer_group_t'range loop
      tbtg(i) := slv2tbt( slv( ((i+1)*BUFFER_SIZE-1) downto i*BUFFER_SIZE));
    end loop;
    return tbtg;
  end;
  
end package body tdc_pkg;

