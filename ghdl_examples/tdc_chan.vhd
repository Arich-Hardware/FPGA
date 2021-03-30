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
use work.tdc_pkg.all;


entity tdc_chan is
  port (
    rst          : in  std_logic;                     -- (not currently used)
    clk          : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    pulse        : in  std_logic;                     -- signal input
    trigger      : in  std_logic;                     -- trigger (capture data)
    buffer_valid : out std_logic;                     -- valid output
    buffer_group : out tdc_buffer_group_t             -- output buffers
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

  signal buffers : tdc_buffer_group_t; -- := (others => zero_buffer);

  signal sample : std_logic_vector(6 downto 0);
  signal rise, fall, high, low, glitch : std_logic;
  signal phase : std_logic_vector(1 downto 0);

  signal trig0 : std_logic;             -- previous trigger state for edge detect

  signal next_buffer : integer range 0 to NUM_TDC_BUFFERS-1; -- := 0;

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
      buffers <= (others => zero_buffer);
      buffer_group <= (others => zero_buffer);

    elsif rising_edge(clk(0)) then         -- rising clock edge

      trig0 <= trigger;                 -- previous trigger state

      -- activate next buffer on rising edge of input
      if rise = '1' then

        buffers(next_buffer).tdc_phase <= phase;
        buffers(next_buffer).tdc_valid <= '1';
        buffers(next_buffer).tdc_time  <= to_unsigned(TRIGGER_WINDOW, TDC_COARSE_WIDTH);

        if next_buffer < NUM_TDC_BUFFERS-1 then
          next_buffer <= next_buffer + 1;
        else
          next_buffer <= 0;
        end if;

      end if;

      -- update active buffers:  decrement counter,
      -- set valid=0 when count reaches zero
      for i in 0 to NUM_TDC_BUFFERS-1 loop

        if buffers(i).tdc_time > 0 then
          buffers(i).tdc_time <= buffers(i).tdc_time - 1;
        end if;

        if buffers(i).tdc_time = 1 then
          buffers(i).tdc_valid <= '0';
        end if;

      end loop;  -- i

      -- on trigger rising edge, capture outputs
      if trigger = '1' and trig0 = '0' then
        buffer_group <= buffers;
        buffer_valid <= '1';            -- pulse buffer_valid
      else
        buffer_valid <= '0';
      end if;

    end if;
  end process;

end architecture arch;
