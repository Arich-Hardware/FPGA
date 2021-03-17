library ieee;
use ieee.std_logic_1164.all;
 
package pre_define is

constant Ntdc: integer := 4;
 
TYPE t_hit IS RECORD 
     o_time : std_logic_vector(7 downto 0);
     o_prec : std_logic_vector(3 downto 0);
     o_width: std_logic_vector(7 downto 0);
     o_valid: std_logic;     
END RECORD;
  
type t_fifo is array (Ntdc - 1 downto 0) of t_hit;
   
end package pre_define;