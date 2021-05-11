-- trigger_tdc.vhd - simple trigger TDC
-- record trigger timestamps
--
-- inputs:
--   4-phase clock, reset
--   trigger input (rising edge)
-- outputs:
--   output with trig_time, trig_phase (TDC)
--               trig_event (event number)
--   output_valid
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;
use work.tdc_types.all;
use work.my_textio.all;
use work.tdc_types_textio.all;

entity trigger_tdc is

  port (
    clk              : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    rst              : in  std_logic;   -- active high asynch
    trigger          : in  std_logic;   -- rising edge
    event_number_out : out unsigned(TRIG_EVN_BITS-1 downto 0);
    output           : out trigger_tdc_hit;  -- hit (time, phase, evn)
    output_valid     : out std_logic);

end entity trigger_tdc;

architecture synth of trigger_tdc is

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
      phase                         : out std_logic_vector(TDC_PHASE_BITS-1 downto 0));
  end component decode;

  -- interconnects from decoder to hit mux
  signal sample                        : std_logic_vector(6 downto 0);
  signal rise, fall, high, low, glitch : std_logic;
  signal phase                         : std_logic_vector(TDC_PHASE_BITS-1 downto 0);

  -- internal signals
  signal hit            : trigger_tdc_hit;
  signal current_time   : unsigned(TRIG_TDC_BITS-1 downto 0);
  signal event_number   : unsigned(TRIG_EVN_BITS-1 downto 0);
  signal event_number_r : unsigned(TRIG_EVN_BITS-1 downto 0);

begin  -- architecture synth

  output <= hit;
  event_number_out <= event_number_r;

  multi_sample_1 : entity work.multi_sample
    port map (
      clk   => clk,
      pulse => trigger,
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
    if rst = '1' then                   -- asynchronous reset (active high)
      hit          <= nullify(hit);
      current_time <= (others => '0');
      event_number <= (others => '0');
    elsif rising_edge(clk(0)) then      -- rising clock edge

      current_time <= current_time + 1;
      output_valid <= '0';

      if rise = '1' then
        hit.trig_time  <= current_time;
        hit.trig_event <= event_number;
        hit.trig_phase <= phase;
        output_valid   <= '1';
        event_number   <= event_number + 1;
        event_number_r <= event_number;
      end if;

    end if;
  end process;

end architecture synth;
