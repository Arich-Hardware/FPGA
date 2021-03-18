library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.pre_define.all;

entity tdc_group is
  generic (Ntdc: integer := 4);
  Port (
     clk    : in std_logic_vector(3 downto 0);
     reset: in std_logic;
     trigger: in std_logic;
     pulse  : in std_logic_vector(Ntdc - 1 downto 0);
     rd_en  : in std_logic_vector(Ntdc - 1 downto 0);
     dout : OUT din_array;
     full : OUT STD_LOGIC_vector(Ntdc - 1 downto 0);
     empty : OUT STD_LOGIC_vector(Ntdc - 1 downto 0)
     );   
end tdc_group;

architecture Behavioral of tdc_group is
component tdc
    Port (
       clk    : in std_logic_vector(3 downto 0);     
       t_reset: in std_logic;
       pulse  : in std_logic;
       coarse_time : in std_logic_vector(7 downto 0);
       output : out t_hit);
end component;

component fifo_generator_0
    Port (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC);
end component;

signal coarse_time : std_logic_vector(7 downto 0) := (others => '0');
signal din : din_array;
signal wr_en: std_logic_vector(Ntdc - 1 downto 0) := (others => '0');
signal fifo_reset: std_logic := '0';
signal output : t_fifo;
  
begin

coarse_clock: process(clk(0))  
variable tmp_time : unsigned(7 downto 0) := (others => '0');    
begin    
if(rising_edge(clk(0))) then
    if (trigger='1') then
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
                         t_reset => trigger,
                         pulse   => pulse(i),
                         coarse_time => coarse_time,
                         output  => output(i));
                        
fifo_test: fifo_generator_0 port map ( clk     => clk(0),
    srst => fifo_reset,
    din => din(i),
    wr_en => wr_en(i),
    rd_en => rd_en(i),
    dout => dout(i),
    full => full(i),
    empty=> empty(i));
    
write_to_fifo: process(clk(0))
begin
   if(rising_edge(clk(0))) then
         fifo_reset <= reset;           
         din(i) <= output(i).o_time & output(i).o_prec & output(i).o_width & output(i).o_valid;
         wr_en(i) <= output(i).o_valid;
   end if;   
end process;    

end generate g_multitdc; 
 
end Behavioral;
