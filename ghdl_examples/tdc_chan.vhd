------------------------------------------------------------------------
-- tdc_chan.vhd
--
-- One TDC channel with n-pulse buffer
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_pkg.all;


entity tdc_chan is

  generic (
    NCHAN : integer := 4);              -- number of buffers

  port (
    rst          : in  std_logic;
    clk          : in  std_logic_vector(3 downto 0);  -- 4 phase clock
    pulse        : in  std_logic;                     -- signal input
    trigger      : in  std_logic;                     -- trigger (capture data)
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

  signal buffers : tdc_buffer_group_t := (others => zero_buffer);

  signal sample : std_logic_vector(6 downto 0);

  signal rise, fall, high, low, glitch : std_logic;

  signal phase : std_logic_vector(1 downto 0);

  -- count buffers in use
  --NOTE: change if #buffers changes!
  signal next_buffer : integer range 0 to NUM_TDC_BUFFERS-1 := 0;

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

  -- update all active buffers
--  upd :
--  for i in 0 to NUM_TDC_BUFFERS-1 generate
--
--    process(clk(0)) is
--    begin
--      if(rising_edge(clk(0))) then
--        if buffers(i).tdc_valid = '1' then
--          if buffers(i).tdc_time = 1 then
--            buffers(i).tdc_valid <= '0';
--          end if;
--          buffers(i).tdc_time <= buffers(i).tdc_time - 1;
--        end if;
--      end if;
--
--    end process;
--
--  end generate upd;


  process (clk(0), rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)

    elsif clk(0)'event and clk(0) = '1' then  -- rising clock edge

      -- activate next buffer on rising edge of input
      if rise = '1' then

        buffers(next_buffer).tdc_phase <= phase;
        buffers(next_buffer).tdc_valid <= '1';
        buffers(next_buffer).tdc_time <= to_unsigned(TRIGGER_WINDOW, TDC_COARSE_WIDTH );

        if next_buffer < NUM_TDC_BUFFERS-1 then
          next_buffer <= next_buffer + 1;
        else
          next_buffer <= 0;
        end if;

      end if;

      for i in 0 to NUM_TDC_BUFFERS-1 loop

        if buffers(i).tdc_time > 0 then
          buffers(i).tdc_time <= buffers(i).tdc_time - 1;
        end if;

      end loop;  -- i

  end if;
  end process;

end architecture arch;
