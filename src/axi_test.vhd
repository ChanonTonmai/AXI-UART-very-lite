library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_v1_0_S_AXI is 
generic (
    -- width of s_axi data bus 
    C_S_AXI_DATA_WIDTH : integer  := 32;
    -- width of s_axi address bus
    C_S_AXI_ADDR_WIDTH : integer := 5
); 
port (
    -- users ports add here 
    -- control register 
    baud_rate : out std_logic_vector(5 downto 0);
    tx_fifo_rst : out std_logic; 
    rx_fifo_rst : out std_logic; 

    -- status register 
    tx_fifo_full : in std_logic; 
    tx_fifo_empty : in std_logic; 
    rx_fifo_full : in std_logic; 
    rx_fifo_empty : in std_logic; 

    -- data port register
    rx_from_fifo : in std_logic_vector(7 downto 0);
    rx_en : out std_logic;
    tx_to_fifo   : out std_logic_vector(7 downto 0);
    tx_en : out std_logic; 
    -- users ports end

    -- Do not modify the port beyond this line
    -- Global Clock Signal
    S_AXI_ACLK : in std_logic; 
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN : in std_logic;
    -- Write address (issued by master; acceped by Slave)
    S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction; and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT : in std_logic_vector(2 downto 0); 
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID : in std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY : out std_logic;
    -- Write data (issued by master; acceped by Slave) 
    S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID : in std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP : out std_logic_vector(1 downto 0) ;
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID: out std_logic;
    -- Response ready. This signal indicates that the master
        -- can accept a write response.
    S_AXI_BREADY : in std_logic  ;
    -- Read address (issued by master; acceped by Slave)
    S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction; and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT : in std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID : in std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY : out std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) ;
    -- Read response. This signal indicates the status of the
        -- read transfer.
    S_AXI_RRESP : out std_logic_vector(1 downto 0) ;
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID : out std_logic;
    -- Read ready. This signal indicates that the master can
        -- accept the read data and response information.
    S_AXI_RREADY: in std_logic  
);
end uart_v1_0_S_AXI;

architecture beh of uart_v1_0_S_AXI is 

-- AXI4LITE signals
signal axi_awaddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_awready : std_logic;
signal axi_wready : std_logic;
signal axi_bresp : std_logic_vector(1 downto 0);
signal axi_bvalid : std_logic;
signal axi_araddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_arready : std_logic;
signal axi_rdata : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rresp : std_logic_vector(1 downto 0);
signal axi_rvalid : std_logic;


-- Example-specific design signals
-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
-- ADDR_LSB is used for addressing 32/64 bit registers/memories
-- ADDR_LSB = 2 for 32 bits (n downto 2)
-- ADDR_LSB = 3 for 64 bits (n downto 3)
constant ADDR_LSB : integer := 2;
constant OPT_MEM_ADDR_BITS : integer := 2;

------------------------------------------------
---- Signals for user logic register space example
--------------------------------------------------
---- Number of Slave Registers 
signal slv_reg0 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg1 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg2 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg3 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg4 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg5 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg6 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg7 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg_rden : std_logic;
signal slv_reg_wren : std_logic;
signal reg_data_out : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal byte_index : integer  range 0 to 5;
signal asynchFIFO_AlmostFullR : std_logic; 

signal r0_input                           : std_logic;
signal r1_input                           : std_logic;

signal r2_input                           : std_logic;
signal r3_input                           : std_logic;

begin 

-- I/O Connections assignments
S_AXI_AWREADY <= axi_awready;
S_AXI_WREADY <= axi_wready;
S_AXI_BRESP	<= axi_bresp;
S_AXI_BVALID <= axi_bvalid;
S_AXI_ARREADY <= axi_arready;
S_AXI_RDATA	<= axi_rdata;
S_AXI_RRESP	<= axi_rresp;
S_AXI_RVALID <= axi_rvalid;

