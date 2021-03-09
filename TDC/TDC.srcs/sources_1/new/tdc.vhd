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

    signal present_time, start_time: unsigned(7 downto 0) := (others => '0');
    signal flags: std_logic_vector(3 downto 0) := (others => '0');
    signal outflag: std_logic_vector(1 downto 0) := (others => '0');
    signal prec_raw : std_logic_vector(3 downto 0) := (others => '0'); 
        
begin

g_multiclock: for i in 0 to 3 generate
    one_clock: process(clk(i))    
    begin    
    if(rising_edge(clk(i))) then
    if (g_reset = '1') then
       flags(i) <= '0';
    else       
       flags(i) <= pulse;        
    end if; 
    end if;
 end process;
 end generate g_multiclock; 

clock3 :process (clk(1)) is
variable tmp_flag : std_logic := '0'; 

begin
   if (rising_edge(clk(1))) then
      if(pulse='1'and tmp_flag='0'and outflag/="00") then
         prec_raw(3) <= flags(3);
         tmp_flag := '1';
      elsif(pulse='0' and tmp_flag='1') then
         tmp_flag := '0';
      end if;
   end if;
end process;

time_counter: process(clk)  
variable tmp_prec : std_logic_vector(3 downto 0) := (others => '0');
    
begin    
if(rising_edge(clk(0))) then
    if (t_reset='1') then
       present_time <= (others => '0');
    elsif (g_reset = '1') then
       present_time <= (others => '0');
       o_time <= (others => '0');
       o_prec(2 downto 0) <= (others => '0');
       o_width <= (others => '0');
       o_valid <= '0';
    else
       present_time <= present_time + 1;
       if (pulse='1' and outflag="00") then
          o_time <= std_logic_vector(present_time);
          start_time <= present_time;
          prec_raw(0) <= flags(0);
          prec_raw(1) <= flags(1);
          prec_raw(2) <= flags(2); 
          outflag <= "01";
          o_valid <= '0';     
       elsif (outflag="01") then
          case prec_raw is
             when "1000" => o_prec <= "0000";
             when "0000" => o_prec <= "0001";
             when "1110" => o_prec <= "0010";
             when "1100" => o_prec <= "0011";
             when others  => o_prec <= "1111";
          end case;
          outflag <= "10";          
       elsif (pulse='0' and outflag/="00") then
          o_width <= std_logic_vector(present_time - start_time);
          o_valid <= '1';
          outflag <= "00";
       elsif (pulse='0' and outflag="00") then
          o_valid <= '0';
       end if; 
    end if; 
 end if;
 end process;

end Behavioral;