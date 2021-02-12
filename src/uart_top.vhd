---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:02:21 12/23/2018 
-- Design Name: 
-- Module Name:    UART - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TOP is

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
end UART_TOP;

architecture Behavioral of UART_TOP is

component UART_TX is 
generic (
    g_CLKS_PER_BIT : integer := 50 -- Need to be set correctly  fclk/baud_rate
);
port (
    i_clk : in std_logic;
    i_tx_dv : in std_logic; 
    i_tx_byte : in std_logic_vector(7 downto 0);
    o_tx_active : out std_logic;
    o_tx_done : out std_logic;
    o_tx_serial : out std_logic
);
end component; 

component UART_RX is 
generic (
    g_CLKS_PER_BIT : integer := 50 -- Need to be set correctly  fclk/baud_rate
);
port (
    i_clk : in std_logic;
    i_rx_serial : in std_logic; 
    o_rx_dv : out std_logic;
    o_rx_byte : out std_logic_vector(7 downto 0)
);
end component; 

signal TX_Byte   : std_logic_vector(7 downto 0);
signal RX_Byte   : std_logic_vector(7 downto 0);
signal TX_Active, o_rx_dv_signal : std_logic;

constant c_clk_per_bit1 : integer := 870;
begin
   
	
TX_Byte <= i_byte;
o_byte <= RX_Byte(7 downto 0) when o_rx_dv_signal = '1';

o_rx_dv <= o_rx_dv_signal; 
	
receiver : UART_RX 
generic map(
    g_CLKS_PER_BIT => c_clk_per_bit1
)
   port map (
     i_clk       => i_clk,
     i_rx_serial => i_serial,
     o_rx_dv     => o_rx_dv_signal,
     o_rx_byte   => RX_Byte
   );
   
transmitter : UART_TX 
generic map(
    g_CLKS_PER_BIT => c_clk_per_bit1
)
   port map (
     i_clk       => i_clk,
     i_tx_dv     => i_tx_dv,
     i_tx_byte   => TX_Byte,
     o_tx_active => o_active,
     o_tx_serial => o_serial,
     o_tx_done   => o_tx_done      
   );

end Behavioral;