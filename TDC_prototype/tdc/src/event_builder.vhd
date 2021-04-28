-- event_builder.vhd - simple event builder
-- <><> Not finished
--
-- inputs:
--   trig_in: trigger_tdc_hit        trigger time, phase, evn
--   trig_valid: sl                  trigger seen
--   tdc_data: tdc_output_array      array of tdc hits
--   tdc_empty: slv                  empty flags for TDC FIFOs
--   tdc_full: slv                   full flags for TDC FIFOs
-- outputs:
--   rd_ena: slv                     read enable for TDC FIFOs
--   data_out: event_builder_word    output data stream
--   data_valid: sl                  output valid
--   

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;
use work.tdc_types.all;

entity event_builder is

  port (
    clk        : in  std_logic_vector(3 downto 0);
    rst        : in  std_logic;
    trig_in    : in  trigger_tdc_hit;
    trig_valid : in  std_logic;
    tdc_data   : in  tdc_output_array;
    tdc_empty  : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    tdc_full   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    rd_ena     : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO read
    trig_num   : out unsigned(TDC_TRIG_BITS-1 downto 0);            -- to TDCs
    data_out   : out event_builder_word;
    data_valid : out std_logic
    );

end entity event_builder;

architecture synth of event_builder is

begin  -- architecture synth

  

end architecture synth;
