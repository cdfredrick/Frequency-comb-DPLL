-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Feb 21 13:45:33 2019
-- Host        : 688DDH running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim {C:/Git/Frequency-comb-DPLL/Firmware Vivado
--               Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.vhdl}
-- Design      : input_multiplier
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
`protect begin_protected
`protect version = 1
`protect encrypt_agent = "XILINX"
`protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`protect key_block
g7azmhtm6FcP7uNFjuXJjN8Z6yccOPk3SSjzvKB27peFKmnPmQmov5+YTGwYqqN9LpdyiUExk8K6
vPnJqontvQ==

`protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`protect key_block
MFrqn2K0Cr7TmQ5al162oDGiY83d+AkTWOgFyXPYrTNznygR/tx44RAp24ytphNK9p6shs2EFMg/
Qqz0l8DCWiVEoJ/T8vMpnAn7Y+poGVGS1qAR3qE2njrl81VcGBZJeFaWIudhfr/DLTuuf2T/dWDU
YpelM3KbfYNPPiPy8PU=

`protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
FZca5XZouG+/BYoQ8qrJTmnJanku4IprIWRkO6VciHehE5WehR0wsZJhfKlqLEeY1oTPA4bXaxmY
NjYkrop4EOwW8t47/hj2kFLI1OKUAE/TAhCGg/aNSOViUbB3dUomG/y+TBuDt9L6g0Arj1vb/5Pt
IChc5ZdEfRr1lJMTpFfP+5qmEH6lePPdzgPZATPB4Zrj0P6EyiEsU1FKBuAKd9iYNGiLCxVomaz0
3/RwK2Nl+/l4mc7PJt5Hso+4s1qHb4s2wD+OgbIwdH26ZkEnKVFpaLiuWQKu9uhDLGnsBMPf7XDE
p29f+mrvP9Zi/3nonA2aBKrTwR7XuH+ZYoakxA==

`protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
jP68OjlYJglq3zpmKrXOhq7Sex8XNW8fQKp4hUNmuw06OOoKhQASNTnjtyVjAIk/VXb64ViBu1ds
cNMJybDSWBhnChfJq4h9PNybShGJXxSm3NDOo5wUHKf10Eti3fSotB9rVks+tNdTEZo4O97kgfdD
G1FNOqlsYcQiShEGLLiEQ2yYtgJBxJ+jc8mFjIEfPhAYy1ElrvtFEpnhkNS2LfE7xdWOQdO/XoKK
ibeY08pgncTI3pvO6TMbXushf0AX2S7hgfk8ysZrT+0gktqFrJnyR6oljS6VVPLtRNW2vo/cC8XQ
Bzvwwt4cpSo5KLS4XxB6qClZipItck2AUEdIbQ==

`protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
o7jAZIoXlFbFtDYmtXhfRBlb07dhBb6Wp03mlT4T0FXtvccSHWhWZgc+VUNwt6TohLihOwvSipPP
XVXpGL4pUVYNdQBCVpFzhMkt6jhyUgsF5t10yI5Of6YEfQrDHigceoBukM3+/zJHPprrPQE6FUvC
wXSGhBCXnHJs1R+n4l0714w8/WftPQhlD9QGQp1qT2VARQXUKBRxcRjxe9TcLfs0P4xnN7uHu0R6
JTmV+MHmhGpetSZGx+B2Wa1MQofUPURqwE70IwBoUhdXH8+39DT5I6x2+wMY6RcVATnhNd2BCgPd
RzAhwfrcqRiU9aB+eNNdFR8ve9M2nGMmV2JxZg==

`protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`protect key_block
Cl1Dz+fZIDYEIQuUd0pSg+5jknmtX/JERd+yOZ2SRaVra/4pU/eCTjEXMzhz4VFGYB6dgUxMsGBk
nL2WNdn/uaSPpi6mNF0UHQvZik4pUkYPrnRbFveVqW8i1t95SG0RW96uD19206lWrp5U1lqc4fH7
sfKHi8ZpU3MAg0DOO0E=

`protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
Qqp76m2aV9ue8Qai7QUavb+lhRYdu/txrnwYLzwTe0vS0S2OD1vxr8VeIT3bF/ZuXlTGm4S/UCSF
bgOPp7VqEOeGNfsSPK+VpQ+foQMENCQYccwKquBDSg/sLjpPK9uuoGLBLxjw2OwsRzplVFXiPcRN
LYK1/FmCP7RJBNgmhh/ti99a+WSl6i2YIIRGocNplQlG8FXq8ZTTHd/x2Gtdf/zGvJOy/fNsos6S
Oq9yJ0rMmbGeWbri5c04gZM08pUmXBsivgOHm2IVEZZFM4SBqrsi0xa52hs2kelc3iKJcWiTvU3X
0fJP9qNFuIjXBPPZvEYwhVtIh6DwiIC2viSscQ==

`protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
B3mVhbNlTJgmONCS+KbeZ32tG6LUvXTbp2U2pQqae6mBBWsgJT88hx9dP5r8Tdu4lVYs/SADlrlV
L5gU0MQqBWoFfzb287LPtXxfuzbXI8H5qzlVR+9WueG8AHSRcmtA7X3nzbMGPmvRvcJDTNnnBvs3
XV/NtctuM9Ik1TN1GYX7zRCIEbxJJVpybU6gz+2Tc+IP+swbs9vQYgeQWr1iI3DJm7Ya3I/W2aDK
tdxEXAabp4w0qectZJ7dIJJB5MNccqX4g2ma13E1rbGey4NL//8I4n2cpwn1K+sDxM2v/Z7L8lV2
mo7PpxaUi317uvGEn0Hm64rNtjB9r9DFr7BQ0g==

`protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`protect key_block
ENoGeiBjaG8x/MicX4aj+bR81xRvmqvv1PNRW5SslmpqlzXxzzU9kwpKVMRG8JGIl9uv0v3i+weC
2Z/HQUxsId+HeREtrGQ5jN59Apg1aMXLEqY6doc6Kb99x4foSCIXhVhuSQhVQ8sYWO9ry3E4CCfL
qgLDmMEKD64uNdLtGbEX2e9eYaxI4phSYxS9N06nyd4LO+2b9VosLnaTuA8DFUd+G/X48SOLp5Mh
poQm3lSuGxrIvtDhWWbLOFcd7mKMApm6bWktNMbXjYiOXFKVdvghp9tzv+OdLdPXBxUDOFk+MDvW
+gYjKN7nQEGI8d/ImooCtqLwcbhUrDCBX/Efwg==

`protect data_method = "AES128-CBC"
`protect encoding = (enctype = "BASE64", line_length = 76, bytes = 10080)
`protect data_block
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
`protect end_protected
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity input_multiplier_mult_gen_v12_0_14 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 15 downto 0 );
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    ZERO_DETECT : out STD_LOGIC_VECTOR ( 1 downto 0 );
    P : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PCASC : out STD_LOGIC_VECTOR ( 47 downto 0 )
  );
  attribute C_A_TYPE : integer;
  attribute C_A_TYPE of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_A_WIDTH : integer;
  attribute C_A_WIDTH of input_multiplier_mult_gen_v12_0_14 : entity is 16;
  attribute C_B_TYPE : integer;
  attribute C_B_TYPE of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_B_VALUE : string;
  attribute C_B_VALUE of input_multiplier_mult_gen_v12_0_14 : entity is "10000001";
  attribute C_B_WIDTH : integer;
  attribute C_B_WIDTH of input_multiplier_mult_gen_v12_0_14 : entity is 16;
  attribute C_CCM_IMP : integer;
  attribute C_CCM_IMP of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_CE_OVERRIDES_SCLR : integer;
  attribute C_CE_OVERRIDES_SCLR of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_HAS_ZERO_DETECT : integer;
  attribute C_HAS_ZERO_DETECT of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_LATENCY : integer;
  attribute C_LATENCY of input_multiplier_mult_gen_v12_0_14 : entity is 1;
  attribute C_MODEL_TYPE : integer;
  attribute C_MODEL_TYPE of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_MULT_TYPE : integer;
  attribute C_MULT_TYPE of input_multiplier_mult_gen_v12_0_14 : entity is 1;
  attribute C_OPTIMIZE_GOAL : integer;
  attribute C_OPTIMIZE_GOAL of input_multiplier_mult_gen_v12_0_14 : entity is 1;
  attribute C_OUT_HIGH : integer;
  attribute C_OUT_HIGH of input_multiplier_mult_gen_v12_0_14 : entity is 31;
  attribute C_OUT_LOW : integer;
  attribute C_OUT_LOW of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_ROUND_OUTPUT : integer;
  attribute C_ROUND_OUTPUT of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_ROUND_PT : integer;
  attribute C_ROUND_PT of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_VERBOSITY : integer;
  attribute C_VERBOSITY of input_multiplier_mult_gen_v12_0_14 : entity is 0;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of input_multiplier_mult_gen_v12_0_14 : entity is "zynq";
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of input_multiplier_mult_gen_v12_0_14 : entity is "mult_gen_v12_0_14";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of input_multiplier_mult_gen_v12_0_14 : entity is "yes";
end input_multiplier_mult_gen_v12_0_14;

