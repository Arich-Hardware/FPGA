--
-- simple testbench for multi-phase TDC front-end with decoder
--
-- E.Hazen
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_types.all;
use std.textio.all;


entity tdc_chan_tb is
	end;

architecture bench of tdc_chan_tb is

	component tdc_chan is
		generic (
					  NCHAN : integer);
		port (
				  rst      : in  std_logic;
				  clk      : in  std_logic_vector(3 downto 0);
				  pulse    : in  std_logic;
				  trigger  : in  std_logic;
				  trig_num : in  unsigned(TDC_TRIG_BITS-1 downto 0);  -- trigger no.
				  output   : out tdc_output_rt);
	end component tdc_chan;

	signal clk : std_logic_vector(3 downto 0);  -- 4 phase clock
	signal rst : std_logic;

	signal pulse  : std_logic;
	signal sample : std_logic_vector(6 downto 0);

	signal phase : std_logic_vector(1 downto 0);

	constant clock_pi     : real := 4.0 ;
	constant clock_period : time := clock_pi * 1 ns;
	signal stop_the_clock : boolean;

	signal trigger     : std_logic;
	signal trig_number : unsigned(TDC_TRIG_BITS-1 downto 0) := (others => '0');

	signal output : tdc_output_rt;

-- Declare and Open file in read mode:

begin

	tdc_chan_1 : entity work.tdc_chan

	port map (
					rst      => rst,
					clk      => clk,
					pulse    => pulse,
					trigger  => trigger,
					trig_num => trig_number,
					output   => output);

	pulse_sim : process

		file file_handler     : text open read_mode is "test_data_1ms.txt";
		variable row          : line;
		variable flag  : string(1 to 1);
		variable stime, ptime, width  : real;
		variable chanID  : integer;

	begin

		-- Put initialisation code here
		rst   <= '1';
		pulse <= '0';
		wait for clock_period*4;
		rst   <= '0';
		wait for clock_period*4;
		ptime := 0.0;

		while not endfile(file_handler) loop
			-- Read line from file
			readline(file_handler, row);
			-- Read value from line
			read(row, flag);
			if(flag = "S") then
				read(row, stime);
				read(row, chanID);
				read(row, width);
				if(stime<ptime) then
					--	report "The value of 'stime' is " & real'image(stime);
					if(stime + width > ptime) then
						wait for (stime + width - ptime) * 1 ns;
						ptime := stime + width;
					end if;
				else
					wait for (stime-ptime) * 1 ns;
					pulse <= '1';
					wait for width* 1 ns;
					pulse <='0';
					ptime := stime + width;
				end if;
			end if;
		end loop;

		wait;

	end process;

	trig_sim : process

		file file_handler     : text open read_mode is "test_data_1ms.txt";
		variable row          : line;
		variable flag  : string(1 to 1);
		variable stime, ptime  : real;

	begin

		ptime := 0.0;
		trigger <= '0';

		while not endfile(file_handler) loop
			-- Read line from file
			readline(file_handler, row);
			-- Read value from line
			read(row, flag);
			if(flag = "T") then				
				read(row, stime);
				if(stime<ptime) then
					if(stime + clock_pi*2.0 > ptime) then
						wait for (stime + clock_pi*2.0 - ptime) * 1 ns;
						ptime := stime + clock_pi*2.0;
					end if;
				else
					wait for (stime-ptime)* 1 ns;
					trigger <= '1';
					wait for clock_period*2;
					trigger <= '0';
					ptime := stime + clock_pi*2.0;
				end if;
			end if;
		end loop;

		wait;

	end process;

	g_multiphase : for i in 0 to 3 generate
		clocking : process
		begin
			wait for clock_period/4*i;
			while not stop_the_clock loop
				clk(i) <= '0', '1' after clock_period / 2;
				wait for clock_period;
			end loop;
			wait;
		end process;
	end generate g_multiphase;

end;

