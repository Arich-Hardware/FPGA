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
    clk         : in  std_logic;
    rst         : in  std_logic;
    trig_in     : in  trigger_tdc_hit;
    trig_empty  : in  std_logic;
    trig_rd_ena : out std_logic;
    tdc_data    : in  tdc_output_array;
    tdc_empty   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    tdc_full    : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    rd_ena      : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO read
    trig_num    : out unsigned(TDC_TRIG_BITS-1 downto 0);  -- to TDCs
    data_out    : out event_builder_word;
    data_valid  : out std_logic
    );

end entity event_builder;

architecture synth of event_builder is

  signal current_chan : integer range 0 to NUM_TDC_CHANNELS := 0;

  signal trig_empty_r : std_logic;      --delay register for empty
  signal tdc_empty_r  : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);

begin  -- architecture synth

  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active high)
      current_chan <= 0;
    elsif rising_edge(clk) then         -- rising clock edge

      -- default values for strobes
      data_valid  <= '0';
      rd_ena      <= (others => '0');
      trig_rd_ena <= '0';

      tdc_empty_r <= tdc_empty;         -- delayed empty
      trig_empty_r = trig_empty;

      if current_chan = NUM_TDC_CHANNELS then
        -- pointing at the trigger
        if trig_empty = '0' and trig_empty_r = '0' then
          data_out   <= vectorify(trig_in, data_out);
          trig_rd_ena <= '1';
          data_valid <= '1';
        end if;
        current_chan <= 0;
      else
        -- pointing at a TDC channel
        if tdc_empty(to_integer(current_chan)) = '0' and
           tdc_empty_r( to_integer(current_chan)) = '0' then
          data_out <= vectorify(tdc_data(to_integer(current_chan)),
                                data_out);
          rd_ena( to_integer(current_chan)) <= '1';
          data_valid <= '1';
        end if;
        current_chan <= current_chan + 1;
      end if;

    end if;
  end process;

end architecture synth;
