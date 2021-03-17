library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tdc_group is
  generic (Ntdc: integer := 4);
  Port (
     clk    : in std_logic_vector(3 downto 0);
     t_reset: in std_logic;
     pulse  : in std_logic_vector(Ntdc - 1 downto 0);
     o_time : out std_logic_vector(8*Ntdc - 1 downto 0);
     o_prec : out std_logic_vector(4*Ntdc - 1 downto 0);
     o_width: out std_logic_vector(8*Ntdc - 1 downto 0);
     o_valid: out std_logic_vector(Ntdc - 1 downto 0));   
end tdc_group;

architecture Behavioral of tdc_group is
component tdc
    Port (
       clk    : in std_logic_vector(3 downto 0);     
       t_reset: in std_logic;
       pulse  : in std_logic;
       coarse_time : in std_logic_vector(7 downto 0);
       o_time : out std_logic_vector(7 downto 0);
       o_prec : out std_logic_vector(3 downto 0);
       o_width: out std_logic_vector(7 downto 0);
       o_valid: out std_logic);
end component;

signal coarse_time : std_logic_vector(7 downto 0) := (others => '0');
  
begin

coarse_clock: process(clk(0))  
variable tmp_time : unsigned(7 downto 0) := (others => '0');
    
begin    
if(rising_edge(clk(0))) then
    if (t_reset='1') then
       coarse_time <= (others => '0');
       tmp_time := (others => '0');
    else
       tmp_time := tmp_time + 1;
       coarse_time <= std_logic_vector(tmp_time);
    end if; 
 end if;
 end process;
 
g_multitdc: for i in 0 to Ntdc-1 generate
tdc_test: tdc port map ( clk     => clk,
                         t_reset => t_reset,
                         pulse   => pulse(i),
                         coarse_time => coarse_time,
                         o_time  => o_time(8*(i+1)-1 downto 8*i),
                         o_prec  => o_prec(4*(i+1)-1 downto 4*i),
                         o_width => o_width(8*(i+1)-1 downto 8*i),
                         o_valid => o_valid(i) );
 end generate g_multitdc; 
 
end Behavioral;