-- Implement axi_awready generation
-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
-- de-asserted when reset is low.

process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            axi_awready <= '0'; 
        else 
            if ((not axi_awready) and S_AXI_AWVALID and S_AXI_WVALID) = '1' then
                -- slave is ready to accept write address when 
                -- there is a valid write address and write data
                -- on the write address and data bus. This design 
                -- expects no outstanding transactions. 
                axi_awready <= '1';
            else 
                axi_awready <= '0';
            end if; 
        end if;
    end if;
end process;


-- Implement axi_awaddr latching
-- This process is used to latch the address when both 
-- S_AXI_AWVALID and S_AXI_WVALID are valid. 
process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            axi_awaddr <= (others => '0'); 
        else 
            if ((not axi_awready) and S_AXI_AWVALID and S_AXI_WVALID)  = '1' then
                -- Write Address latching 
                axi_awaddr <= S_AXI_AWADDR;
            end if; 
        end if;
    end if;
end process;

-- Implement axi_wready generation
-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
-- de-asserted when reset is low. 

process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            axi_wready <= '0'; 
        else 
            if ((not axi_awready) and S_AXI_AWVALID and S_AXI_WVALID) = '1' then
                -- slave is ready to accept write data when 
                -- there is a valid write address and write data
                -- on the write address and data bus. This design 
                -- expects no outstanding transactions. 
                axi_wready <= '1';
            else 
                axi_wready <= '0'; 
            end if; 
        end if;
    end if;
end process;


