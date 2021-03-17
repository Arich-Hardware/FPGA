-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.pre_define.all;

entity tdc_tb is
generic (Ntdc: integer := 4);
end;

architecture bench of tdc_tb is

  component tdc_group
    Port (
       clk    : in std_logic_vector(3 downto 0);     
       t_reset: in std_logic;
       pulse  : in std_logic_vector(Ntdc - 1 downto 0);
       output : out t_fifo);
  end component;

  signal clk: std_logic_vector(3 downto 0);
  signal t_reset: std_logic;
  signal pulse: std_logic_vector(Ntdc - 1 downto 0); 
  signal output: t_fifo;

  constant clock_period: time := 4 ns;
  signal stop_the_clock: boolean;
  
begin

  uut: tdc_group port map ( clk     => clk,
                         t_reset => t_reset,
                         pulse   => pulse,
                         output  => output);

  stimulus: process
  begin
  
    -- Put initialisation code here
    pulse <= (others => '0');
    t_reset <= '0';
    wait for 4 ns;
    t_reset <='1';
    wait for 4 ns;
    t_reset <='0';
    wait for 4 ns;
    pulse <= "0001";
    wait for 16 ns;
    pulse <= (others => '0');
    wait for 25 ns;    
    pulse <= "0010";
    wait for 16 ns;
    pulse <= (others => '0');
    wait for 25 ns;    
    pulse <= "0100";
    wait for 16 ns;
    pulse <= (others => '0');
    wait for 25 ns;    
    pulse <= "1000";
    wait for 16 ns;
    pulse <= (others => '0');
    wait for 25 ns;    
    pulse <= "1111";
    wait for 16 ns;
    pulse <= (others => '0');    
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
  