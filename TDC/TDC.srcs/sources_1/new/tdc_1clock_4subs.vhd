library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc is
  Port (
     clk    : in std_logic_vector(3 downto 0);
     g_reset: in std_logic;
     t_reset: in std_logic;
     pulse  : in std_logic;
     o_time : out std_logic_vector(7 downto 0);
     o_prec : out std_logic_vector(3 downto 0);
     o_width: out std_logic_vector(7 downto 0);
     o_valid: out std_logic);
end tdc;

architecture Behavioral of tdc is

    signal present_time, start_time, width_time: unsigned(7 downto 0) := (others => '0');
    signal flags: std_logic_vector(3 downto 0) := (others => '0');
        
begin

g_multiclock: for i in 0 to 3 generate
    one_clock: process(clk)    
    begin    
    if(rising_edge(clk(i))) then
    if (g_reset = '1') then
       flags(i) <= '0';
    else       
       if (pulse='1' and flags(0)='0') then
          flags(i) <= '1';
       elsif (pulse='0' and flags(0)='1') then
          flags(i) <= '0';
       end if; 
    end if; 
    end if;
 end process;
 end generate g_multiclock;

time_counter: process(clk)    

    variable outflag: std_logic := '0';
    
begin    
if(rising_edge(clk(0))) then
    if (t_reset='1') then
       present_time <= (others => '0');
    elsif (g_reset = '1') then
       present_time <= (others => '0');
       o_time <= (others => '0');
       o_prec <= (others => '0');
       o_width <= (others => '0');
       o_valid <= '0';
    else
       present_time <= present_time + 1;
       if (pulse='1' and outflag='0') then
          o_time <= std_logic_vector(present_time);
          o_prec <= flags;
          start_time <= present_time;
          outflag := '1';
          o_valid <= '0';
       elsif (pulse='0' and outflag='1') then
          o_width <= std_logic_vector(present_time - start_time);
          o_valid <= '1';
          outflag := '0';
       elsif (pulse='0') then
          o_valid <= '0';
       end if; 
    end if; 
 end if;
 end process;

end Behavioral;