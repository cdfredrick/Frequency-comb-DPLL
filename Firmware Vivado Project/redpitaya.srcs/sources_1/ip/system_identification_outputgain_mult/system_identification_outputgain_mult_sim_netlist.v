// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Feb 21 13:44:41 2019
// Host        : 688DDH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {C:/Git/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_sim_netlist.v}
// Design      : system_identification_outputgain_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_identification_outputgain_mult,mult_gen_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_14,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module system_identification_outputgain_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [17:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [15:0]P;

  wire [15:0]A;
  wire [17:0]B;
  wire CLK;
  wire [15:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_14 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "2" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "30" *) 
(* C_OUT_LOW = "15" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_14" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module system_identification_outputgain_mult_mult_gen_v12_0_14
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [15:0]A;
  input [17:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [15:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [15:0]A;
  wire [17:0]B;
  wire CLK;
  wire [15:0]P;
  wire SCLR;
  wire [47:0]NLW_i_mult_PCASC_UNCONNECTED;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign PCASC[47] = \<const0> ;
  assign PCASC[46] = \<const0> ;
  assign PCASC[45] = \<const0> ;
  assign PCASC[44] = \<const0> ;
  assign PCASC[43] = \<const0> ;
  assign PCASC[42] = \<const0> ;
  assign PCASC[41] = \<const0> ;
  assign PCASC[40] = \<const0> ;
  assign PCASC[39] = \<const0> ;
  assign PCASC[38] = \<const0> ;
  assign PCASC[37] = \<const0> ;
  assign PCASC[36] = \<const0> ;
  assign PCASC[35] = \<const0> ;
  assign PCASC[34] = \<const0> ;
  assign PCASC[33] = \<const0> ;
  assign PCASC[32] = \<const0> ;
  assign PCASC[31] = \<const0> ;
  assign PCASC[30] = \<const0> ;
  assign PCASC[29] = \<const0> ;
  assign PCASC[28] = \<const0> ;
  assign PCASC[27] = \<const0> ;
  assign PCASC[26] = \<const0> ;
  assign PCASC[25] = \<const0> ;
  assign PCASC[24] = \<const0> ;
  assign PCASC[23] = \<const0> ;
  assign PCASC[22] = \<const0> ;
  assign PCASC[21] = \<const0> ;
  assign PCASC[20] = \<const0> ;
  assign PCASC[19] = \<const0> ;
  assign PCASC[18] = \<const0> ;
  assign PCASC[17] = \<const0> ;
  assign PCASC[16] = \<const0> ;
  assign PCASC[15] = \<const0> ;
  assign PCASC[14] = \<const0> ;
  assign PCASC[13] = \<const0> ;
  assign PCASC[12] = \<const0> ;
  assign PCASC[11] = \<const0> ;
  assign PCASC[10] = \<const0> ;
  assign PCASC[9] = \<const0> ;
  assign PCASC[8] = \<const0> ;
  assign PCASC[7] = \<const0> ;
  assign PCASC[6] = \<const0> ;
  assign PCASC[5] = \<const0> ;
  assign PCASC[4] = \<const0> ;
  assign PCASC[3] = \<const0> ;
  assign PCASC[2] = \<const0> ;
  assign PCASC[1] = \<const0> ;
  assign PCASC[0] = \<const0> ;
  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_14_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_i_mult_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
g7azmhtm6FcP7uNFjuXJjN8Z6yccOPk3SSjzvKB27peFKmnPmQmov5+YTGwYqqN9LpdyiUExk8K6
vPnJqontvQ==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
MFrqn2K0Cr7TmQ5al162oDGiY83d+AkTWOgFyXPYrTNznygR/tx44RAp24ytphNK9p6shs2EFMg/
Qqz0l8DCWiVEoJ/T8vMpnAn7Y+poGVGS1qAR3qE2njrl81VcGBZJeFaWIudhfr/DLTuuf2T/dWDU
YpelM3KbfYNPPiPy8PU=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FZca5XZouG+/BYoQ8qrJTmnJanku4IprIWRkO6VciHehE5WehR0wsZJhfKlqLEeY1oTPA4bXaxmY
NjYkrop4EOwW8t47/hj2kFLI1OKUAE/TAhCGg/aNSOViUbB3dUomG/y+TBuDt9L6g0Arj1vb/5Pt
IChc5ZdEfRr1lJMTpFfP+5qmEH6lePPdzgPZATPB4Zrj0P6EyiEsU1FKBuAKd9iYNGiLCxVomaz0
3/RwK2Nl+/l4mc7PJt5Hso+4s1qHb4s2wD+OgbIwdH26ZkEnKVFpaLiuWQKu9uhDLGnsBMPf7XDE
p29f+mrvP9Zi/3nonA2aBKrTwR7XuH+ZYoakxA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jP68OjlYJglq3zpmKrXOhq7Sex8XNW8fQKp4hUNmuw06OOoKhQASNTnjtyVjAIk/VXb64ViBu1ds
cNMJybDSWBhnChfJq4h9PNybShGJXxSm3NDOo5wUHKf10Eti3fSotB9rVks+tNdTEZo4O97kgfdD
G1FNOqlsYcQiShEGLLiEQ2yYtgJBxJ+jc8mFjIEfPhAYy1ElrvtFEpnhkNS2LfE7xdWOQdO/XoKK
ibeY08pgncTI3pvO6TMbXushf0AX2S7hgfk8ysZrT+0gktqFrJnyR6oljS6VVPLtRNW2vo/cC8XQ
Bzvwwt4cpSo5KLS4XxB6qClZipItck2AUEdIbQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
o7jAZIoXlFbFtDYmtXhfRBlb07dhBb6Wp03mlT4T0FXtvccSHWhWZgc+VUNwt6TohLihOwvSipPP
XVXpGL4pUVYNdQBCVpFzhMkt6jhyUgsF5t10yI5Of6YEfQrDHigceoBukM3+/zJHPprrPQE6FUvC
wXSGhBCXnHJs1R+n4l0714w8/WftPQhlD9QGQp1qT2VARQXUKBRxcRjxe9TcLfs0P4xnN7uHu0R6
JTmV+MHmhGpetSZGx+B2Wa1MQofUPURqwE70IwBoUhdXH8+39DT5I6x2+wMY6RcVATnhNd2BCgPd
RzAhwfrcqRiU9aB+eNNdFR8ve9M2nGMmV2JxZg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Cl1Dz+fZIDYEIQuUd0pSg+5jknmtX/JERd+yOZ2SRaVra/4pU/eCTjEXMzhz4VFGYB6dgUxMsGBk
nL2WNdn/uaSPpi6mNF0UHQvZik4pUkYPrnRbFveVqW8i1t95SG0RW96uD19206lWrp5U1lqc4fH7
sfKHi8ZpU3MAg0DOO0E=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Qqp76m2aV9ue8Qai7QUavb+lhRYdu/txrnwYLzwTe0vS0S2OD1vxr8VeIT3bF/ZuXlTGm4S/UCSF
bgOPp7VqEOeGNfsSPK+VpQ+foQMENCQYccwKquBDSg/sLjpPK9uuoGLBLxjw2OwsRzplVFXiPcRN
LYK1/FmCP7RJBNgmhh/ti99a+WSl6i2YIIRGocNplQlG8FXq8ZTTHd/x2Gtdf/zGvJOy/fNsos6S
Oq9yJ0rMmbGeWbri5c04gZM08pUmXBsivgOHm2IVEZZFM4SBqrsi0xa52hs2kelc3iKJcWiTvU3X
0fJP9qNFuIjXBPPZvEYwhVtIh6DwiIC2viSscQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XD97DPF2/U2Og0+f3tlgH0bbVfqvwVqK7D9Sb8fD2Zu3UU2hcV0+jDpLNomICX/zKU8JDGxqDfHK
a/1GGL/7AgAa7x099coC8zdDri8pdvlBDo3CFbi2I3oN9Te6acgpTGOuUDakfabX90qCmtL+e98/
8xosUpIUTMlW1uOfXOMJaqeCaDe7eAqlZL4hsGHVoFZJfuN4D3vJ+VeazXPbukmDc/xIWazw2Ytx
lg/suw0vz0e4Yvq1gRUvHZsgsJYt6n4vYgWP7XEzedAtFWbUnOVDEV8fTAevgwKDEkzZ6YPGx2BH
cFsZkBKuMsEX/pSLAnfZt4G8C6emR+kMJG5klw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
S/EjJzuF+aMVUsFw+7uIaKlPsX965hWw+SVUI4lajuA/oljoyYjva1qIaxLYqgqkZ51DMA8z3oHm
SHMMmDcarGsEf9MrwPAI/ZtNH9D2x4WCLUoh93YWJZ0waTjgn3tpvUuMe88sDLZVvOEQNTyxupJl
qlkMb8tyJ+VvSbDCZjJTC8rh1Uj/zS6sO70cyQCZ4qRJzaxQ/PxmoaeX/kONt1UrU6a1kGsmx5hH
ebtFyqebxJCaEjJMAz5qqk6Wd0xryHEFrnPXLp7kzm7tYdIYX3pdUuhXs36fc1opfokx06SQ/jSW
WrKOBRHHqdFEynl8naAUoHNX+X3a+zPmnCpHZQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
kw==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
