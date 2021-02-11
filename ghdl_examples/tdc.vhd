--
-- tdc.vhd:  a very simple TDC example
--
-- wait for a trigger on 'start'
-- measure start time and width of 'pulse'
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc is

  generic (
    T_WIDE : integer := 12;             -- width of time counter
    W_WIDE : integer := 8);             -- width of pulse width counter

  port (
    clk   : in  std_logic;              -- master clock
    rst   : in  std_logic;              -- active high reset
    start : in  std_logic;              -- active high start
    pulse : in  std_logic;              -- active high pulse input
    dv    : out std_logic;              -- data valid output
    tyme  : out std_logic_vector(T_WIDE-1 downto 0);
    width : out std_logic_vector(W_WIDE-1 downto 0));

end entity tdc;


architecture arch of tdc is

  -- maximum counter values as integers
  constant T_MASK : integer := (2 ** T_WIDE)-1;
  constant W_MASK : integer := (2 ** W_WIDE)-1;

  signal t_count : std_logic_vector(T_WIDE-1 downto 0);
  signal w_count : std_logic_vector(W_WIDE-1 downto 0);

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
      t_count    <= (others => '0');
      w_count    <= (others => '0');
      last_pulse <= '0';
      dv         <= '0';
      state      <= IDLE;               -- start in idle state

    elsif clk'event and clk = '1' then  -- rising clock edge

      last_pulse <= pulse;              -- keep previous pulse for edge sense
      last_start <= start;

      dv <= '0';

      -- time counter runs to max value, then reset to IDLE state
      if t_count = std_logic_vector(to_unsigned(T_MASK, T_WIDE)) then
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
            tyme    <= t_count;
          end if;

        when INPULSE =>                 -- in a pulse
          -- end of pulse input?
          if (last_pulse = '1') and (pulse = '0') then
            state <= TRIGGERED;
            width <= w_count;
            dv    <= '1';
          else
            -- have we reached max width?  If so, output now
            if w_count = std_logic_vector(to_unsigned(W_MASK, W_WIDE)) then
              state <= TRIGGERED;
              width <= w_count;
              dv    <= '1';
            else -- otherwise, keep counting width
              w_count <= std_logic_vector(unsigned(w_count) + 1);
            end if;
          end if;

        when others => null;
      end case;

    end if;  -- clock loop
  end process;

end architecture arch;