-- Implement memory mapped register select and write logic generation
-- The write data is accepted and written to memory mapped registers when
-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
-- select byte enables of slave registers while writing.
-- These registers are cleared when reset (active low) is applied.
-- Slave register write enable is asserted when valid address and data are available
-- and the slave is ready to accept the write address and write data.
slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            slv_reg0 <= (others=>'0');
            slv_reg1 <= (others=>'0');
            slv_reg2 <= (others=>'0');
            slv_reg3 <= (others=>'0');
            slv_reg4 <= (others=>'0');
            slv_reg5 <= (others=>'0');
            slv_reg6 <= (others=>'0');
            slv_reg7 <= (others=>'0');
        else 
            if (slv_reg_wren) = '1' then 
                case axi_awaddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) is 
                    when "000" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg0((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "001" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg1((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "010" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg2((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "011" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg3((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "100" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg4((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "101" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg5((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "110" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg6((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;
                    when "111" => 
                        for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                            if (S_AXI_WSTRB(byte_index) = '1') then 
                                slv_reg7((byte_index+1)*8-1 downto byte_index*8) <= 
                                    S_AXI_WDATA((byte_index+1)*8-1 downto byte_index*8);
                            end if;
                        end loop;

                    when others => 
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                        slv_reg4 <= slv_reg4;
                        slv_reg5 <= slv_reg5;
                        slv_reg6 <= slv_reg6;
                        slv_reg7 <= slv_reg7;
                end case; 
            end if; 
        end if;
    end if;
end process;


-- Implement write response logic generation
-- The write response and response valid signals are asserted by the slave 
-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
-- This marks the acceptance of address and indicates the status of 
-- write transaction.
process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            axi_bvalid  <= '0';
	        axi_bresp   <= (others=> '0');
        else 
            if ((not axi_bvalid) and S_AXI_AWVALID and axi_awready and axi_wready and S_AXI_WVALID) = '1' then
                axi_bvalid  <= '1';
                axi_bresp   <= (others=> '0');
            else 
                if (S_AXI_BREADY and axi_bvalid) = '1' then 
                    --check if bready is asserted while bvalid is high) 
                    --(there is a possibility that bready is always asserted high)  
                    axi_bvalid <= '0'; 
                end if;  
            end if; 
        end if;
    end if;
end process;

-- Implement axi_arready generation
-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
-- S_AXI_ARVALID is asserted. axi_awready is 
-- de-asserted when reset (active low) is asserted. 
-- The read address is also latched when S_AXI_ARVALID is 
-- asserted. axi_araddr is reset to zero on reset assertion.

process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
            axi_arready  <= '0';
	        axi_araddr   <= (others=> '0');
        else 
            if ((not axi_arready) and S_AXI_ARVALID) = '1' then
                axi_arready  <= '1';
                axi_araddr  <= S_AXI_ARADDR;
            else 
                axi_arready  <= '0'; 
            end if; 
        end if;
    end if;
end process;

-- Implement axi_arvalid generation
-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
-- data are available on the axi_rdata bus at this instance. The 
-- assertion of axi_rvalid marks the validity of read data on the 
-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
-- cleared to zero on reset (active low).  


process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
	        axi_rvalid  <= '0';
	        axi_rresp   <= "00";
        else 
            if ((not axi_rvalid) and S_AXI_ARVALID and axi_arready) = '1' then
                axi_rvalid  <= '1';
                axi_rresp   <= "00";
            elsif (axi_rvalid and S_AXI_RREADY) = '1' then
                axi_rvalid  <= '0'; 
            end if; 
        end if;
    end if;
end process;


-- Implement memory mapped register select and read logic generation
-- Slave register read enable is asserted when valid address is available
-- and the slave is ready to accept the read address.

slv_reg_rden <= axi_arready and S_AXI_ARVALID and  (not axi_rvalid);

process (slv_reg0,slv_reg1,slv_reg2, slv_reg3,axi_araddr, rx_fifo_empty, rx_fifo_full, tx_fifo_empty, tx_fifo_full) is 
begin 
case ( axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB)) is 
    when "000" =>    reg_data_out <= x"000000" & rx_from_fifo ; -- rx_from_fifo
    when "001" =>    reg_data_out <= slv_reg1; -- tx_to_fifo
    when "010" =>    reg_data_out <= slv_reg2; -- control register write state 
    when "011" =>    reg_data_out <= x"0000000" & rx_fifo_empty & rx_fifo_full & tx_fifo_empty & tx_fifo_full ; -- status register read state
    when "100" =>    reg_data_out <= x"DEADBEAF";  -- unused		 
    when "101" =>    reg_data_out <= x"DEADBEAF";  -- unused
    when "110" =>    reg_data_out <= x"DEADBEAF";  -- unused
    when "111" =>    reg_data_out <= x"DEADBEAF";  -- unused
    when others =>   reg_data_out <= (others=>'0');
    end case;
end process;

-- Output register or memory read data
process(S_AXI_ACLK) 
begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
	        axi_rdata  <= (others => '0');
        else 
            if (slv_reg_rden) = '1' then
                axi_rdata <= reg_data_out;  
            end if; 
        end if;
    end if;
end process;

-- Add user logic here
--slv_reg0(7 downto 0) <= rx_from_fifo;
tx_to_fifo <= slv_reg1(7 downto 0);

-- status register 
--slv_reg3(0) <= tx_fifo_full; 
--slv_reg3(1) <= tx_fifo_empty;
--slv_reg3(2) <= rx_fifo_full; 
--slv_reg3(3) <= rx_fifo_empty; 

-- control register
baud_rate <= slv_reg2(5 downto 0); 
tx_fifo_rst <= slv_reg2(6); 
rx_fifo_rst <= slv_reg2(7); 



process(S_AXI_ACLK) is 
begin 
    if rising_edge(S_AXI_ACLK) then
       r0_input           <= not S_AXI_BREADY;
       r1_input           <= r0_input;
     end if; 
end process; 

process(S_AXI_ACLK) is 
begin 
    if rising_edge(S_AXI_ACLK) then
       r2_input           <= not axi_rvalid;
       r3_input           <= r2_input;
     end if; 
end process; 
rx_en <= (not r2_input) and r3_input;
tx_en <= (not r0_input) and r1_input when( axi_awaddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB)) = "001" else '0';
-- end user logic 


end beh;