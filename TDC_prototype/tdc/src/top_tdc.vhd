-- top_tdc.vhd
--
-- temporary top-level design for Basys-3 trial build
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.tdc_types.all;

entity top_tdc is

  port (
    clk100 : in  std_logic;                     -- 100MHz board clock
    sw     : in  std_logic_vector(9 downto 0);  -- 10 inputs
    LED    : out std_logic_vector(1 downto 0);  -- 2 outputs

--    seg : out std_logic_vector(6 downto 0);  --total 12 outputs
--    dp : out std_logic;
--    an : out std_logic_vector(3 downto 0);

    btnC, btnU : in std_logic;

    -- total 24 I/O
    JA, JB, JC : in std_logic_vector(7 downto 0)

--     -- total 14 I/O
--     vgaRed, vgaBlue, vgaGreen : out std_logic_vector(3 downto 0);
--     Hsync, Vsync : out std_logic;
    );

end entity top_tdc;


architecture arch of top_tdc is

  component top_tdc_logic is
    port (
      clk100  : in  std_logic;
      reset   : in  std_logic;
      trigger : in  std_logic;
      pulse   : in  std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
      daq     : out std_logic_vector(DAQ_OUT_BITS-1 downto 0);
      valid   : out std_logic);
  end component top_tdc_logic;

  signal trigger_s, reset_s : std_logic;
  signal pulse_s            : std_logic_vector(NUM_TDC_CHANNELS-1 downto 0);
  signal daq_s              : std_logic_vector(DAQ_OUT_BITS-1 downto 0);
  signal valid_s            : std_logic;

  signal group_sel : std_logic_vector(1 downto 0);

  signal group_in : std_logic_vector(31 downto 0);

begin

  reset_s   <= btnC;
  trigger_s <= btnU;

  group_sel <= sw(9) & sw(8);
  group_in <= sw(7 downto 0) & JA & JB & JC;

  -- 32 from PMOD and 8 switches
  -- mux to 96 inputs using next switches
  mux1 : process (sw, JA, JB, JC) is
  begin  -- process mux1
    case group_sel is
      when "00" =>
        pulse_s <= X"11111111" & group_in & X"22222222";

      when "01" =>
        pulse_s <= group_in & X"22222222" & X"11111111";

      when "10" =>
        pulse_s <= X"22222222" & X"11111111" & group_in;
      when others => null;
    end case;
  end process mux1;


  -- outputs xor'd
  LED(0) <= xor_reduce(daq_s);
  LED(1) <= valid_s;


  top_tdc_logic_1 : entity work.top_tdc_logic
    port map (
      clk100  => clk100,
      reset   => reset_s,
      trigger => trigger_s,
      pulse   => pulse_s,
      daq     => daq_s,
      valid   => valid_s);

end architecture arch;
