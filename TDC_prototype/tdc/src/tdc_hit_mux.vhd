------------------------------------------------------------------------
-- tdc_hit_mux -- multiplex TDC hits to multi-hit outputs
--
-- Each rising pulse edge (rise=1), advance multiplexer, and route
-- (delayed) rise, fall, phase signals to output hit processors
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity tdc_hit_mux is
  
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    rise    : in  std_logic;
    fall    : in  std_logic;
    phase   : in  std_logic_vector(TDC_PHASE_BITS-1 downto 0);
    m_rise  : out std_logic_vector(NUM_TDC_BUFFERS-1 downto 0);
    m_fall  : out std_logic_vector(NUM_TDC_BUFFERS-1 downto 0);
    m_phase : out std_logic_vector(TDC_PHASE_BITS-1 downto 0));

end entity tdc_hit_mux;

architecture arch of tdc_hit_mux is

  signal current_buffer : integer range 0 to NUM_TDC_BUFFERS-1 := 0;

  -- two levels of delay pipeline
  signal p0_rise, p1_rise : std_logic;
  signal p0_fall, p1_fall : std_logic;
  signal p0_phase, p1_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);

begin  -- architecture arch

  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active low)

      current_buffer <= 0;
      
    elsif rising_edge(clk) then  -- rising clock edge

      -- pipeline delays
      p0_rise <= rise;
      p1_rise <= p0_rise;
      m_rise( current_buffer) <= p1_rise;

      p0_fall <= fall;
      p1_fall <= p0_fall;
      m_fall( current_buffer) <= p1_fall;

      p0_phase <= phase;
      p1_phase <= p0_phase;
      m_phase <= p1_phase;

      -- pulse rising edge, advance multiplexer
      if rise = '1' then
        if current_buffer < NUM_TDC_BUFFERS-1 then
          current_buffer <= current_buffer + 1;
        else
          current_buffer <= 0;
        end if;
      end if;

    end if;
  end process;

end architecture arch;
