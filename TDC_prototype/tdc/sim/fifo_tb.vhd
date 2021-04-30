--
-- test FIFO behavior
--

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity fifo_tb is

end entity fifo_tb;


architecture sim of fifo_tb is

  component web_fifo is
    generic (
      RAM_WIDTH : natural;
      RAM_DEPTH : natural);
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      wr_en      : in  std_logic;
      wr_data    : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      rd_en      : in  std_logic;
      rd_valid   : out std_logic;
      rd_data    : out std_logic_vector(RAM_WIDTH - 1 downto 0);
      empty      : out std_logic;
      empty_next : out std_logic;
      full       : out std_logic;
      full_next  : out std_logic;
      fill_count : out integer range RAM_DEPTH - 1 downto 0);
  end component web_fifo;

  signal clk, rst     : std_logic;
  signal empty, full  : std_logic;
  signal wr_en, rd_en : std_logic;
  signal rd_valid     : std_logic;

  constant clock_period : time := 4 ns;
  signal stop_the_clock : boolean := false;

  signal rd_data, wr_data : std_logic_vector(7 downto 0);

begin  -- architecture sim

  web_fifo_1 : entity work.web_fifo
    generic map (
      RAM_WIDTH => 8,
      RAM_DEPTH => 16)
    port map (
      clk        => clk,
      rst        => rst,
      wr_en      => wr_en,
      wr_data    => wr_data,
      rd_en      => rd_en,
      rd_valid   => rd_valid,
      rd_data    => rd_data,
      empty      => empty,
      empty_next => open,
      full       => full,
      full_next  => open,
      fill_count => open);

  stim: process is
  begin  -- process stim

    rst <= '0';
    wr_en <= '0';
    rd_en <= '0';
    wr_data <= (others => '0');

    wait for clock_period;
    rst <= '1';
    wait for clock_period;
    rst <= '0';
    wait for clock_period*2;

    wr_data <= x"12";
    wr_en <= '1';
    wait for clock_period;
    wr_en <= '0';
    wait for clock_period*2;

    wr_data <= x"34";
    wr_en <= '1';
    wait for clock_period;
    wr_en <= '0';
    wait for clock_period*2;

    rd_en <= '1';
    wait for clock_period;
    rd_en <= '0';
    wait for clock_period*2;

    rd_en <= '1';
    wait for clock_period;
    rd_en <= '0';
    wait for clock_period*2;

    rd_en <= '1';
    wait for clock_period;
    rd_en <= '0';
    wait for clock_period*2;


    wait;
    

  end process stim;








  clocking : process
  begin
    while not stop_the_clock loop
      clk <= '0';
      clk <= transport '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;


  


end architecture sim;
