------------------------------------------------------------------------
-- decode.vhd : J.Y.Wu multi-clock TDC decoder
--
-- This is an implmentation of the multiple sampling TDC
-- from J.Y.Wu
-- "Applications of Field-Programmable Gate Arrays in scientific research"
-- (diagram on page 60)
--
-- This is the decoder part which senses edges from the sampler
-- This is completely asynchronous and the result should be latched
--
-- input:  7 successive samples from J.Y.Wu sampler in time order
--         (only the low 5 bits are used)
--
-- outputs (all asynchronous, active '1'):
--
--         rise   -- rising edge
--         fall   -- falling edge
--         phase  -- two-bit binary edge number for rise, fall only
--         high   -- all '1's sampled
--         low    -- all '0's sampled
--         glitch -- multiple edges seen in 5 bit window
--
-- E.Hazen
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity decode is

  port (
    code                          : in  std_logic_vector(6 downto 0);
    rise, fall, high, low, glitch : out std_logic;
    phase : out std_logic_vector( 1 downto 0)
    );

end entity decode;


architecture arch of decode is

begin  -- architecture arch

  p1 : process (code) is
  begin  -- process p1

    rise <= '0';
    fall <= '0';
    high <= '0';
    low <= '0';
    glitch <= '0';
    phase <= "00";

    case code(4 downto 0) is

      when "00000" => low <= '1';
      when "11111" => high <= '1';

      when "00001" => phase <= "11"; rise <= '1';
      when "00011" => phase <= "10"; rise <= '1';
      when "00111" => phase <= "01"; rise <= '1';
      when "01111" => phase <= "00"; rise <= '1';

      when "10000" => phase <= "00"; fall <= '1';
      when "11000" => phase <= "01"; fall <= '1';
      when "11100" => phase <= "10"; fall <= '1';
      when "11110" => phase <= "11"; fall <= '1';

      when others => glitch <= '1';
    end case;

  end process p1;


end architecture arch;
