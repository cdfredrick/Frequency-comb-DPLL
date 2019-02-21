// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Feb 21 13:44:43 2019
// Host        : 688DDH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Git/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_stub.v}
// Design      : pll_wide_mult
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_14,Vivado 2018.3" *)
module pll_wide_mult(CLK, A, B, SCLR, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[9:0],B[31:0],SCLR,P[41:0]" */;
  input CLK;
  input [9:0]A;
  input [31:0]B;
  input SCLR;
  output [41:0]P;
endmodule
