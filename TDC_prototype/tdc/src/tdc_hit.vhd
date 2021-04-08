------------------------------------------------------------------------
-- tdc_hit.vhd -- control/timing logic for one TDC hit
--
-- This module implements TDC triggering and recording for one hit.
-- Inputs are (rise, fall, phase) from the 'decode' block
--   rise   - starts a count-down timer of ~150ns
--            capture leading edge phase
--   fall   - capture count-down time to record falling-edge time
-- del_trig - trigger delayed to match end of 100ns window
--
-- When the count-down expires (~150ns) the "readme" signal is pulsed
-- if a pulse fell within the (~100ns) trigger window.
--
-- N.B. all control signals (rise, fall, del_trig, readme) are one
-- clock wide, update on clock rising edge.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tdc_types.all;

entity tdc_hit is

  port (
    clk      : in  std_logic;           -- clock (phase 0)
    rst      : in  std_logic;           -- active high asynch reset
    -- inputs from 'decode' module
    rise     : in  std_logic;           -- decoded rising edge
    fall     : in  std_logic;           -- decoded falling edge
    phase    : in  std_logic_vector(TDC_PHASE_BITS-1 downto 0);  -- measured phase for rise/fall
    -- input from trigger
    del_trig : in  std_logic;           -- delayed trigger (end of window)
    -- output
    readme   : out std_logic;  -- readout request strobe (1 clock wide)
    hit      : out tdc_hit_rt           -- times/phases
    );

end entity tdc_hit;

architecture arch of tdc_hit is

  -- the countdown timer
  signal timer : unsigned(TDC_TIMEOUT_BITS-1 downto 0);

  -- internal status signals
  signal busy   : std_logic;            -- count-down timer running
  signal active : std_logic;            -- inside "100ns" trigger window

  -- latch
  signal valid : std_logic;             -- hit validated by trigger

  -- local copy for reading
  signal s_hit    : tdc_hit_rt;
  signal s_readme : std_logic;

begin  -- architecture arch

  hit    <= s_hit;                      -- wire outputs to internal signals
  readme <= s_readme;

  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- reset mainly for simulation

      timer <= (others => '0');
      valid <= '0';
      s_hit <= nullify(s_hit);          -- clear to zero

    elsif rising_edge(clk) then         -- rising clock edge

      -- leading edge, start timer, capture phase
      if rise = '1' then
        timer          <= to_unsigned(TDC_TIMEOUT, TDC_TIMEOUT_BITS);
        valid          <= '0';
        s_hit.le_phase <= phase;
      end if;

      -- trailing edge, capture time/phase
      if fall = '1' then
        s_hit.te_time  <= timer;
        s_hit.te_phase <= phase;
      end if;

      -- count timer down, decode busy
      if timer /= 0 then
        timer <= timer - 1;
        busy  <= '1';
      else
        busy <= '0';
      end if;

      -- check for active trigger window
      if timer > TDC_TIMEOUT-TRIGGER_WINDOW then
        active <= '1';
      else
        active <= '0';
      end if;

      -- handle end of countdown
      if timer = 1 then
        if valid = '1' then
          s_readme <= '1';
        end if;
      else
        s_readme <= '0';
      end if;

      -- reset valid after readout
      if s_readme = '1' then
        valid <= '0';
      end if;

      -- handle trigger
      if del_trig = '1' and active = '1' then
        valid         <= '1';
        s_hit.le_time <= timer;         -- capture leading edge time
      end if;

    end if;
  end process;

end architecture arch;
