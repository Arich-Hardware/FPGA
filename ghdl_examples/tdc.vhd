--
-- tdc.vhd:  a very simple TDC example
--
-- wait for a trigger on 'start'
-- measure start time and width of 'pulse'
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tdc_pkg.all;

entity tdc is

  port (
    clk   : in std_logic;               -- master clock
    rst   : in std_logic;               -- active high reset
    start : in std_logic;               -- active high start
    pulse : in std_logic;               -- active high pulse input

    tdc_out : out t_tdc_out             -- time, width, valid
    );

end entity tdc;


architecture arch of tdc is

  -- maximum counter values as integers
  constant T_MASK : integer := (2 ** TDC_T_WIDE)-1;
  constant W_MASK : integer := (2 ** TDC_W_WIDE)-1;

  signal t_count : std_logic_vector(TDC_T_WIDE-1 downto 0);
  signal w_count : std_logic_vector(TDC_W_WIDE-1 downto 0);

  signal last_pulse : std_logic;        -- use to sense edges
  signal last_start : std_logic;        -- use to sense edges

  -- simple 3-state machine
  type state_type is (IDLE, TRIGGERED, INPULSE);
  signal state : state_type;

begin  -- architecture arch

  -- process to trigger on rising clock edge
  process (clk, rst) is
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active high)
      t_count           <= (others => '0');
      w_count           <= (others => '0');
      last_pulse        <= '0';
      tdc_out.tdc_valid <= '0';
      state             <= IDLE;        -- start in idle state

    elsif clk'event and clk = '1' then  -- rising clock edge

      last_pulse <= pulse;              -- keep previous pulse for edge sense
      last_start <= start;

      tdc_out.tdc_valid <= '0';

      -- time counter runs to max value, then reset to IDLE state
      if t_count = std_logic_vector(to_unsigned(T_MASK, TDC_T_WIDE)) then
        state <= IDLE;
      else
        t_count <= std_logic_vector(unsigned(t_count) + 1);
      end if;

      -- update state based on inputs
      case state is
        when IDLE =>                    -- wait for start leading edge
          if (start = '1') and (last_start = '0') then
            t_count <= (others => '0');
            state   <= TRIGGERED;
          end if;

        when TRIGGERED =>               -- wait for pulse(s)
          -- leading edge
          if (last_pulse = '0') and (pulse = '1') then
            w_count <= (others => '0');
            state   <= INPULSE;
            tdc_out.tdc_time    <= t_count;
          end if;

        when INPULSE =>                 -- in a pulse
          -- end of pulse input?
          if (last_pulse = '1') and (pulse = '0') then
            state             <= TRIGGERED;
            tdc_out.tdc_width             <= w_count;
            tdc_out.tdc_valid <= '1';
          else
            -- have we reached max width?  If so, output now
            if w_count = std_logic_vector(to_unsigned(W_MASK, TDC_W_WIDE)) then
              state             <= TRIGGERED;
              tdc_out.tdc_width             <= w_count;
              tdc_out.tdc_valid <= '1';
            else                        -- otherwise, keep counting width
              w_count <= std_logic_vector(unsigned(w_count) + 1);
            end if;
          end if;

        when others => null;
      end case;

    end if;  -- clock loop
  end process;

end architecture arch;
