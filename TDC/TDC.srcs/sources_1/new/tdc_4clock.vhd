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
    type all_time is array(0 to 3) of unsigned(7 downto 0);
    signal present_time: all_time;
    signal start_time: all_time;
    signal width_time: all_time;
    signal outflag: std_logic_vector(3 downto 0) := (others => '0');
        
begin

g_multiclock: for i in 0 to 3 generate
    time_counter: process(clk)    
    begin    
    if(rising_edge(clk(i))) then
    if (t_reset='1') then
       present_time(i) <= (others => '0');
       start_time(i) <= (others => '0');
    elsif (g_reset = '1') then
       present_time(i) <= (others => '0');
       start_time(i) <= (others => '0');
    else
       present_time(i) <= present_time(i) + 1;
       if (pulse='1' and outflag(i)='0') then
          start_time(i) <= present_time(i);
          outflag(i) <= '1';
       elsif (pulse='0' and outflag(i)='1') then
          width_time(i) <= present_time(i) - start_time(i);
          outflag(i) <= '0';
       end if; 
    end if; 
    end if;
 end process;
 end generate g_multiclock;

main_cycle: process(clk)   
variable tmp_width: unsigned(3 downto 0) := (others => '0'); 
variable out_flag: std_logic := '0';
    begin    
    if(rising_edge(clk(0))) then
       tmp_width := outflag(0) & outflag(0) & outflag(0) & outflag(0);
       o_prec <= std_logic_vector(tmp_width);
       if (pulse = '1' and out_flag = '0' and tmp_width > 0 ) then
          o_time <= std_logic_vector(start_time(3));
          out_flag :='1';
          o_valid <= '0';
       elsif (pulse='0' and out_flag='1') then
          o_width <= std_logic_vector(width_time(3));
          o_valid <= '1';
          out_flag := '0';
       elsif (pulse='0') then
          o_valid <= '0';
       end if; 
    end if;
end process;

end Behavioral;