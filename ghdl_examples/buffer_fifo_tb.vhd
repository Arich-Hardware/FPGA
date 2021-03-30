library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.tdc_pkg.all;

entity buffer_fifo_tb is
end entity buffer_fifo_tb;

architecture bench of buffer_fifo_tb is

  component buffer_fifo is
    generic (
      DEPTH : integer);
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  tdc_buffer_group_t;
      wen   : in  std_logic;
      full  : out std_logic;
      dout  : out tdc_buffer_group_t;
      ren   : in  std_logic;
      empty : out std_logic);
  end component buffer_fifo;

  constant clk_period : time := 4 ns;

  signal din                   : tdc_buffer_group_t;
  signal clk, rst              : std_logic;
  signal wen, ren, full, empty : std_logic;

  signal dout : tdc_buffer_group_t;

begin  -- architecture bench

  buffer_fifo_1 : entity work.buffer_fifo
    generic map (
      DEPTH => 4)
    port map (
      clk   => clk,
      rst   => rst,
      din   => din,
      wen   => wen,
      full  => full,
      dout  => dout,
      ren   => ren,
      empty => empty);

  stimulus : process
  begin
    -- initialize
    rst <= '1';
    din <= (others => zero_buffer);
    ren <= '0';
    wen <= '0';

    wait for clk_period;
    rst <= '0';
    wait for clk_period;

    -- write some words
    din <= (others => test1);
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;

    din <= (others => test2);
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;

    din <= (others => test3);
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;

    din <= (others => test4);
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;

    din <= (others => test1);
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;

    -- read some words
    wen <= '1';
    wait for clk_period;
    wen <= '0';
    wait for clk_period;
    
    -- read some words
    ren <= '1';
    wait for clk_period;
    ren <= '0';
    wait for clk_period;
    
    -- read some words
    ren <= '1';
    wait for clk_period;
    ren <= '0';
    wait for clk_period;
    
    -- read some words
    ren <= '1';
    wait for clk_period;
    ren <= '0';
    wait for clk_period;
    
    -- read some words
    ren <= '1';
    wait for clk_period;
    ren <= '0';
    wait for clk_period;
    

    wait;

  end process;


  clocking : process
  begin
    while true loop
      clk <= '0', '1' after clk_period / 2;
      wait for clk_period;
    end loop;
  end process;


end architecture bench;
