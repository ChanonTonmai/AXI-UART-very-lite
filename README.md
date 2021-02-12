# AXI UART very lite
This core builds for learning the UART communication and AXI interface. The target hardware can be all kind from zynq platform due to the AXI interface. The purpose of this is just read and write the data to UART through AXI interface.  

## The folder are consists of 
- src : The whole VHDL src 
- sdk : The example C project correspond with the core
- bd : The tcl script for create block design with vivado 2018.2 

## The VHDL code are list here: 
- axi_uart_top.vhd : the highest file here consist of AXI interface and the serial i/o. 
  - axi_test.vhd : the AXI interface for write and read register. 
  - uart_fifo.vhd : the UART core with fifo. The rest of here is the component in this file. 
  
The uart_tx and uart_rx is reference from nandland.com. 
  
