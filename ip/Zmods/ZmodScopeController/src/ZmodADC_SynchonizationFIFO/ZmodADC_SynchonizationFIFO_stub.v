// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Thu Jan 20 16:40:35 2022
// Host        : balas-ro-TP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Workspace/Vivado/eclypse_z7/hw/repo/vivado-library/ip/Zmods/ZmodScopeController/src/ZmodADC_SynchonizationFIFO/ZmodADC_SynchonizationFIFO_stub.v
// Design      : ZmodADC_SynchonizationFIFO
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2021.1" *)
module ZmodADC_SynchonizationFIFO(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  overflow, empty, valid)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[31:0],wr_en,rd_en,dout[31:0],full,overflow,empty,valid" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [31:0]din;
  input wr_en;
  input rd_en;
  output [31:0]dout;
  output full;
  output overflow;
  output empty;
  output valid;
endmodule