architecture STRUCTURE of input_multiplier_mult_gen_v12_0_14 is
  signal \<const0>\ : STD_LOGIC;
  signal NLW_i_mult_PCASC_UNCONNECTED : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal NLW_i_mult_ZERO_DETECT_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_A_TYPE of i_mult : label is 0;
  attribute C_A_WIDTH of i_mult : label is 16;
  attribute C_B_TYPE of i_mult : label is 0;
  attribute C_B_VALUE of i_mult : label is "10000001";
  attribute C_B_WIDTH of i_mult : label is 16;
  attribute C_CCM_IMP of i_mult : label is 0;
  attribute C_CE_OVERRIDES_SCLR of i_mult : label is 0;
  attribute C_HAS_CE of i_mult : label is 0;
  attribute C_HAS_SCLR of i_mult : label is 0;
  attribute C_HAS_ZERO_DETECT of i_mult : label is 0;
  attribute C_LATENCY of i_mult : label is 1;
  attribute C_MODEL_TYPE of i_mult : label is 0;
  attribute C_MULT_TYPE of i_mult : label is 1;
  attribute C_OPTIMIZE_GOAL of i_mult : label is 1;
  attribute C_OUT_HIGH of i_mult : label is 31;
  attribute C_OUT_LOW of i_mult : label is 0;
  attribute C_ROUND_OUTPUT of i_mult : label is 0;
  attribute C_ROUND_PT of i_mult : label is 0;
  attribute C_VERBOSITY of i_mult : label is 0;
  attribute C_XDEVICEFAMILY of i_mult : label is "zynq";
  attribute downgradeipidentifiedwarnings of i_mult : label is "yes";
