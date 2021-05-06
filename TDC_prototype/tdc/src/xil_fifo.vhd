

entity xil_fifo is
  
  generic (
    FIFO_WIDTH : integer := 32;
    FIFO_EPTH  : integer := 512);

  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    wr_en   : in  std_logic;
    rd_en   : in  std_logic;
    empty   : out std_logic;
    full    : out std_logic;
    wr_data : in  std_logic_vector(FIFO_WIDTH-1 downto 0);
    rd_data : out std_logic_vector(FIFO_WIDTH-1 downto 0));

end entity xil_fifo;

architecture synth of xil_fifo is

  component simple_dual_one_clock is
    generic (
      RAM_WIDTH : integer;
      RAM_DEPTH : integer);
    port (
      clk   : in  std_logic;
      ena   : in  std_logic;
      enb   : in  std_logic;
      wea   : in  std_logic;
      addra : in  std_logic_vector(clog2(RAM_DEPTH)-1 downto 0);
      addrb : in  std_logic_vector(clog2(RAM_DEPTH)-1 downto 0);
      dia   : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      dob   : out std_logic_vector(RAM_WIDTH-1 downto 0));
  end component simple_dual_one_clock;

  signal ram_wr : std_logic;

  subtype index_type is integer range (0 to FIFO_DEPTH-1);
  signal head, tail : index_type;

  signal empty_i : std_logic;
  signal full_i : std_logic;

begin  -- architecture synth

  simple_dual_one_clock_1: entity work.simple_dual_one_clock
    generic map (
      RAM_WIDTH => FIFO_WIDTH,
      RAM_DEPTH => FIFO_DEPTH)
    port map (
      clk   => clk,
      ena   => '1',
      enb   => '1',
      wea   => ram_wr,
      addra => head,
      addrb => tail,
      dia   => wr_data,
      dob   => rd_data);

  if head = tail then
    empty <= '1';
  else
    empty <= '0';
  end if;

  if 

  proc1: process (clk, rst) is
  begin  -- process proc1
    if rst = '1' then                   -- asynchronous reset (active high)
      head <= 0;
      tail <= 0;
    elsif rising_edge(clk) then         -- rising clock edge

    end if;
  end process proc1;

end architecture synth;
