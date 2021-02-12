library ieee;
use ieee.std_logic_1164.ALL; 
use ieee.numeric_std.ALL; 

entity UART_TX is 
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
end UART_TX; 

architecture RTL of UART_TX is 

type t_SM_MAIN is (s_idle, s_tx_start_bit, s_tx_data_bit,
                    s_tx_stop_bit, s_cleanup);
signal r_SM_Main_reg, r_SM_Main_next : t_SM_MAIN := s_idle; 

signal r_clk_cnt : integer range 0 to g_CLKS_PER_BIT-1 := 0;
signal r_bit_index : integer range 0 to 7 := 0;

signal r_tx_data : std_logic_vector(7 downto 0) := (others => '0'); 
signal r_tx_done, r_tx_active, r_tx_serial : std_logic; 

begin 

--REGIS_STATE : process(i_clk) 
--begin 
  --  if rising_edge(i_clk)  then
       -- r_SM_Main_reg <= r_SM_Main_next; 
    --end if;
--end process;

ASM_CHART : process(i_clk)
begin 
if rising_edge(i_clk) then
    case r_SM_Main_next is 
        when s_idle =>
            r_tx_active <= '0';
            r_tx_serial <= '1';
            r_tx_done <= '0'; 
            r_clk_cnt <= 0;
            r_bit_index <= 0; 
            if i_tx_dv = '1' then 
                r_tx_data <= i_tx_byte; 
                r_SM_Main_next <= s_tx_start_bit; 
            else 
                r_SM_Main_next <= s_idle; 
            end if; 

        when s_tx_start_bit =>
            r_tx_active <= '1';
            r_tx_serial <= '0' ; 
            if r_clk_cnt < (g_CLKS_PER_BIT-1) then 
                r_clk_cnt <= r_clk_cnt + 1;
                r_SM_Main_next <= s_tx_start_bit; 
            else 
                r_clk_cnt <= 0;
                r_SM_Main_next <= s_tx_data_bit; 
            end if; 

        when s_tx_data_bit =>
            r_tx_serial <= r_tx_data(r_bit_index);
            if r_clk_cnt < (g_CLKS_PER_BIT-1) then 
                r_clk_cnt <= r_clk_cnt + 1;
                r_SM_Main_next <= s_tx_data_bit; 
            else 
                r_clk_cnt <= 0;
                if r_bit_index < 7 then
                    r_bit_index <= r_bit_index + 1; 
                    r_SM_Main_next <= s_tx_data_bit; 
                else 
                    r_bit_index <= 0; 
                    r_SM_Main_next <= s_tx_stop_bit; 
                end if; 
            end if; 

        when s_tx_stop_bit =>
            r_tx_serial <= '1'; 
            if r_clk_cnt < (g_CLKS_PER_BIT-1) then 
                r_clk_cnt <= r_clk_cnt + 1;
                r_SM_Main_next <= s_tx_stop_bit; 
            else 
                r_clk_cnt <= 0;
                r_tx_done <= '1'; 
                r_SM_Main_next <= s_cleanup; 
            end if; 

        when s_cleanup =>
            r_tx_done <= '0'; 
            r_tx_active <= '1'; 
            r_SM_Main_next <= s_idle; 
                       
        when others =>
            r_SM_Main_next <= s_idle; 
    end case;
end if; 
end process ASM_CHART; 

o_tx_done <= r_tx_done; 
O_tx_active <= r_tx_active; 
o_tx_serial <= r_tx_serial; 

end RTL;