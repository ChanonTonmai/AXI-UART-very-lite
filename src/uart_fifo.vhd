library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
entity UART_WITH_FIFO is 

port (
	i_clk : in std_logic;
    rx_fifo_rst : in std_logic;  -- reset active high
	tx_fifo_rst : in std_logic;  -- reset active high  
	--i_send : in std_logic; -- tell the system to send t
	
	-- uart tx
	o_serial :  out std_logic; 
	
	-- uart rx
	i_serial : in std_logic; 

	-- fifo write for tx 
	i_wr_en : in std_logic; 
	i_wr_data : in std_logic_vector(8-1 downto 0); 
	
	-- fifo read for rx
	i_rd_en_to_top : in std_logic; 
	o_rd_data_to_top : out std_logic_vector(8-1 downto 0);
	
	baud_rate : in std_logic_vector(5 downto 0);

	tx_fifo_empty : out std_logic; 
	tx_fifo_full : out std_logic; 
	rx_fifo_empty : out std_logic;
	rx_fifo_full : out std_logic

);
end UART_WITH_FIFO;


architecture beh of UART_WITH_FIFO is 

component UART_TOP is
port(
	 i_clk       : in  std_logic;
	 c_clk_per_bit : in integer; 

	 -- write channel 
	 i_tx_dv     : in  std_logic;
	 i_byte      : in  std_logic_vector(7 downto 0);
	 o_tx_done   : out std_logic;
	 o_serial   : out  std_logic;
	 o_active   : out std_logic; 
	 
	 
	 -- read channel
	 o_rx_dv     : out std_logic;
	 o_byte      : out std_logic_vector(7 downto 0);
         i_serial   : in  std_logic
	 );
end component; 

component module_fifo_regs_no_flags is
   generic (
    g_WIDTH : natural := 8;
	g_DEPTH : integer := 32
    );
   port (
    i_rst_sync      : in std_logic;
    i_clk      : in std_logic;
    g_bit : in integer range 0 to 1000;
 
    -- FIFO Write Interface
    i_wr_en     : in  std_logic;
    i_wr_data    : in  std_logic_vector(g_WIDTH-1 downto 0);
    o_full     : out std_logic;
 
    -- FIFO Read Interface
    i_rd_en    : in  std_logic;
    o_rd_data   : out std_logic_vector(g_WIDTH-1 downto 0);
    o_empty    : out std_logic;
	o_tx_dv     : out std_logic -- tx dv for uart
    );
end component;




signal i_rd_en, o_rx_dv, en, i_tx_dv, o_empty, o_tx_dv, o_active : std_logic; 
signal o_rd_data, o_byte : std_logic_vector(7 downto 0); 
signal o_tx_dv_temp, o_tx_dv_out : std_logic; 

constant g_WIDTH : integer := 8; 
constant g_DEPTH : integer := 32; 

signal c_clk_per_bit : integer range 0 to 1000 := 870;  -- this will be set correctly with f_clk/baud_rate; 
signal g_bit : std_logic_vector(5 downto 0);

begin 
c_clk_per_bit <= 870 when baud_rate = "000001" else 
				500;

--g_bit <= std_logic_vector(to_unsigned(c_clk_per_bit, g_bit'length));

fifo_in_uart_tx: module_fifo_regs_no_flags 
   generic map (
    g_WIDTH => g_WIDTH,
	g_DEPTH => g_DEPTH
)
   port map (
    i_rst_sync => tx_fifo_rst,      
    i_clk => i_clk,     
    g_bit => c_clk_per_bit,  
 
    -- FIFO Write Interface
    i_wr_en => i_wr_en,      
    i_wr_data => i_wr_data,     
    o_full => tx_fifo_full,      
 
    -- FIFO Read Interface
    i_rd_en => i_rd_en,   
    o_rd_data => o_rd_data,    
    o_empty => tx_fifo_empty,
	o_tx_dv => o_tx_dv
    );

process(i_clk)
begin
    if rising_edge(i_clk) then 
	o_tx_dv_temp <= o_tx_dv;
	o_tx_dv_out <= o_tx_dv_temp;
end if;
end process;

uart_module_1 : UART_TOP 
port map(
	 i_clk => i_clk,
     c_clk_per_bit => c_clk_per_bit,
	 -- write channel 
	 i_tx_dv => o_tx_dv_out,    
	 i_byte => o_rd_data,     
	 o_tx_done => i_rd_en,   
	 o_serial => o_serial,  
	 o_active => o_active,   
	
	 -- read channel
	 o_rx_dv => o_rx_dv, 
	 o_byte => o_byte,      
     i_serial => i_serial   
	 );


fifo_in_uart_rx: module_fifo_regs_no_flags 
   generic map (
    g_WIDTH => g_WIDTH,
    g_DEPTH => g_DEPTH
)
   port map (
    i_rst_sync => rx_fifo_rst,      
    i_clk => i_clk,      
    g_bit => c_clk_per_bit,  
      
 
    -- FIFO Write Interface
    i_wr_en => o_rx_dv,      
    i_wr_data => o_byte,     
    o_full => rx_fifo_full,      
 
    -- FIFO Read Interface
    i_rd_en => i_rd_en_to_top,   
    o_rd_data => o_rd_data_to_top,    
    o_empty => rx_fifo_empty  
    ); 
end beh; 