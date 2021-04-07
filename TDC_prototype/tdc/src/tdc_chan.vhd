------------------------------------------------------------------------
-- tdc_chan.vhd
--
-- One TDC channel with n-pulser buffer
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
      phase                         : out std_logic_vector(TDC_PHASE_BITS-1 downto 0));
  end component decode;

  component tdc_hit is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      rise     : in  std_logic;
      fall     : in  std_logic;
      phase    : in  std_logic_vector(TDC_PHASE_BITS-1 downto 0);
      del_trig : in  std_logic;
      readme   : out std_logic;
      hit      : out tdc_hit_rt);
  end component tdc_hit;

  signal sample                        : std_logic_vector(6 downto 0);
  signal rise, fall, high, low, glitch : std_logic;
  signal phase                         : std_logic_vector(TDC_PHASE_BITS-1 downto 0);

  signal trig0    : std_logic;  -- previous trigger state for edge detect
  signal del_trig : std_logic;          -- delayed trigger

  signal current_buffer : integer range 0 to NUM_TDC_BUFFERS-1;  -- := 0;

  signal buffers : tdc_buffer_group_rt;

  -- multiplexers for input signals
  signal m_rise, m_fall   : std_logic_vector(NUM_TDC_BUFFERS-1 downto 0) := (others => '0');
  signal s_phase, x_phase : std_logic_vector(TDC_PHASE_BITS-1 downto 0);

  signal x_rise, x_fall : std_logic;


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

  -- four buffers
  g_hits : for i in 0 to NUM_TDC_BUFFERS-1 generate

    tdc_hit_1 : entity work.tdc_hit
      port map (
        clk      => clk(0),
        rst      => rst,
        rise     => m_rise(i),
        fall     => m_fall(i),
        phase    => s_phase,
        del_trig => del_trig,
        readme   => buffers(i).readme,
        hit      => buffers(i).hit);
  end generate g_hits;

  process (clk(0), rst) is
  begin  -- process
    if rst = '1' then

      current_buffer <= 0;
      buffers        <= nullify(buffers);

    elsif rising_edge(clk(0)) then      -- rising clock edge

      trig0 <= trigger;                 -- previous trigger state

      buffer_valid <= '0';

      for i in 0 to NUM_TDC_BUFFERS-1 loop
        if buffers(i).readme = '1' then
          output.hit   <= buffers(i).hit;
          buffer_valid <= '1';
        end if;
      end loop;  -- i

      -- pass on the decoder signals, delayed by two clocks
      x_rise  <= rise;
      x_fall  <= fall;
      x_phase <= phase;

      m_rise(current_buffer) <= x_rise;
      m_fall(current_buffer) <= x_fall;
      s_phase                <= x_phase;

      -- pulse rising edge
      if rise = '1' then
        if current_buffer < NUM_TDC_BUFFERS-1 then
          current_buffer <= current_buffer + 1;
        else
          current_buffer <= 0;
        end if;
      end if;

      -- rising edge of trigger
      if trigger = '1' and trig0 = '0' then
        del_trig <= '1';
      else
        del_trig <= '0';
      end if;

    end if;
  end process;

end architecture arch;
