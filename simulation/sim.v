`timescale 1ns / 1ps

//import axi4stream_vip_v1_0_0_pkg::*;
//import ex_sim_axi4stream_vip_mst_0_pkg::*;
//import ex_sim_axi4stream_vip_slv_0_pkg::*;
//import ex_sim_axi4stream_vip_passthrough_0_pkg::*;

module tb;
    reg tb_ACLK;
    reg tb_ARESETn;

    wire temp_clk;
    wire temp_rstn; 
    wire tx_serial; 
    wire rx_serial; 
    
    reg resp;
    
    reg [31:0] read_data;
    
    initial 
    begin       
        tb_ACLK = 1'b0;
    end

    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------
    
    always #5 tb_ACLK = !tb_ACLK;

    initial
    begin
    
        $display ("running the tb");
        
        tb_ARESETn = 1'b0;
        repeat(20)@(posedge tb_ACLK);        
        tb_ARESETn = 1'b1;
        @(posedge tb_ACLK);
        

        
        //Reset the PL
         #10 tb.zynq_sys.design_2_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
         #10 tb.zynq_sys.design_2_i.processing_system7_0.inst.fpga_soft_reset(32'h0);
         
         
        tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h43C00008, 4, 32'h00000001, resp);
        tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h43C10008, 4, 32'h00000001, resp);
        
        #10000
        tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h43C10004, 4, 32'h000000AB, resp); 
        #100 tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h43C10004, 4, 32'h000000AB, resp); 
        #100 tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h43C10004, 4, 32'h000000AB, resp); 
//        //tb.zynq_sys.design_2_i.processing_system7_0.inst.read_data(32'h43C00010, 4, read_data, resp);
      
//        #10000000
//        #100 tb.zynq_sys.design_2_i.processing_system7_0.inst.read_data(32'h43C10000, 4, read_data, resp);
//        #100 tb.zynq_sys.design_2_i.processing_system7_0.inst.read_data(32'h43C10000, 4, read_data, resp);
//        #100 tb.zynq_sys.design_2_i.processing_system7_0.inst.read_data(32'h43C10000, 4, read_data, resp);
        
      
        $display ("Simulation completed");
      // $stop;
    end
        assign temp_clk = tb_ACLK;
        assign temp_rstn = tb_ARESETn;
        
  design_2_wrapper zynq_sys
             (.DDR_0_addr(),
              .DDR_0_ba(),
              .DDR_0_cas_n(),
              .DDR_0_ck_n(),
              .DDR_0_ck_p(),
              .DDR_0_cke(),
              .DDR_0_cs_n(),
              .DDR_0_dm(),
              .DDR_0_dq(),
              .DDR_0_dqs_n(),
              .DDR_0_dqs_p(),
              .DDR_0_odt(),
              .DDR_0_ras_n(),
              .DDR_0_reset_n(),
              .DDR_0_we_n(),
              .FIXED_IO_0_ddr_vrn(),
              .FIXED_IO_0_ddr_vrp(),
              .FIXED_IO_0_mio(),
              .FIXED_IO_0_ps_clk(temp_clk),
              .FIXED_IO_0_ps_porb(temp_rstn),
              .FIXED_IO_0_ps_srstb(temp_rstn),
              .i_serial_0(rx_serial),
              .o_serial_0(tx_serial));
//   design_2_wrapper zynq_sys
//       (.DDR_0_addr(),
//        .DDR_0_ba(),
//        .DDR_0_cas_n(),
//        .DDR_0_ck_n(),
//        .DDR_0_ck_p(),
//        .DDR_0_cke(),
//        .DDR_0_cs_n(),
//        .DDR_0_dm(),
//        .DDR_0_dq(),
//        .DDR_0_dqs_n(),
//        .DDR_0_dqs_p(),
//        .DDR_0_odt(),
//        .DDR_0_ras_n(),
//        .DDR_0_reset_n(),
//        .DDR_0_we_n(),
//        .FIXED_IO_0_ddr_vrn(),
//        .FIXED_IO_0_ddr_vrp(),
//        .FIXED_IO_0_mio(),
//        .FIXED_IO_0_ps_clk(temp_clk),
//        .FIXED_IO_0_ps_porb(temp_rstn),
//        .FIXED_IO_0_ps_srstb(temp_rstn),
//        .i_serial_0(rx_serial),
//        .o_serial_0(tx_serial));
//  design_1_wrapper zynq_sys
//         (.DDR_0_addr(),
//          .DDR_0_ba(),
//          .DDR_0_cas_n(),
//          .DDR_0_ck_n(),
//          .DDR_0_ck_p(),
//          .DDR_0_cke(),
//          .DDR_0_cs_n(),
//          .DDR_0_dm(),
//          .DDR_0_dq(),
//          .DDR_0_dqs_n(),
//          .DDR_0_dqs_p(),
//          .DDR_0_odt(),
//          .DDR_0_ras_n(),
//          .DDR_0_reset_n(),
//          .DDR_0_we_n(),
//          .FIXED_IO_0_ddr_vrn(),
//          .FIXED_IO_0_ddr_vrp(),
//          .FIXED_IO_0_mio(),
//          .FIXED_IO_0_ps_clk(temp_clk),
//          .FIXED_IO_0_ps_porb(temp_rstn),
//          .FIXED_IO_0_ps_srstb(temp_rstn),
//          .tx_serial(tx_serial), 
//          .rx_serial(rx_serial));
endmodule