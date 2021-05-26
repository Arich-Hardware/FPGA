-- event_builder.vhd - simple event builder
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
-- 2021-05-11, hazen - new version with FSM

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;
use work.tdc_types.all;

entity event_builder is

  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    trig_hit_in : in  trigger_tdc_hit;
    trig_empty  : in  std_logic;
    trig_rd_ena : out std_logic;
    tdc_data    : in  tdc_output_array;
    tdc_empty   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    tdc_full    : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO flags
    rd_ena      : out std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);  -- FIFO read
--    data_out    : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
--    data_valid  : out std_logic
    trig_data_out : out trigger_tdc_hit;
    trig_data_valid : out std_logic;
    tdc_data_out : out tdc_output;
    tdc_data_valid : out std_logic
    );

end entity event_builder;

architecture synth of event_builder is

  signal current_chan : integer range 0 to NUM_TDC_CHANNELS := 0;

  signal trig_empty_r : std_logic;      --delay register for empty
  signal tdc_empty_r  : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);

  signal data_out_s : std_logic_vector(DAQ_OUT_BITS-1 downto 0);

  type state_type is (sIDLE, sCHECK_TRIG, sREAD_TRIG, sOUTPUT_TRIG,
                      sINIT_CHAN, sCHECK_CHAN, sREAD_CHAN, sWAIT_CHAN,
                      sOUTPUT_CHAN,
                      sNEXT_CHAN);
  signal state : state_type;

begin  -- architecture synth

  trig_data_out <= trig_hit_in;         -- just wire this up for now

  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active high)
      current_chan <= 0;
      state <= sIDLE;
    elsif rising_edge(clk) then         -- rising clock edge

      -- default values for strobes
      rd_ena      <= (others => '0');
      trig_rd_ena <= '0';

--      data_valid  <= '0';
      trig_data_valid <= '0';
      tdc_data_valid <= '0';

      -- Simple FSM to sequence the readout
      -- See http://gauss.bu.edu/svn/emphatic-doco/Figures/event_builder.pdf

      case state is
        when sIDLE =>                   -- could start in CHECK_TRIG
          state <= sCHECK_TRIG;
          
        when sCHECK_TRIG =>
          if trig_empty = '0' then      -- move on if trigger data
            state <= sREAD_TRIG;
          else                          -- otherwise, go check channels
            state <= sINIT_CHAN;
          end if;

        when sREAD_TRIG =>              -- this state just pulses rd trig
          trig_rd_ena <= '1';
          state <= sOUTPUT_TRIG;

        when sOUTPUT_TRIG =>
          trig_data_valid <= '1';       -- flag output valid
          state <= sINIT_CHAN;
          
        when sINIT_CHAN =>              -- start reading channels
          current_chan <= 0;
          state <= sCHECK_CHAN;

        when sCHECK_CHAN =>             -- check empty flag for current channel
          if tdc_empty(current_chan) = '0' then
            state <= sREAD_CHAN;        -- go read if not empty
          else
            state <= sNEXT_CHAN;        -- else advance to next channel
          end if;

        when sREAD_CHAN =>              -- assert FIFO read enable
          rd_ena(current_chan) <= '1';
          state <= sWAIT_CHAN;

        when sWAIT_CHAN =>              -- wait for data to come out
          state <= sOUTPUT_CHAN;

        when sOUTPUT_CHAN =>            -- latch to output, assert valid
          tdc_data_out <= tdc_data(current_chan);
          tdc_data_valid <= '1';
          state <= sNEXT_CHAN;

        when sNEXT_CHAN =>              -- go back to trigger check, or
          if current_chan = NUM_TDC_CHANNELS-1 then
            current_chan <= 0;
            state <= sCHECK_TRIG;
          else                          -- advance to next channel
            current_chan <= current_chan + 1;
            state <= sCHECK_CHAN;
          end if;
      end case;
      
          
    end if;
  end process;

end architecture synth;
