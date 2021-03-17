library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pre_define.all;

entity tdc is  
  Port (
     clk    : in std_logic_vector(3 downto 0);
     pulse  : in std_logic;
     t_reset: in std_logic;
     coarse_time : in std_logic_vector(7 downto 0);
     output : out t_hit);
end tdc;

architecture Behavioral of tdc is

    signal start_time: unsigned(7 downto 0) := (others => '0');
    signal flags: std_logic_vector(3 downto 0) := (others => '0');
    signal prec_raw, prec_re : std_logic_vector(3 downto 0) := (others => '0'); 
        
begin

g_multiclock: for i in 0 to 3 generate
one_clock: process(clk(i))    
begin    
    if(rising_edge(clk(i))) then     
       flags(i) <= pulse;        
    end if;
 end process;
 end generate g_multiclock; 
 
clock0 :process (clk(0)) is
begin
   if (rising_edge(clk(0))) then
         prec_raw(0) <= flags(0);
         prec_raw(1) <= flags(1);
         prec_raw(2) <= flags(2);
   end if;
end process;

clock3 :process (clk(1)) is
begin
   if (rising_edge(clk(1))) then
      prec_raw(3) <= flags(3);
   end if;
end process;

clock_all :process (clk(0)) is
begin
   if (rising_edge(clk(0))) then
      prec_re(0) <= prec_raw(0);
      prec_re(1) <= prec_raw(1);
      prec_re(2) <= prec_raw(2);
      prec_re(3) <= prec_raw(3);
   end if;
end process;

time_counter: process(clk(0))  
variable tmp_width: unsigned(7 downto 0) := (others => '0');
begin    
if(rising_edge(clk(0))) then
   if(t_reset = '1') then
      output.o_prec<=(others => '0');
      output.o_time<=(others => '0');
      output.o_width<=(others => '0');
      output.o_valid<='0';
   else
       case prec_re is
          when "0000" =>
             if(prec_raw/="0000") then
                output.o_time <= coarse_time;
                start_time <= unsigned(coarse_time);
                case prec_raw is
                   when "1000" => output.o_prec<="0000";
                   when "1111" => output.o_prec<="0001";
                   when "1110" => output.o_prec<="0010";
                   when "1100" => output.o_prec<="0011";
                   when others  => output.o_prec<="1111"; 
                end case;
             end if;
             output.o_valid <= '0';
          when "1111" =>
             if(prec_raw/="1111") then
                tmp_width := unsigned(coarse_time)-start_time; 
                output.o_width <= std_logic_vector(tmp_width);
                output.o_valid <= '1';
             end if;
          when others => 
             output.o_valid <= '0';
       end case;
    end if;
 end if;
 end process;

end Behavioral;