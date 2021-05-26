-- event_formatter.vhd - merge trigger and hit data and format events
--
-- Expects input on inputs as:
--    trig_data_out : out trigger_tdc_hit;
--    trig_data_valid : out std_logic;
--    tdc_data_out : out tdc_output;
--    tdc_data_valid : out std_logic
--
-- (event builder guarantees that trigger and hit data are not simultaneous)
--
-- First version just outputs hits with appropriate tag bits
-- (no attempt to sort hits to match trigger number)

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_types.all;

entity event_formatter is

  port(
    clk : in std_logic;
    rst : in std_logic;

    trig_data_in    : in trigger_tdc_hit;
    trig_data_valid : in std_logic;
    tdc_data_in     : in tdc_output;
    tdc_data_valid  : in std_logic;

    daq_out   : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
    daq_valid : out std_logic
    );

end entity event_formatter;



architecture synth of event_formatter is

  signal daq_valid_s : std_logic;
  signal daq_out_s   : std_logic_vector(DAQ_OUT_BITS-1 downto 0);

begin

  daq_out <= daq_out_s;
  daq_valid <= daq_valid_s;

  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active high)

    elsif rising_edge(clk) then         -- rising clock edge

      daq_valid_s <= '0';
      daq_out_s <= (others => '0');

      -- output_1a <= std_logic_vector(to_unsigned(input_1, output_1a'length));

      daq_out_s(DAQ_TYPE_BITS-1 downto DAQ_TYPE_BITS-4) <=
        std_logic_vector(to_unsigned(DAQ_TYPE_IDLE, DAQ_TYPE_BITS));

      if trig_data_valid = '1' then

        -- put data in low bits
        daq_out_s(len(trig_data_in)-1 downto 0) <= 
          vectorify(trig_data_in, daq_out_s(len(trig_data_in)-1 downto 0));

        daq_out_s(DAQ_OUT_BITS-1 downto DAQ_OUT_BITS-4) <=
          std_logic_vector(to_unsigned(DAQ_TYPE_HEADER, DAQ_TYPE_BITS));

        daq_valid_s <= '1';
      end if;

      if tdc_data_valid = '1' then

        daq_out_s(len(tdc_data_in)-1 downto 0) <= 
          vectorify(tdc_data_in, daq_out_s(len(tdc_data_in)-1 downto 0));

        daq_out_s(DAQ_OUT_BITS-1 downto DAQ_OUT_BITS-4) <=
          std_logic_vector(to_unsigned(DAQ_TYPE_DATA, DAQ_TYPE_DATA));
        daq_valid_s <= '1';
      end if;

    end if;

  end process;

end architecture synth;
