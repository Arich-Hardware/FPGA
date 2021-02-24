----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/02/16 21:55:13
-- Design Name: 
-- Module Name: tdc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc is
  Port (
     clk    : in std_logic;
     g_reset: in std_logic;
     t_reset: in std_logic;
     pulse  : in std_logic;
     o_time : out std_logic_vector(11 downto 0);
     o_width: out std_logic_vector(7 downto 0);
     o_valid: out std_logic);
end tdc;

architecture Behavioral of tdc is
    signal present_time: unsigned(11 downto 0) := (others => '0');
    signal start_time: unsigned(11 downto 0) := (others => '0');
    signal outflag: std_logic := '0';
    
begin

    time_counter: process(clk, t_reset, g_reset, pulse)    
    variable tmp_width: std_logic_vector(11 downto 0) := (others => '0');
    begin    
    --if(rising_edge(clk)) then
 if(clk'event) then
    if (t_reset='1') then
       present_time <= (others => '0');
    elsif (g_reset = '1') then
       present_time <= (others => '0');
       o_time <= (others => '0');
       o_width <= (others => '0');
       o_valid <= '0';
    else
       present_time <= present_time + 1;
       if (pulse='1' and outflag='0') then
          o_time <= std_logic_vector(present_time);
          start_time <= present_time;
          outflag <= '1';
          o_valid <= '0';
       elsif (pulse='0' and outflag='1') then
          tmp_width := std_logic_vector(present_time - start_time);
          o_width <= tmp_width(7 downto 0);
          o_valid <= '1';
          outflag <= '0';
       elsif (pulse='0') then
          o_valid <= '0';
    end if; 
 end if; 
 end if;
 end process;

end Behavioral;
