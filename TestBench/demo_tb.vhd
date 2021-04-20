--
-- demo testbench for a single data file
--
-- assumes all data is in time order and each line starts with
-- a "T" for trigger or "S" for SiPM pulse
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;

entity demo_tb is
end;

architecture bench of demo_tb is

  constant NCHAN : integer := 4;

  signal pulse : std_logic_vector(NCHAN-1 downto 0);

  signal trigger : std_logic;

begin


  reader : process

    file fh               : text open read_mode is "random_data/combined_sorted.dat";
    variable ibuf, obuf   : line;
    variable flag         : character;
    variable stime, width : real;
    variable ptime        : real;
    variable chan         : integer;

  begin

    while not endfile(fh) loop
      -- Read line from file
      readline(fh, ibuf);
      -- Read value from line
      read(ibuf, flag);
      read(ibuf, stime);

      -- wait for start of event
      wait for (stime * 1 ns)-now;

      if(flag = 'S') then
        read(ibuf, chan);
        read(ibuf, width);

        pulse(chan) <= '1';
        pulse(chan) <= transport '0' after (width * 1 ns);

      end if;

      if(flag = 'T') then

        trigger <= '1';
        trigger <= transport '0' after 4 ns;

      end if;

    end loop;

    wait;

  end process;

end;

