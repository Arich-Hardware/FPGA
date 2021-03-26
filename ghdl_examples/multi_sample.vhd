------------------------------------------------------------------------
-- multi_sample.vhd : J.Y.Wu multi-clock sampling front-end
--
-- This is an implmentation of the multiple sampling TDC
-- from J.Y.Wu
-- "Applications of Field-Programmable Gate Arrays in scientific research"
-- (diagram on page 60)
--
-- Note that this is merely the sampling front-end, and
-- provides as output the raw samples, synchronized to clk0
--
-- output, by Wu's naming, in descending sampling time order
--   outp(0) <= prec_raw(2);  -- QD
--   outp(1) <= prec_raw(1);  -- QE
--   outp(2) <= prec_raw(0);  -- QF
--   outp(3) <= prec_re(3);   -- Q0
--   outp(4) <= prec_re(2);   -- Q1
--   outp(5) <= prec_re(1);   -- Q2
--   outp(6) <= prec_re(0);   -- Q3
--
-- By A.Peck, L.Y.Wan, E.Hazen 
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity multi_sample is
  port (
    clk   : in  std_logic_vector(3 downto 0); -- 4 phase input clock
    pulse : in  std_logic;                    -- input pulse to sample
    outp  : out std_logic_vector(6 downto 0)  -- output code (sync to clk(0))
    );
end multi_sample;

architecture Behavioral of multi_sample is

  -- first sample on 4 clock phases
  signal flags : std_logic_vector(3 downto 0) := (others => '0');
  -- second sample (3 on phase 0, 1 on phase 90)
  signal prec_raw : std_logic_vector(3 downto 0) := (others => '0');
  -- third sample (all on phase 0 again)
  signal prec_re  : std_logic_vector(3 downto 0) := (others => '0');
  -- output register
  signal outp_s   : std_logic_vector(6 downto 0);

begin

  -- wire the outputs in sampling order for decoding convenience
  outp_s(0) <= prec_raw(2);             -- QD  last sample
  outp_s(1) <= prec_raw(1);             -- QE
  outp_s(2) <= prec_raw(0);             -- QF
  outp_s(3) <= prec_re(3);              -- Q0
  outp_s(4) <= prec_re(2);              -- Q1
  outp_s(5) <= prec_re(1);              -- Q2
  outp_s(6) <= prec_re(0);              -- Q3  first sample

  outp <= outp_s;

  -- sample input on 4 clock phases
  -- 0, 90, 180, 270
  g_multiclock : for i in 0 to 3 generate
    one_clock : process(clk(i))
    begin
      if(rising_edge(clk(i))) then
        flags(i) <= pulse;
      end if;
    end process;
  end generate g_multiclock;

  -- now two banks of registers to move samples
  -- back to clk(0)

  -- first, sample the first 3 phases (0, 90, 180)
  -- on clk(0) resulting in Wu's signals:
  -- prec_raw 0 => QF, 1 => QE, 2 => QD
  clock0 : process (clk(0)) is
  begin
    if (rising_edge(clk(0))) then
      prec_raw(0) <= flags(0);
      prec_raw(1) <= flags(1);
      prec_raw(2) <= flags(2);
    end if;
  end process;

  -- next, sample the last phase (270) on clk0
  clock3 : process (clk(1)) is
  begin
    if (rising_edge(clk(1))) then
      prec_raw(3) <= flags(3);
    end if;
  end process;

  -- finally, resync all to clk0
  clock_all : process (clk(0)) is
  begin
    if (rising_edge(clk(0))) then
      prec_re(0) <= prec_raw(0);
      prec_re(1) <= prec_raw(1);
      prec_re(2) <= prec_raw(2);
      prec_re(3) <= prec_raw(3);
    end if;
  end process;


end Behavioral;
