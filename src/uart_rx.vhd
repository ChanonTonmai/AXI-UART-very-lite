library ieee;
use ieee.std_logic_1164.ALL; 
use ieee.numeric_std.ALL; 

entity UART_RX is 
generic (
    g_CLKS_PER_BIT : integer := 50 -- Need to be set correctly  fclk/baud_rate
);
port (
    i_clk : in std_logic;
    i_rx_serial : in std_logic; 
    o_rx_dv : out std_logic;
    o_rx_byte : out std_logic_vector(7 downto 0)
);
end UART_RX; 

architecture RTL of UART_RX is 

type t_SM_MAIN is (s_idle, s_rx_start_bit, s_rx_data_bit,
                    s_rx_stop_bit, s_cleanup);
signal r_SM_Main_reg, r_SM_Main_next : t_SM_MAIN := s_idle; 

signal r_rx_dv : std_logic := '0';
signal r_rx_byte : std_logic_vector(7 downto 0) := (others => '0');

signal r_clk_cnt : integer range 0 to g_CLKS_PER_BIT-1;
signal r_bit_index : integer range 0 to 7 := 0;

signal r_rx_data_r, r_rx_data : std_logic; -- for buffer

begin 

BUFFER_STATE : process(i_clk) -- Double Register for incoming data
begin
    if rising_edge(i_clk) then
        r_rx_data_r <= i_rx_serial; 
        r_rx_data <= r_rx_data_r; 
    end if; 
end process; 

--REGIS_STATE : process(i_clk) 
--begin 
    --if rising_edge(i_clk)  then
        --r_SM_Main_reg <= r_SM_Main_next; 
    --end if;
--end process;

ASM_CHART : process(i_clk)
begin 
if rising_edge(i_clk) then 
    case r_SM_Main_next is 
        when s_idle =>
            r_rx_dv <= '0';
            r_clk_cnt <= 0;
            r_bit_index <= 0; 
            if r_rx_data = '0' then -- start_bit_declared
                r_SM_Main_next <= s_rx_start_bit;
            else 
                r_SM_Main_next <= s_idle; 
            end if; 
        
        -- check middle of start bit
        when s_rx_start_bit =>
            if r_clk_cnt = (g_CLKS_PER_BIT-1)/2 then 
                if r_rx_data = '0' then 
                    r_clk_cnt <= 0;
                    r_SM_Main_next <=  s_rx_data_bit; 
                else 
                    r_SM_Main_next <= s_idle; 
                end if; 
            else 
                r_clk_cnt <= r_clk_cnt + 1 ;
                r_SM_Main_next <= s_rx_start_bit;
            end if; 

        when s_rx_data_bit =>
            if r_clk_cnt < (g_CLKS_PER_BIT-1) then 
                r_clk_cnt <= r_clk_cnt + 1; 
                r_SM_Main_next <=  s_rx_data_bit; 
            else 
                r_clk_cnt <= 0;
		r_rx_byte(r_bit_index) <= r_rx_data;
                if r_bit_index < 7 then 
                    r_bit_index <= r_bit_index + 1; 
                    r_SM_Main_next <=  s_rx_data_bit; 
                else 
                    r_bit_index <= 0;
                    r_SM_Main_next <=  s_rx_stop_bit; 
                end if;
            end if; 
        when s_rx_stop_bit =>
            if r_clk_cnt < (g_CLKS_PER_BIT-1) then 
                r_clk_cnt <= r_clk_cnt + 1; 
                r_SM_Main_next <=  s_rx_stop_bit; 
            else
                r_rx_dv <= '1';
                r_clk_cnt <= 0;
                r_SM_Main_next <=  s_cleanup; 
            end if;
        when s_cleanup =>
            r_rx_dv <= '0';
            r_SM_Main_next <= s_idle; 
        when others =>
            r_SM_Main_next <= s_idle; 
    end case;
end if; 
end process ASM_CHART; 

o_rx_dv <= r_rx_dv; 
o_rx_byte <= r_rx_byte;

end RTL;