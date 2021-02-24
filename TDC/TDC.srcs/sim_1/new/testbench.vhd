-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tdc_tb is
end;

architecture bench of tdc_tb is

  component tdc
    Port (
       clk    : in std_logic;
       g_reset: in std_logic;
       t_reset: in std_logic;
       pulse  : in std_logic;
       o_time : out std_logic_vector(11 downto 0);
       o_width: out std_logic_vector(7 downto 0);
       o_valid: out std_logic);
  end component;

  signal clk: std_logic;
  signal g_reset: std_logic;
  signal t_reset: std_logic;
  signal pulse: std_logic;
  signal o_time: std_logic_vector(11 downto 0);
  signal o_width: std_logic_vector(7 downto 0);
  signal o_valid: std_logic;

  constant clock_period: time := 4 ns;
  signal stop_the_clock: boolean;

begin

  uut: tdc port map ( clk     => clk,
                      g_reset => g_reset,
                      t_reset => t_reset,
                      pulse   => pulse,
                      o_time  => o_time,
                      o_width => o_width,
                      o_valid => o_valid );                   

  stimulus: process
  begin
  
    -- Put initialisation code here
    g_reset <= '1';
    t_reset <= '0';
    pulse <= '0';
    wait for 8 ns;
    g_reset <= '0';
    wait for 80 ns;
    -- For some reason the multiphase clock is not working in the initial 80 ns
        
    g_reset <= '1';
    wait for 4 ns;
    g_reset <= '0';
    wait for 4 ns;
    t_reset <= '1';
    wait for 4 ns;
    t_reset <= '0';
    wait for 16 ns;
    
    pulse <= '1';
    wait for 20 ns;
    pulse <= '0';
    wait for 12 ns;
    
    pulse <= '1';
    wait for 8 ns;
    pulse <= '0';
    wait for 12 ns;
    
    t_reset <= '1';
    wait for 4 ns;
    t_reset <= '0';
    wait for 7 ns;
    
    pulse <= '1';
    wait for 11 ns;
    pulse <= '0';
    wait for 5 ns;
    
    g_reset <= '1';
    wait for 4 ns;
    g_reset <= '0';
    wait for 3 ns;
    
    pulse <= '1';
    wait for 9 ns;
    pulse <= '0';
    wait for 4 ns;
    

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  