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
    type all_time is array (0 to 3) of unsigned(3 downto 0);
    signal multi_time : all_time; 
    signal start_time: unsigned(7 downto 0) := (others => '0');
    signal present_time: unsigned(7 downto 0) := (others => '0');
    signal precise_time: unsigned(3 downto 0) := (others => '0');
    
    signal valid_flag: std_logic := '0';
    signal output_flag: std_logic := '1';
    
    signal clk_out: std_logic_vector(3 downto 0);
    signal reset: std_logic := '0';
    signal locked: std_logic;
    
    component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_out4          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk               : in     std_logic
 );
end component;

begin

clock_phase : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_out(0),
   clk_out2 => clk_out(1),
   clk_out3 => clk_out(2),
   clk_out4 => clk_out(3),
  -- Status and control signals                
   reset => reset,
   locked => locked,
   -- Clock in ports
   clk => clk
 );

time_counter : process(clk, g_reset, t_reset) 
 begin 
    if (g_reset = '1') then
       o_valid <= '0';
       present_time <= (others => '0');
    elsif (t_reset = '1') then
       present_time <= (others => '0');
    elsif (rising_edge(clk)) then
       present_time <= present_time + 1;
       if (valid_flag = '1' and output_flag = '1') then
          o_valid <= '1';
          output_flag <= '0';
       else
          o_valid <= '0';
          output_flag <= '1';
       end if;
    end if;
end process;
 
g_GENERATE_FOR: for i in 0 to 3 generate
time_counter : process(clk_out(i), t_reset) 
 begin 
    if (t_reset = '1') then
       multi_time(i) <= (others => '0');
    elsif (rising_edge(clk_out(i))) then
       multi_time(i) <= multi_time(i) + 1;
    end if;
end process;
end generate g_GENERATE_FOR;
  
read_pulse : process(pulse, output_flag) 
variable tmp_prec: unsigned(3 downto 0) := (others => '0');

begin
       if (rising_edge(pulse)) then
          start_time <= present_time;    
          tmp_prec := (others => '0');      
          for i in 0 to 3 loop
              if (multi_time(0)=multi_time(i)) then
                  tmp_prec := tmp_prec +1;
              end if;
          end loop;        
          precise_time <= tmp_prec;
       end if;
end process;

stop_pulse : process(pulse, output_flag, g_reset)    

begin    
       if (g_reset = '1') then
          o_time <= (others => '0');
          o_width <= (others => '0');
       elsif (falling_edge(pulse)) then
          valid_flag <= '1';
          o_time <= std_logic_vector(start_time) & std_logic_vector(precise_time);
          o_width <= std_logic_vector(present_time - start_time);
       end if;    
       if (output_flag = '0') then
          valid_flag <= '0';
       end if;      
end process;

end Behavioral;