begin
  PCASC(47) <= \<const0>\;
  PCASC(46) <= \<const0>\;
  PCASC(45) <= \<const0>\;
  PCASC(44) <= \<const0>\;
  PCASC(43) <= \<const0>\;
  PCASC(42) <= \<const0>\;
  PCASC(41) <= \<const0>\;
  PCASC(40) <= \<const0>\;
  PCASC(39) <= \<const0>\;
  PCASC(38) <= \<const0>\;
  PCASC(37) <= \<const0>\;
  PCASC(36) <= \<const0>\;
  PCASC(35) <= \<const0>\;
  PCASC(34) <= \<const0>\;
  PCASC(33) <= \<const0>\;
  PCASC(32) <= \<const0>\;
  PCASC(31) <= \<const0>\;
  PCASC(30) <= \<const0>\;
  PCASC(29) <= \<const0>\;
  PCASC(28) <= \<const0>\;
  PCASC(27) <= \<const0>\;
  PCASC(26) <= \<const0>\;
  PCASC(25) <= \<const0>\;
  PCASC(24) <= \<const0>\;
  PCASC(23) <= \<const0>\;
  PCASC(22) <= \<const0>\;
  PCASC(21) <= \<const0>\;
  PCASC(20) <= \<const0>\;
  PCASC(19) <= \<const0>\;
  PCASC(18) <= \<const0>\;
  PCASC(17) <= \<const0>\;
  PCASC(16) <= \<const0>\;
  PCASC(15) <= \<const0>\;
  PCASC(14) <= \<const0>\;
  PCASC(13) <= \<const0>\;
  PCASC(12) <= \<const0>\;
  PCASC(11) <= \<const0>\;
  PCASC(10) <= \<const0>\;
  PCASC(9) <= \<const0>\;
  PCASC(8) <= \<const0>\;
  PCASC(7) <= \<const0>\;
  PCASC(6) <= \<const0>\;
  PCASC(5) <= \<const0>\;
  PCASC(4) <= \<const0>\;
  PCASC(3) <= \<const0>\;
  PCASC(2) <= \<const0>\;
  PCASC(1) <= \<const0>\;
  PCASC(0) <= \<const0>\;
  ZERO_DETECT(1) <= \<const0>\;
  ZERO_DETECT(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
i_mult: entity work.input_multiplier_mult_gen_v12_0_14_viv
     port map (
      A(15 downto 0) => A(15 downto 0),
      B(15 downto 0) => B(15 downto 0),
      CE => '0',
      CLK => CLK,
      P(31 downto 0) => P(31 downto 0),
      PCASC(47 downto 0) => NLW_i_mult_PCASC_UNCONNECTED(47 downto 0),
      SCLR => '0',
      ZERO_DETECT(1 downto 0) => NLW_i_mult_ZERO_DETECT_UNCONNECTED(1 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity input_multiplier is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 15 downto 0 );
    P : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of input_multiplier : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of input_multiplier : entity is "input_multiplier,mult_gen_v12_0_14,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of input_multiplier : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of input_multiplier : entity is "mult_gen_v12_0_14,Vivado 2018.3";
end input_multiplier;

architecture STRUCTURE of input_multiplier is
  signal NLW_U0_PCASC_UNCONNECTED : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal NLW_U0_ZERO_DETECT_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_A_TYPE : integer;
  attribute C_A_TYPE of U0 : label is 0;
  attribute C_A_WIDTH : integer;
  attribute C_A_WIDTH of U0 : label is 16;
  attribute C_B_TYPE : integer;
  attribute C_B_TYPE of U0 : label is 0;
  attribute C_B_VALUE : string;
  attribute C_B_VALUE of U0 : label is "10000001";
  attribute C_B_WIDTH : integer;
  attribute C_B_WIDTH of U0 : label is 16;
  attribute C_CCM_IMP : integer;
  attribute C_CCM_IMP of U0 : label is 0;
  attribute C_CE_OVERRIDES_SCLR : integer;
  attribute C_CE_OVERRIDES_SCLR of U0 : label is 0;
  attribute C_HAS_CE : integer;
  attribute C_HAS_CE of U0 : label is 0;
  attribute C_HAS_SCLR : integer;
  attribute C_HAS_SCLR of U0 : label is 0;
  attribute C_HAS_ZERO_DETECT : integer;
  attribute C_HAS_ZERO_DETECT of U0 : label is 0;
  attribute C_LATENCY : integer;
  attribute C_LATENCY of U0 : label is 1;
  attribute C_MODEL_TYPE : integer;
  attribute C_MODEL_TYPE of U0 : label is 0;
  attribute C_MULT_TYPE : integer;
  attribute C_MULT_TYPE of U0 : label is 1;
  attribute C_OPTIMIZE_GOAL : integer;
  attribute C_OPTIMIZE_GOAL of U0 : label is 1;
  attribute C_OUT_HIGH : integer;
  attribute C_OUT_HIGH of U0 : label is 31;
  attribute C_OUT_LOW : integer;
  attribute C_OUT_LOW of U0 : label is 0;
  attribute C_ROUND_OUTPUT : integer;
  attribute C_ROUND_OUTPUT of U0 : label is 0;
  attribute C_ROUND_PT : integer;
  attribute C_ROUND_PT of U0 : label is 0;
  attribute C_VERBOSITY : integer;
  attribute C_VERBOSITY of U0 : label is 0;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of U0 : label is "zynq";
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
  attribute x_interface_info : string;
  attribute x_interface_info of CLK : signal is "xilinx.com:signal:clock:1.0 clk_intf CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of CLK : signal is "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0";
  attribute x_interface_info of A : signal is "xilinx.com:signal:data:1.0 a_intf DATA";
  attribute x_interface_parameter of A : signal is "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef";
  attribute x_interface_info of B : signal is "xilinx.com:signal:data:1.0 b_intf DATA";
  attribute x_interface_parameter of B : signal is "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef";
  attribute x_interface_info of P : signal is "xilinx.com:signal:data:1.0 p_intf DATA";
  attribute x_interface_parameter of P : signal is "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef";
begin
U0: entity work.input_multiplier_mult_gen_v12_0_14
     port map (
      A(15 downto 0) => A(15 downto 0),
      B(15 downto 0) => B(15 downto 0),
      CE => '1',
      CLK => CLK,
      P(31 downto 0) => P(31 downto 0),
      PCASC(47 downto 0) => NLW_U0_PCASC_UNCONNECTED(47 downto 0),
      SCLR => '0',
      ZERO_DETECT(1 downto 0) => NLW_U0_ZERO_DETECT_UNCONNECTED(1 downto 0)
    );
end STRUCTURE;
