------------------------------------------------------------------------
-- tdc_chan.vhd
--
-- One TDC channel with n-pulser buffer (see tdc_pkg for configuration)
--
-- Each pulse allocates one "buffer" and starts a count-down timer.
-- The buffer is freed when the timer reaches zero.
-- A trigger captures all active buffers to the output and pulses
-- buffer_valid.
--   
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;


entity tdc_chan is
  port (
    rst          : in  std_logic;                     -- (not currently used)
    clk          : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    pulse        : in  std_logic;                     -- signal input
    trigger      : in  std_logic;                     -- trigger (capture data)
    buffer_valid : out std_logic;                     -- valid output
    output       : out tdc_output_rt                  -- TDC output
    );
end entity tdc_chan;


architecture arch of tdc_chan is

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
      phase                         : out std_logic_vector(1 downto 0));
  end component decode;

  signal buffers : tdc_buffer_group_rt;  -- := (others => zero_buffer);

  signal sample                        : std_logic_vector(6 downto 0);
  signal rise, fall, high, low, glitch : std_logic;
  signal phase                         : std_logic_vector(1 downto 0);

  signal trig0 : std_logic;  -- previous trigger state for edge detect

  signal next_buffer    : integer range 0 to NUM_TDC_BUFFERS-1;  -- := 0;
  signal current_buffer : integer range 0 to NUM_TDC_BUFFERS-1;  -- := 0;

begin  -- architecture arch

  -- just one sampler and decoder

  multi_sample_1 : entity work.multi_sample
    port map (
      clk   => clk,
      pulse => pulse,
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
    if rst = '1' then

      next_buffer <= 0;
      buffers     <= nullify(buffers);

    elsif rising_edge(clk(0)) then      -- rising clock edge

      trig0 <= trigger;                 -- previous trigger state

      -- rising edge:  set timers, active=1; valid=0;
      if rise = '1' then

        buffers(next_buffer).hit.le_phase <= phase;
--        buffers(next_buffer).active       <= '1';
--        buffers(next_buffer).busy         <= '1';
        buffers(next_buffer).valid        <= '0';
        buffers(next_buffer).timeout      <= to_unsigned(TDC_TIMEOUT, TDC_TIMEOUT_BITS);

        current_buffer <= next_buffer;

        if next_buffer < NUM_TDC_BUFFERS-1 then
          next_buffer <= next_buffer + 1;
        else
          next_buffer <= 0;
        end if;

      end if;

      -- falling edge, capture time and phase
      if fall = '1' then
        buffers(current_buffer).hit.te_time  <= buffers(current_buffer).timeout;
        buffers(current_buffer).hit.te_phase <= phase;
      end if;

      buffer_valid <= '0';

      -- update active buffers:  decrement counters,
      for i in 0 to NUM_TDC_BUFFERS-1 loop

        -- try decoding active, busy asynchronously
        if buffers(i).timeout /= 0 then
          buffers(i).busy <= '1';
        else
          buffers(i).busy <= '0';
        end if;

        if buffers(i).timeout > TDC_TIMEOUT-TRIGGER_WINDOW then
          buffers(i).active <= '1';
        else
          buffers(i).active <= '0';
        end if;

        buffers(i).readme <= '0';

        -- decrement timeout time, set busy=0 at zero and readout
        if buffers(i).timeout > 0 then
          buffers(i).timeout <= buffers(i).timeout - 1;
        end if;

        if buffers(i).timeout = 1 then
          if buffers(i).valid = '1' then  --we have a valid hit
            buffers(i).readme     <= '1';
            output.hit            <= buffers(i).hit;
            output.trigger_number <= (others => '0');
            output.glitch         <= '0';
            output.error          <= '0';
            buffer_valid          <= '1';
          end if;
        end if;

        -- on trigger rising edge, set valid, copy le times
        if trigger = '1' and trig0 = '0' then
          if buffers(i).active = '1' then
            buffers(i).valid       <= '1';
            buffers(i).hit.le_time <= buffers(i).timeout;
          end if;
        end if;

      end loop;  -- i


    end if;
  end process;

end architecture arch;
