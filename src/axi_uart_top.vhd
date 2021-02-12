library ieee;
use ieee.std_logic_1164.ALL; 
use ieee.numeric_std.ALL; 

entity axi_uart is 
generic (
    -- width of s_axi data bus 
    C_S_AXI_DATA_WIDTH : integer  := 32;
    -- width of s_axi address bus
    C_S_AXI_ADDR_WIDTH : integer := 5
); 
port (
    -- user port 
    o_serial : out std_logic;
    i_serial : in std_logic; 

    -- S_AXI INTERFACE -- DO NOT EDIT THIS
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
end axi_uart; 

architecture beh of axi_uart is 



component uart_v1_0_S_AXI is 
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
end component;

component UART_WITH_FIFO is 

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
end component;

signal rx_fifo_rst, tx_fifo_rst : std_logic; 
signal tx_en, rx_en : std_logic; 
signal rx_from_fifo : std_logic_vector(7 downto 0);
signal tx_to_fifo : std_logic_vector(7 downto 0); 
signal baud_rate : std_logic_vector(5 downto 0); 
signal tx_fifo_empty, tx_fifo_full, rx_fifo_empty, rx_fifo_full : std_logic; 
signal i_clk : std_logic; 

begin 
i_clk <= S_AXI_ACLK;
--baud_rate <= "000001";
uart_with_fifo_test : UART_WITH_FIFO 
port map(
	i_clk => i_clk,
    rx_fifo_rst => rx_fifo_rst,  -- reset active high
	tx_fifo_rst => tx_fifo_rst,  -- reset active high  
	--i_send =>, -- tell the system to send t
	
	-- uart tx
	o_serial => o_serial, 
	
	-- uart rx
	i_serial => i_serial, 

	-- fifo write for tx 
	i_wr_en => tx_en, 
	i_wr_data => tx_to_fifo, 
	
	-- fifo read for rx
	i_rd_en_to_top => rx_en, 
	o_rd_data_to_top => rx_from_fifo,
	
	baud_rate => baud_rate,

	tx_fifo_empty => tx_fifo_empty, 
	tx_fifo_full => tx_fifo_full, 
	rx_fifo_empty => rx_fifo_empty,
	rx_fifo_full => rx_fifo_full

);

s_axi_interface :  uart_v1_0_S_AXI
generic map (
    -- width of s_axi data bus 
    C_S_AXI_DATA_WIDTH  => 32,
    -- width of s_axi address bus
    C_S_AXI_ADDR_WIDTH => 5
)
port map (
    -- users ports add here 
    -- control register 
    baud_rate => baud_rate,
    tx_fifo_rst => tx_fifo_rst,
    rx_fifo_rst => rx_fifo_rst,

    -- status register 
    tx_fifo_full => tx_fifo_full,
    tx_fifo_empty => tx_fifo_empty,
    rx_fifo_full => rx_fifo_full,
    rx_fifo_empty => rx_fifo_empty,

    -- data port register
    rx_from_fifo => rx_from_fifo,
    rx_en => rx_en,
    tx_to_fifo   => tx_to_fifo,
    tx_en => tx_en,
    -- users ports end

    -- Do not modify the port beyond this line
    -- Global Clock Signal
    S_AXI_ACLK => S_AXI_ACLK,
    S_AXI_ARESETN =>S_AXI_ARESETN,
    S_AXI_AWADDR => S_AXI_AWADDR,
    S_AXI_AWPROT => S_AXI_AWPROT,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_WDATA => S_AXI_WDATA , 
    S_AXI_WSTRB => S_AXI_WSTRB,
    S_AXI_WVALID => S_AXI_WVALID,
    S_AXI_WREADY => S_AXI_WREADY,
    S_AXI_BRESP => S_AXI_BRESP,
    S_AXI_BVALID=> S_AXI_BVALID,
    S_AXI_BREADY => S_AXI_BREADY,
    S_AXI_ARADDR => S_AXI_ARADDR,
    S_AXI_ARPROT => S_AXI_ARPROT,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_RDATA => S_AXI_RDATA,
    S_AXI_RRESP => S_AXI_RRESP,
    S_AXI_RVALID =>S_AXI_RVALID,
    S_AXI_RREADY=> S_AXI_RREADY
);

end beh; 