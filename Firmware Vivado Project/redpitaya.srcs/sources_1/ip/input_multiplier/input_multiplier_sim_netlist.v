// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Feb 21 13:45:33 2019
// Host        : 688DDH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {C:/Git/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.v}
// Design      : input_multiplier
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "input_multiplier,mult_gen_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_14,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module input_multiplier
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [31:0]P;

  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [31:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "31" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  input_multiplier_mult_gen_v12_0_14 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "16" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "1" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "31" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_14" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module input_multiplier_mult_gen_v12_0_14
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
  input [15:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [31:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [31:0]P;
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
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "31" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  input_multiplier_mult_gen_v12_0_14_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_i_mult_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
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
SB56ZwAeusrZHqGzc1vUC4jztmVyHNZRO9FgQIWOan7eWvafSfwOTi7k2b+67YxpGzUvivQuL5cf
lSkuUttQRamnzxucOb6jKJAJ+UQ6kiKDcYsqqvz4sX+qD7HkKilL/OLMC9bK6GEWXpLs3luUYQX5
BwFmyr5AjNaltmzw95pMQrfNkH7M+0gs18t0SKocZUtJnSc6Zz8x/OC3gAp12Fqw9ALokMTjUr+S
0UF9ptjHRp3LTE2ienYxPJ8tMJ8gl5lsE72S/0Ta8Q79LrAq+Z06EnWPIdeUlYdmdVIcmQ7ktGTJ
CG7iJarhMIKfnqVUVadiH4Qtg/6v+tndjYv/8A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hn2HFCNgpsaUDrOu4LJUYzArV3Py5iQ6z8waNpGnUWGuBZdSlH3XBADJwAiKNlyYLdnTvBNc3h7j
YA42jtfoLrzJOnV+0ukLNoLnzFjt9mFsVwcfY6hduPDnZJxMyWb/RszYearUcw1m4XyrEp7LjVgN
kKI0XJGyUSyRup05k1mZvozCFD0QdllXQPovs6vIdtNyhbvvLkdIESAdWxbEB/bd/wXwjMFnrl6q
JDWGNPbdr93pCpUsoMiX6SHN8bcTYs+l+kd/SSAwn2hP6ghlgT2LuDW3KNI6YmUFam91UKR3o/cs
BGYGAG4YSlVdSl09Is+qV/VH/39Batw0LPTZjw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
Qp7Si2lJCQdP
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
