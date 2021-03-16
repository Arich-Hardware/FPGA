-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tdc_tb is
end;

architecture bench of tdc_tb is

  component multi_tdc
    Port (
       clk    : in std_logic_vector(3 downto 0);     
       t_reset: in std_logic;
       pulse  : in std_logic;
       --coarse_time : in std_logic_vector(7 downto 0);
       o_time : out std_logic_vector(7 downto 0);
       o_prec : out std_logic_vector(3 downto 0);
       o_width: out std_logic_vector(7 downto 0);
       o_valid: out std_logic);
  end component;

  signal clk: std_logic_vector(3 downto 0);
  signal t_reset: std_logic;
  signal pulse: std_logic;
  --signal coarse_time: std_logic_vector(7 downto 0);   
  signal o_time: std_logic_vector(7 downto 0); 
  signal o_prec: std_logic_vector(3 downto 0);
  signal o_width: std_logic_vector(7 downto 0); 
  signal o_valid: std_logic;

  constant clock_period: time := 4 ns;
  signal stop_the_clock: boolean;
  
begin

  uut: multi_tdc port map ( clk     => clk,
                         t_reset => t_reset,
                         pulse   => pulse,
                         --coarse_time => coarse_time,
                         o_time  => o_time,
                         o_prec  => o_prec,
                         o_width => o_width,
                         o_valid => o_valid );

  stimulus: process
  begin
  
    -- Put initialisation code here
    pulse <= '0';
    t_reset <= '0';
    wait for 4 ns;
    t_reset <='1';
    wait for 4 ns;
    t_reset <='0';
    wait for 4 ns;
    pulse <= '1';
    wait for 16 ns;
    pulse <= '0';
    wait for 25 ns;    
    pulse <= '1';
    wait for 16 ns;
    pulse <= '0';
    wait for 25 ns;    
    pulse <= '1';
    wait for 16 ns;
    pulse <= '0';
    wait for 25 ns;    
    pulse <= '1';
    wait for 16 ns;
    pulse <= '0';
    wait for 25 ns;    
    pulse <= '1';
    wait for 16 ns;
    pulse <= '0';    
    wait for 20 ns;

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

    c_time: process
    variable tmp_time : unsigned(7 downto 0) := (others => '0');
  begin
    while not stop_the_clock loop       
      tmp_time := tmp_time +1;
      --coarse_time <= std_logic_vector(tmp_time);
      wait for clock_period;
    end loop;
    wait;
  end process;

g_multiphase: for i in 0 to 3 generate  
    clocking: process
  begin
  wait for clock_period/4*i;
    while not stop_the_clock loop       
      clk(i) <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;
end generate g_multiphase;  
  
end;
  