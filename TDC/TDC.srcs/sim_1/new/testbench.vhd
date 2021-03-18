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
       reset: in std_logic;
       trigger: in std_logic;
       pulse  : in std_logic_vector(Ntdc - 1 downto 0);
       rd_en  : in std_logic_vector(Ntdc - 1 downto 0);
       dout : OUT din_array;
       full : OUT STD_LOGIC_vector(Ntdc - 1 downto 0);
       empty : OUT STD_LOGIC_vector(Ntdc - 1 downto 0));
  end component;

  signal clk: std_logic_vector(3 downto 0);
  signal reset, trigger: std_logic;
  signal pulse, rd_en, full, empty: std_logic_vector(Ntdc - 1 downto 0); 
  signal dout: din_array;

  constant clock_period: time := 4 ns;
  signal stop_the_clock: boolean;
  
begin

  uut: tdc_group port map ( clk     => clk,
                         reset => reset,
                         trigger => trigger,                         
                         pulse   => pulse,
                         rd_en => rd_en,
                         dout => dout,
                         full => full,                         
                         empty  => empty);

  stimulus: process
  begin
  
    -- Put initialisation code here
    reset <= '1';
    rd_en <= (others => '0');
    pulse <= (others => '0');
    trigger <= '0';
    wait for 4 ns;
    reset <= '0';
    wait for 4 ns;
    trigger <='1';
    wait for 4 ns;
    trigger <='0';
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
  