//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sat Mar  2 21:13:38 2019
//Host        : 688DDH running 64-bit major release  (build 9200)
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=5,numReposBlks=5,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "system.hwdef" *) 
module system
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FCLK_CLK0,
    FCLK_CLK1,
    FCLK_CLK2,
    FCLK_CLK3,
    FCLK_RESET0_N,
    FCLK_RESET1_N,
    FCLK_RESET2_N,
    FCLK_RESET3_N,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M_AXI_GP0_ACLK,
    M_AXI_GP0_araddr,
    M_AXI_GP0_arburst,
    M_AXI_GP0_arcache,
    M_AXI_GP0_arid,
    M_AXI_GP0_arlen,
    M_AXI_GP0_arlock,
    M_AXI_GP0_arprot,
    M_AXI_GP0_arqos,
    M_AXI_GP0_arready,
    M_AXI_GP0_arsize,
    M_AXI_GP0_arvalid,
    M_AXI_GP0_awaddr,
    M_AXI_GP0_awburst,
    M_AXI_GP0_awcache,
    M_AXI_GP0_awid,
    M_AXI_GP0_awlen,
    M_AXI_GP0_awlock,
    M_AXI_GP0_awprot,
    M_AXI_GP0_awqos,
    M_AXI_GP0_awready,
    M_AXI_GP0_awsize,
    M_AXI_GP0_awvalid,
    M_AXI_GP0_bid,
    M_AXI_GP0_bready,
    M_AXI_GP0_bresp,
    M_AXI_GP0_bvalid,
    M_AXI_GP0_rdata,
    M_AXI_GP0_rid,
    M_AXI_GP0_rlast,
    M_AXI_GP0_rready,
    M_AXI_GP0_rresp,
    M_AXI_GP0_rvalid,
    M_AXI_GP0_wdata,
    M_AXI_GP0_wid,
    M_AXI_GP0_wlast,
    M_AXI_GP0_wready,
    M_AXI_GP0_wstrb,
    M_AXI_GP0_wvalid,
    S_AXI_HP0_aclk,
    S_AXI_HP0_araddr,
    S_AXI_HP0_arburst,
    S_AXI_HP0_arcache,
    S_AXI_HP0_arid,
    S_AXI_HP0_arlen,
    S_AXI_HP0_arlock,
    S_AXI_HP0_arprot,
    S_AXI_HP0_arqos,
    S_AXI_HP0_arready,
    S_AXI_HP0_arsize,
    S_AXI_HP0_arvalid,
    S_AXI_HP0_awaddr,
    S_AXI_HP0_awburst,
    S_AXI_HP0_awcache,
    S_AXI_HP0_awid,
    S_AXI_HP0_awlen,
    S_AXI_HP0_awlock,
    S_AXI_HP0_awprot,
    S_AXI_HP0_awqos,
    S_AXI_HP0_awready,
    S_AXI_HP0_awsize,
    S_AXI_HP0_awvalid,
    S_AXI_HP0_bid,
    S_AXI_HP0_bready,
    S_AXI_HP0_bresp,
    S_AXI_HP0_bvalid,
    S_AXI_HP0_rdata,
    S_AXI_HP0_rid,
    S_AXI_HP0_rlast,
    S_AXI_HP0_rready,
    S_AXI_HP0_rresp,
    S_AXI_HP0_rvalid,
    S_AXI_HP0_wdata,
    S_AXI_HP0_wid,
    S_AXI_HP0_wlast,
    S_AXI_HP0_wready,
    S_AXI_HP0_wstrb,
    S_AXI_HP0_wvalid,
    S_AXI_HP1_aclk,
    S_AXI_HP1_araddr,
    S_AXI_HP1_arburst,
    S_AXI_HP1_arcache,
    S_AXI_HP1_arid,
    S_AXI_HP1_arlen,
    S_AXI_HP1_arlock,
    S_AXI_HP1_arprot,
    S_AXI_HP1_arqos,
    S_AXI_HP1_arready,
    S_AXI_HP1_arsize,
    S_AXI_HP1_arvalid,
    S_AXI_HP1_awaddr,
    S_AXI_HP1_awburst,
    S_AXI_HP1_awcache,
    S_AXI_HP1_awid,
    S_AXI_HP1_awlen,
    S_AXI_HP1_awlock,
    S_AXI_HP1_awprot,
    S_AXI_HP1_awqos,
    S_AXI_HP1_awready,
    S_AXI_HP1_awsize,
    S_AXI_HP1_awvalid,
    S_AXI_HP1_bid,
    S_AXI_HP1_bready,
    S_AXI_HP1_bresp,
    S_AXI_HP1_bvalid,
    S_AXI_HP1_rdata,
    S_AXI_HP1_rid,
    S_AXI_HP1_rlast,
    S_AXI_HP1_rready,
    S_AXI_HP1_rresp,
    S_AXI_HP1_rvalid,
    S_AXI_HP1_wdata,
    S_AXI_HP1_wid,
    S_AXI_HP1_wlast,
    S_AXI_HP1_wready,
    S_AXI_HP1_wstrb,
    S_AXI_HP1_wvalid,
    Vaux0_v_n,
    Vaux0_v_p,
    Vaux1_v_n,
    Vaux1_v_p,
    Vaux8_v_n,
    Vaux8_v_p,
    Vaux9_v_n,
    Vaux9_v_p,
    Vp_Vn_v_n,
    Vp_Vn_v_p);
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) inout [14:0]DDR_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR BA" *) inout [2:0]DDR_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CAS_N" *) inout DDR_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_N" *) inout DDR_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_P" *) inout DDR_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CKE" *) inout DDR_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CS_N" *) inout DDR_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DM" *) inout [3:0]DDR_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQ" *) inout [31:0]DDR_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_N" *) inout [3:0]DDR_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_P" *) inout [3:0]DDR_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ODT" *) inout DDR_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RAS_N" *) inout DDR_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RESET_N" *) inout DDR_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR WE_N" *) inout DDR_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FCLK_CLK0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FCLK_CLK0, CLK_DOMAIN system_processing_system7_0_FCLK_CLK0, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) output FCLK_CLK0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FCLK_CLK1 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FCLK_CLK1, CLK_DOMAIN system_processing_system7_0_FCLK_CLK1, FREQ_HZ 250000000, INSERT_VIP 0, PHASE 0.000" *) output FCLK_CLK1;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FCLK_CLK2 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FCLK_CLK2, CLK_DOMAIN system_processing_system7_0_FCLK_CLK2, FREQ_HZ 50000000, INSERT_VIP 0, PHASE 0.000" *) output FCLK_CLK2;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FCLK_CLK3 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FCLK_CLK3, CLK_DOMAIN system_processing_system7_0_FCLK_CLK3, FREQ_HZ 200000000, INSERT_VIP 0, PHASE 0.000" *) output FCLK_CLK3;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.FCLK_RESET0_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.FCLK_RESET0_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output FCLK_RESET0_N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.FCLK_RESET1_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.FCLK_RESET1_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output FCLK_RESET1_N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.FCLK_RESET2_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.FCLK_RESET2_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output FCLK_RESET2_N;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.FCLK_RESET3_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.FCLK_RESET3_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output FCLK_RESET3_N;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false" *) inout FIXED_IO_ddr_vrn;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP" *) inout FIXED_IO_ddr_vrp;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO" *) inout [53:0]FIXED_IO_mio;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK" *) inout FIXED_IO_ps_clk;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB" *) inout FIXED_IO_ps_porb;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB" *) inout FIXED_IO_ps_srstb;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.M_AXI_GP0_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.M_AXI_GP0_ACLK, ASSOCIATED_BUSIF M_AXI_GP0, CLK_DOMAIN system_M_AXI_GP0_ACLK, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) input M_AXI_GP0_ACLK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_GP0, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN system_M_AXI_GP0_ACLK, DATA_WIDTH 32, FREQ_HZ 125000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 12, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 8, NUM_READ_THREADS 4, NUM_WRITE_OUTSTANDING 8, NUM_WRITE_THREADS 4, PHASE 0.000, PROTOCOL AXI3, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]M_AXI_GP0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARBURST" *) output [1:0]M_AXI_GP0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARCACHE" *) output [3:0]M_AXI_GP0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARID" *) output [11:0]M_AXI_GP0_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARLEN" *) output [3:0]M_AXI_GP0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARLOCK" *) output [1:0]M_AXI_GP0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARPROT" *) output [2:0]M_AXI_GP0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARQOS" *) output [3:0]M_AXI_GP0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARREADY" *) input M_AXI_GP0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARSIZE" *) output [2:0]M_AXI_GP0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 ARVALID" *) output M_AXI_GP0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWADDR" *) output [31:0]M_AXI_GP0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWBURST" *) output [1:0]M_AXI_GP0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWCACHE" *) output [3:0]M_AXI_GP0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWID" *) output [11:0]M_AXI_GP0_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWLEN" *) output [3:0]M_AXI_GP0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWLOCK" *) output [1:0]M_AXI_GP0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWPROT" *) output [2:0]M_AXI_GP0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWQOS" *) output [3:0]M_AXI_GP0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWREADY" *) input M_AXI_GP0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWSIZE" *) output [2:0]M_AXI_GP0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 AWVALID" *) output M_AXI_GP0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 BID" *) input [11:0]M_AXI_GP0_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 BREADY" *) output M_AXI_GP0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 BRESP" *) input [1:0]M_AXI_GP0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 BVALID" *) input M_AXI_GP0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RDATA" *) input [31:0]M_AXI_GP0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RID" *) input [11:0]M_AXI_GP0_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RLAST" *) input M_AXI_GP0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RREADY" *) output M_AXI_GP0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RRESP" *) input [1:0]M_AXI_GP0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 RVALID" *) input M_AXI_GP0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WDATA" *) output [31:0]M_AXI_GP0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WID" *) output [11:0]M_AXI_GP0_wid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WLAST" *) output M_AXI_GP0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WREADY" *) input M_AXI_GP0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WSTRB" *) output [3:0]M_AXI_GP0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_GP0 WVALID" *) output M_AXI_GP0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_HP0_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_HP0_ACLK, ASSOCIATED_BUSIF S_AXI_HP0, CLK_DOMAIN system_S_AXI_HP0_aclk, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) input S_AXI_HP0_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_HP0, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN system_S_AXI_HP0_aclk, DATA_WIDTH 64, FREQ_HZ 125000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI3, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]S_AXI_HP0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARBURST" *) input [1:0]S_AXI_HP0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARCACHE" *) input [3:0]S_AXI_HP0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARID" *) input [5:0]S_AXI_HP0_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARLEN" *) input [3:0]S_AXI_HP0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARLOCK" *) input [1:0]S_AXI_HP0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARPROT" *) input [2:0]S_AXI_HP0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARQOS" *) input [3:0]S_AXI_HP0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARREADY" *) output S_AXI_HP0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARSIZE" *) input [2:0]S_AXI_HP0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARVALID" *) input S_AXI_HP0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWADDR" *) input [31:0]S_AXI_HP0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWBURST" *) input [1:0]S_AXI_HP0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWCACHE" *) input [3:0]S_AXI_HP0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWID" *) input [5:0]S_AXI_HP0_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWLEN" *) input [3:0]S_AXI_HP0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWLOCK" *) input [1:0]S_AXI_HP0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWPROT" *) input [2:0]S_AXI_HP0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWQOS" *) input [3:0]S_AXI_HP0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWREADY" *) output S_AXI_HP0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWSIZE" *) input [2:0]S_AXI_HP0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWVALID" *) input S_AXI_HP0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BID" *) output [5:0]S_AXI_HP0_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BREADY" *) input S_AXI_HP0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BRESP" *) output [1:0]S_AXI_HP0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BVALID" *) output S_AXI_HP0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RDATA" *) output [63:0]S_AXI_HP0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RID" *) output [5:0]S_AXI_HP0_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RLAST" *) output S_AXI_HP0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RREADY" *) input S_AXI_HP0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RRESP" *) output [1:0]S_AXI_HP0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RVALID" *) output S_AXI_HP0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WDATA" *) input [63:0]S_AXI_HP0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WID" *) input [5:0]S_AXI_HP0_wid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WLAST" *) input S_AXI_HP0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WREADY" *) output S_AXI_HP0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WSTRB" *) input [7:0]S_AXI_HP0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WVALID" *) input S_AXI_HP0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_HP1_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_HP1_ACLK, ASSOCIATED_BUSIF S_AXI_HP1, CLK_DOMAIN system_S_AXI_HP1_aclk, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) input S_AXI_HP1_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_HP1, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN system_S_AXI_HP1_aclk, DATA_WIDTH 64, FREQ_HZ 125000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI3, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]S_AXI_HP1_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARBURST" *) input [1:0]S_AXI_HP1_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARCACHE" *) input [3:0]S_AXI_HP1_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARID" *) input [5:0]S_AXI_HP1_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARLEN" *) input [3:0]S_AXI_HP1_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARLOCK" *) input [1:0]S_AXI_HP1_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARPROT" *) input [2:0]S_AXI_HP1_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARQOS" *) input [3:0]S_AXI_HP1_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARREADY" *) output S_AXI_HP1_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARSIZE" *) input [2:0]S_AXI_HP1_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 ARVALID" *) input S_AXI_HP1_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWADDR" *) input [31:0]S_AXI_HP1_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWBURST" *) input [1:0]S_AXI_HP1_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWCACHE" *) input [3:0]S_AXI_HP1_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWID" *) input [5:0]S_AXI_HP1_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWLEN" *) input [3:0]S_AXI_HP1_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWLOCK" *) input [1:0]S_AXI_HP1_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWPROT" *) input [2:0]S_AXI_HP1_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWQOS" *) input [3:0]S_AXI_HP1_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWREADY" *) output S_AXI_HP1_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWSIZE" *) input [2:0]S_AXI_HP1_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 AWVALID" *) input S_AXI_HP1_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 BID" *) output [5:0]S_AXI_HP1_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 BREADY" *) input S_AXI_HP1_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 BRESP" *) output [1:0]S_AXI_HP1_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 BVALID" *) output S_AXI_HP1_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RDATA" *) output [63:0]S_AXI_HP1_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RID" *) output [5:0]S_AXI_HP1_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RLAST" *) output S_AXI_HP1_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RREADY" *) input S_AXI_HP1_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RRESP" *) output [1:0]S_AXI_HP1_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 RVALID" *) output S_AXI_HP1_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WDATA" *) input [63:0]S_AXI_HP1_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WID" *) input [5:0]S_AXI_HP1_wid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WLAST" *) input S_AXI_HP1_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WREADY" *) output S_AXI_HP1_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WSTRB" *) input [7:0]S_AXI_HP1_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HP1 WVALID" *) input S_AXI_HP1_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux0 V_N" *) input Vaux0_v_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux0 V_P" *) input Vaux0_v_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux1 V_N" *) input Vaux1_v_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux1 V_P" *) input Vaux1_v_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux8 V_N" *) input Vaux8_v_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux8 V_P" *) input Vaux8_v_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux9 V_N" *) input Vaux9_v_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vaux9 V_P" *) input Vaux9_v_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vp_Vn V_N" *) input Vp_Vn_v_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_analog_io:1.0 Vp_Vn V_P" *) input Vp_Vn_v_p;

  wire Vaux0_1_V_N;
  wire Vaux0_1_V_P;
  wire Vaux1_1_V_N;
  wire Vaux1_1_V_P;
  wire Vaux8_1_V_N;
  wire Vaux8_1_V_P;
  wire Vaux9_1_V_N;
  wire Vaux9_1_V_P;
  wire Vp_Vn_1_V_N;
  wire Vp_Vn_1_V_P;
  wire [31:0]axi_protocol_converter_0_M_AXI_ARADDR;
  wire axi_protocol_converter_0_M_AXI_ARREADY;
  wire axi_protocol_converter_0_M_AXI_ARVALID;
  wire [31:0]axi_protocol_converter_0_M_AXI_AWADDR;
  wire axi_protocol_converter_0_M_AXI_AWREADY;
  wire axi_protocol_converter_0_M_AXI_AWVALID;
  wire axi_protocol_converter_0_M_AXI_BREADY;
  wire [1:0]axi_protocol_converter_0_M_AXI_BRESP;
  wire axi_protocol_converter_0_M_AXI_BVALID;
  wire [31:0]axi_protocol_converter_0_M_AXI_RDATA;
  wire axi_protocol_converter_0_M_AXI_RREADY;
  wire [1:0]axi_protocol_converter_0_M_AXI_RRESP;
  wire axi_protocol_converter_0_M_AXI_RVALID;
  wire [31:0]axi_protocol_converter_0_M_AXI_WDATA;
  wire axi_protocol_converter_0_M_AXI_WREADY;
  wire [3:0]axi_protocol_converter_0_M_AXI_WSTRB;
  wire axi_protocol_converter_0_M_AXI_WVALID;
  wire m_axi_gp0_aclk_1;
  wire [0:0]proc_sys_reset_0_interconnect_aresetn;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [31:0]processing_system7_0_M_AXI_GP0_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARQOS;
  wire processing_system7_0_M_AXI_GP0_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARSIZE;
  wire processing_system7_0_M_AXI_GP0_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWQOS;
  wire processing_system7_0_M_AXI_GP0_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWSIZE;
  wire processing_system7_0_M_AXI_GP0_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP0_BID;
  wire processing_system7_0_M_AXI_GP0_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_BRESP;
  wire processing_system7_0_M_AXI_GP0_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_RID;
  wire processing_system7_0_M_AXI_GP0_RLAST;
  wire processing_system7_0_M_AXI_GP0_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_RRESP;
  wire processing_system7_0_M_AXI_GP0_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_WID;
  wire processing_system7_0_M_AXI_GP0_WLAST;
  wire processing_system7_0_M_AXI_GP0_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP0_WSTRB;
  wire processing_system7_0_M_AXI_GP0_WVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP1_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP1_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP1_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP1_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARQOS;
  wire processing_system7_0_M_AXI_GP1_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP1_ARSIZE;
  wire processing_system7_0_M_AXI_GP1_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP1_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP1_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP1_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP1_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWQOS;
  wire processing_system7_0_M_AXI_GP1_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP1_AWSIZE;
  wire processing_system7_0_M_AXI_GP1_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP1_BID;
  wire processing_system7_0_M_AXI_GP1_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP1_BRESP;
  wire processing_system7_0_M_AXI_GP1_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP1_RID;
  wire processing_system7_0_M_AXI_GP1_RLAST;
  wire processing_system7_0_M_AXI_GP1_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP1_RRESP;
  wire processing_system7_0_M_AXI_GP1_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP1_WID;
  wire processing_system7_0_M_AXI_GP1_WLAST;
  wire processing_system7_0_M_AXI_GP1_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP1_WSTRB;
  wire processing_system7_0_M_AXI_GP1_WVALID;
  wire [14:0]processing_system7_0_ddr_ADDR;
  wire [2:0]processing_system7_0_ddr_BA;
  wire processing_system7_0_ddr_CAS_N;
  wire processing_system7_0_ddr_CKE;
  wire processing_system7_0_ddr_CK_N;
  wire processing_system7_0_ddr_CK_P;
  wire processing_system7_0_ddr_CS_N;
  wire [3:0]processing_system7_0_ddr_DM;
  wire [31:0]processing_system7_0_ddr_DQ;
  wire [3:0]processing_system7_0_ddr_DQS_N;
  wire [3:0]processing_system7_0_ddr_DQS_P;
  wire processing_system7_0_ddr_ODT;
  wire processing_system7_0_ddr_RAS_N;
  wire processing_system7_0_ddr_RESET_N;
  wire processing_system7_0_ddr_WE_N;
  wire processing_system7_0_fclk_clk0;
  wire processing_system7_0_fclk_clk1;
  wire processing_system7_0_fclk_clk2;
  wire processing_system7_0_fclk_clk3;
  wire processing_system7_0_fclk_reset0_n;
  wire processing_system7_0_fclk_reset1_n;
  wire processing_system7_0_fclk_reset2_n;
  wire processing_system7_0_fclk_reset3_n;
  wire processing_system7_0_fixed_io_DDR_VRN;
  wire processing_system7_0_fixed_io_DDR_VRP;
  wire [53:0]processing_system7_0_fixed_io_MIO;
  wire processing_system7_0_fixed_io_PS_CLK;
  wire processing_system7_0_fixed_io_PS_PORB;
  wire processing_system7_0_fixed_io_PS_SRSTB;
  wire [31:0]s_axi_hp0_1_ARADDR;
  wire [1:0]s_axi_hp0_1_ARBURST;
  wire [3:0]s_axi_hp0_1_ARCACHE;
  wire [5:0]s_axi_hp0_1_ARID;
  wire [3:0]s_axi_hp0_1_ARLEN;
  wire [1:0]s_axi_hp0_1_ARLOCK;
  wire [2:0]s_axi_hp0_1_ARPROT;
  wire [3:0]s_axi_hp0_1_ARQOS;
  wire s_axi_hp0_1_ARREADY;
  wire [2:0]s_axi_hp0_1_ARSIZE;
  wire s_axi_hp0_1_ARVALID;
  wire [31:0]s_axi_hp0_1_AWADDR;
  wire [1:0]s_axi_hp0_1_AWBURST;
  wire [3:0]s_axi_hp0_1_AWCACHE;
  wire [5:0]s_axi_hp0_1_AWID;
  wire [3:0]s_axi_hp0_1_AWLEN;
  wire [1:0]s_axi_hp0_1_AWLOCK;
  wire [2:0]s_axi_hp0_1_AWPROT;
  wire [3:0]s_axi_hp0_1_AWQOS;
  wire s_axi_hp0_1_AWREADY;
  wire [2:0]s_axi_hp0_1_AWSIZE;
  wire s_axi_hp0_1_AWVALID;
  wire [5:0]s_axi_hp0_1_BID;
  wire s_axi_hp0_1_BREADY;
  wire [1:0]s_axi_hp0_1_BRESP;
  wire s_axi_hp0_1_BVALID;
  wire [63:0]s_axi_hp0_1_RDATA;
  wire [5:0]s_axi_hp0_1_RID;
  wire s_axi_hp0_1_RLAST;
  wire s_axi_hp0_1_RREADY;
  wire [1:0]s_axi_hp0_1_RRESP;
  wire s_axi_hp0_1_RVALID;
  wire [63:0]s_axi_hp0_1_WDATA;
  wire [5:0]s_axi_hp0_1_WID;
  wire s_axi_hp0_1_WLAST;
  wire s_axi_hp0_1_WREADY;
  wire [7:0]s_axi_hp0_1_WSTRB;
  wire s_axi_hp0_1_WVALID;
  wire s_axi_hp0_aclk;
  wire [31:0]s_axi_hp1_1_ARADDR;
  wire [1:0]s_axi_hp1_1_ARBURST;
  wire [3:0]s_axi_hp1_1_ARCACHE;
  wire [5:0]s_axi_hp1_1_ARID;
  wire [3:0]s_axi_hp1_1_ARLEN;
  wire [1:0]s_axi_hp1_1_ARLOCK;
  wire [2:0]s_axi_hp1_1_ARPROT;
  wire [3:0]s_axi_hp1_1_ARQOS;
  wire s_axi_hp1_1_ARREADY;
  wire [2:0]s_axi_hp1_1_ARSIZE;
  wire s_axi_hp1_1_ARVALID;
  wire [31:0]s_axi_hp1_1_AWADDR;
  wire [1:0]s_axi_hp1_1_AWBURST;
  wire [3:0]s_axi_hp1_1_AWCACHE;
  wire [5:0]s_axi_hp1_1_AWID;
  wire [3:0]s_axi_hp1_1_AWLEN;
  wire [1:0]s_axi_hp1_1_AWLOCK;
  wire [2:0]s_axi_hp1_1_AWPROT;
  wire [3:0]s_axi_hp1_1_AWQOS;
  wire s_axi_hp1_1_AWREADY;
  wire [2:0]s_axi_hp1_1_AWSIZE;
  wire s_axi_hp1_1_AWVALID;
  wire [5:0]s_axi_hp1_1_BID;
  wire s_axi_hp1_1_BREADY;
  wire [1:0]s_axi_hp1_1_BRESP;
  wire s_axi_hp1_1_BVALID;
  wire [63:0]s_axi_hp1_1_RDATA;
  wire [5:0]s_axi_hp1_1_RID;
  wire s_axi_hp1_1_RLAST;
  wire s_axi_hp1_1_RREADY;
  wire [1:0]s_axi_hp1_1_RRESP;
  wire s_axi_hp1_1_RVALID;
  wire [63:0]s_axi_hp1_1_WDATA;
  wire [5:0]s_axi_hp1_1_WID;
  wire s_axi_hp1_1_WLAST;
  wire s_axi_hp1_1_WREADY;
  wire [7:0]s_axi_hp1_1_WSTRB;
  wire s_axi_hp1_1_WVALID;
  wire s_axi_hp1_aclk;
  wire xadc_wiz_0_ip2intc_irpt;
  wire [0:0]xlconstant_dout;

  assign FCLK_CLK0 = processing_system7_0_fclk_clk0;
  assign FCLK_CLK1 = processing_system7_0_fclk_clk1;
  assign FCLK_CLK2 = processing_system7_0_fclk_clk2;
  assign FCLK_CLK3 = processing_system7_0_fclk_clk3;
  assign FCLK_RESET0_N = processing_system7_0_fclk_reset0_n;
  assign FCLK_RESET1_N = processing_system7_0_fclk_reset1_n;
  assign FCLK_RESET2_N = processing_system7_0_fclk_reset2_n;
  assign FCLK_RESET3_N = processing_system7_0_fclk_reset3_n;
  assign M_AXI_GP0_araddr[31:0] = processing_system7_0_M_AXI_GP0_ARADDR;
  assign M_AXI_GP0_arburst[1:0] = processing_system7_0_M_AXI_GP0_ARBURST;
  assign M_AXI_GP0_arcache[3:0] = processing_system7_0_M_AXI_GP0_ARCACHE;
  assign M_AXI_GP0_arid[11:0] = processing_system7_0_M_AXI_GP0_ARID;
  assign M_AXI_GP0_arlen[3:0] = processing_system7_0_M_AXI_GP0_ARLEN;
  assign M_AXI_GP0_arlock[1:0] = processing_system7_0_M_AXI_GP0_ARLOCK;
  assign M_AXI_GP0_arprot[2:0] = processing_system7_0_M_AXI_GP0_ARPROT;
  assign M_AXI_GP0_arqos[3:0] = processing_system7_0_M_AXI_GP0_ARQOS;
  assign M_AXI_GP0_arsize[2:0] = processing_system7_0_M_AXI_GP0_ARSIZE;
  assign M_AXI_GP0_arvalid = processing_system7_0_M_AXI_GP0_ARVALID;
  assign M_AXI_GP0_awaddr[31:0] = processing_system7_0_M_AXI_GP0_AWADDR;
  assign M_AXI_GP0_awburst[1:0] = processing_system7_0_M_AXI_GP0_AWBURST;
  assign M_AXI_GP0_awcache[3:0] = processing_system7_0_M_AXI_GP0_AWCACHE;
  assign M_AXI_GP0_awid[11:0] = processing_system7_0_M_AXI_GP0_AWID;
  assign M_AXI_GP0_awlen[3:0] = processing_system7_0_M_AXI_GP0_AWLEN;
  assign M_AXI_GP0_awlock[1:0] = processing_system7_0_M_AXI_GP0_AWLOCK;
  assign M_AXI_GP0_awprot[2:0] = processing_system7_0_M_AXI_GP0_AWPROT;
  assign M_AXI_GP0_awqos[3:0] = processing_system7_0_M_AXI_GP0_AWQOS;
  assign M_AXI_GP0_awsize[2:0] = processing_system7_0_M_AXI_GP0_AWSIZE;
  assign M_AXI_GP0_awvalid = processing_system7_0_M_AXI_GP0_AWVALID;
  assign M_AXI_GP0_bready = processing_system7_0_M_AXI_GP0_BREADY;
  assign M_AXI_GP0_rready = processing_system7_0_M_AXI_GP0_RREADY;
  assign M_AXI_GP0_wdata[31:0] = processing_system7_0_M_AXI_GP0_WDATA;
  assign M_AXI_GP0_wid[11:0] = processing_system7_0_M_AXI_GP0_WID;
  assign M_AXI_GP0_wlast = processing_system7_0_M_AXI_GP0_WLAST;
  assign M_AXI_GP0_wstrb[3:0] = processing_system7_0_M_AXI_GP0_WSTRB;
  assign M_AXI_GP0_wvalid = processing_system7_0_M_AXI_GP0_WVALID;
  assign S_AXI_HP0_arready = s_axi_hp0_1_ARREADY;
  assign S_AXI_HP0_awready = s_axi_hp0_1_AWREADY;
  assign S_AXI_HP0_bid[5:0] = s_axi_hp0_1_BID;
  assign S_AXI_HP0_bresp[1:0] = s_axi_hp0_1_BRESP;
  assign S_AXI_HP0_bvalid = s_axi_hp0_1_BVALID;
  assign S_AXI_HP0_rdata[63:0] = s_axi_hp0_1_RDATA;
  assign S_AXI_HP0_rid[5:0] = s_axi_hp0_1_RID;
  assign S_AXI_HP0_rlast = s_axi_hp0_1_RLAST;
  assign S_AXI_HP0_rresp[1:0] = s_axi_hp0_1_RRESP;
  assign S_AXI_HP0_rvalid = s_axi_hp0_1_RVALID;
  assign S_AXI_HP0_wready = s_axi_hp0_1_WREADY;
  assign S_AXI_HP1_arready = s_axi_hp1_1_ARREADY;
  assign S_AXI_HP1_awready = s_axi_hp1_1_AWREADY;
  assign S_AXI_HP1_bid[5:0] = s_axi_hp1_1_BID;
  assign S_AXI_HP1_bresp[1:0] = s_axi_hp1_1_BRESP;
  assign S_AXI_HP1_bvalid = s_axi_hp1_1_BVALID;
  assign S_AXI_HP1_rdata[63:0] = s_axi_hp1_1_RDATA;
  assign S_AXI_HP1_rid[5:0] = s_axi_hp1_1_RID;
  assign S_AXI_HP1_rlast = s_axi_hp1_1_RLAST;
  assign S_AXI_HP1_rresp[1:0] = s_axi_hp1_1_RRESP;
  assign S_AXI_HP1_rvalid = s_axi_hp1_1_RVALID;
  assign S_AXI_HP1_wready = s_axi_hp1_1_WREADY;
  assign Vaux0_1_V_N = Vaux0_v_n;
  assign Vaux0_1_V_P = Vaux0_v_p;
  assign Vaux1_1_V_N = Vaux1_v_n;
  assign Vaux1_1_V_P = Vaux1_v_p;
  assign Vaux8_1_V_N = Vaux8_v_n;
  assign Vaux8_1_V_P = Vaux8_v_p;
  assign Vaux9_1_V_N = Vaux9_v_n;
  assign Vaux9_1_V_P = Vaux9_v_p;
  assign Vp_Vn_1_V_N = Vp_Vn_v_n;
  assign Vp_Vn_1_V_P = Vp_Vn_v_p;
  assign m_axi_gp0_aclk_1 = M_AXI_GP0_ACLK;
  assign processing_system7_0_M_AXI_GP0_ARREADY = M_AXI_GP0_arready;
  assign processing_system7_0_M_AXI_GP0_AWREADY = M_AXI_GP0_awready;
  assign processing_system7_0_M_AXI_GP0_BID = M_AXI_GP0_bid[11:0];
  assign processing_system7_0_M_AXI_GP0_BRESP = M_AXI_GP0_bresp[1:0];
  assign processing_system7_0_M_AXI_GP0_BVALID = M_AXI_GP0_bvalid;
  assign processing_system7_0_M_AXI_GP0_RDATA = M_AXI_GP0_rdata[31:0];
  assign processing_system7_0_M_AXI_GP0_RID = M_AXI_GP0_rid[11:0];
  assign processing_system7_0_M_AXI_GP0_RLAST = M_AXI_GP0_rlast;
  assign processing_system7_0_M_AXI_GP0_RRESP = M_AXI_GP0_rresp[1:0];
  assign processing_system7_0_M_AXI_GP0_RVALID = M_AXI_GP0_rvalid;
  assign processing_system7_0_M_AXI_GP0_WREADY = M_AXI_GP0_wready;
  assign s_axi_hp0_1_ARADDR = S_AXI_HP0_araddr[31:0];
  assign s_axi_hp0_1_ARBURST = S_AXI_HP0_arburst[1:0];
  assign s_axi_hp0_1_ARCACHE = S_AXI_HP0_arcache[3:0];
  assign s_axi_hp0_1_ARID = S_AXI_HP0_arid[5:0];
  assign s_axi_hp0_1_ARLEN = S_AXI_HP0_arlen[3:0];
  assign s_axi_hp0_1_ARLOCK = S_AXI_HP0_arlock[1:0];
  assign s_axi_hp0_1_ARPROT = S_AXI_HP0_arprot[2:0];
  assign s_axi_hp0_1_ARQOS = S_AXI_HP0_arqos[3:0];
  assign s_axi_hp0_1_ARSIZE = S_AXI_HP0_arsize[2:0];
  assign s_axi_hp0_1_ARVALID = S_AXI_HP0_arvalid;
  assign s_axi_hp0_1_AWADDR = S_AXI_HP0_awaddr[31:0];
  assign s_axi_hp0_1_AWBURST = S_AXI_HP0_awburst[1:0];
  assign s_axi_hp0_1_AWCACHE = S_AXI_HP0_awcache[3:0];
  assign s_axi_hp0_1_AWID = S_AXI_HP0_awid[5:0];
  assign s_axi_hp0_1_AWLEN = S_AXI_HP0_awlen[3:0];
  assign s_axi_hp0_1_AWLOCK = S_AXI_HP0_awlock[1:0];
  assign s_axi_hp0_1_AWPROT = S_AXI_HP0_awprot[2:0];
  assign s_axi_hp0_1_AWQOS = S_AXI_HP0_awqos[3:0];
  assign s_axi_hp0_1_AWSIZE = S_AXI_HP0_awsize[2:0];
  assign s_axi_hp0_1_AWVALID = S_AXI_HP0_awvalid;
  assign s_axi_hp0_1_BREADY = S_AXI_HP0_bready;
  assign s_axi_hp0_1_RREADY = S_AXI_HP0_rready;
  assign s_axi_hp0_1_WDATA = S_AXI_HP0_wdata[63:0];
  assign s_axi_hp0_1_WID = S_AXI_HP0_wid[5:0];
  assign s_axi_hp0_1_WLAST = S_AXI_HP0_wlast;
  assign s_axi_hp0_1_WSTRB = S_AXI_HP0_wstrb[7:0];
  assign s_axi_hp0_1_WVALID = S_AXI_HP0_wvalid;
  assign s_axi_hp0_aclk = S_AXI_HP0_aclk;
  assign s_axi_hp1_1_ARADDR = S_AXI_HP1_araddr[31:0];
  assign s_axi_hp1_1_ARBURST = S_AXI_HP1_arburst[1:0];
  assign s_axi_hp1_1_ARCACHE = S_AXI_HP1_arcache[3:0];
  assign s_axi_hp1_1_ARID = S_AXI_HP1_arid[5:0];
  assign s_axi_hp1_1_ARLEN = S_AXI_HP1_arlen[3:0];
  assign s_axi_hp1_1_ARLOCK = S_AXI_HP1_arlock[1:0];
  assign s_axi_hp1_1_ARPROT = S_AXI_HP1_arprot[2:0];
  assign s_axi_hp1_1_ARQOS = S_AXI_HP1_arqos[3:0];
  assign s_axi_hp1_1_ARSIZE = S_AXI_HP1_arsize[2:0];
  assign s_axi_hp1_1_ARVALID = S_AXI_HP1_arvalid;
  assign s_axi_hp1_1_AWADDR = S_AXI_HP1_awaddr[31:0];
  assign s_axi_hp1_1_AWBURST = S_AXI_HP1_awburst[1:0];
  assign s_axi_hp1_1_AWCACHE = S_AXI_HP1_awcache[3:0];
  assign s_axi_hp1_1_AWID = S_AXI_HP1_awid[5:0];
  assign s_axi_hp1_1_AWLEN = S_AXI_HP1_awlen[3:0];
  assign s_axi_hp1_1_AWLOCK = S_AXI_HP1_awlock[1:0];
  assign s_axi_hp1_1_AWPROT = S_AXI_HP1_awprot[2:0];
  assign s_axi_hp1_1_AWQOS = S_AXI_HP1_awqos[3:0];
  assign s_axi_hp1_1_AWSIZE = S_AXI_HP1_awsize[2:0];
  assign s_axi_hp1_1_AWVALID = S_AXI_HP1_awvalid;
  assign s_axi_hp1_1_BREADY = S_AXI_HP1_bready;
  assign s_axi_hp1_1_RREADY = S_AXI_HP1_rready;
  assign s_axi_hp1_1_WDATA = S_AXI_HP1_wdata[63:0];
  assign s_axi_hp1_1_WID = S_AXI_HP1_wid[5:0];
  assign s_axi_hp1_1_WLAST = S_AXI_HP1_wlast;
  assign s_axi_hp1_1_WSTRB = S_AXI_HP1_wstrb[7:0];
  assign s_axi_hp1_1_WVALID = S_AXI_HP1_wvalid;
  assign s_axi_hp1_aclk = S_AXI_HP1_aclk;
  system_axi_protocol_converter_0_0 axi_protocol_converter_0
       (.aclk(processing_system7_0_fclk_clk3),
        .aresetn(proc_sys_reset_0_interconnect_aresetn),
        .m_axi_araddr(axi_protocol_converter_0_M_AXI_ARADDR),
        .m_axi_arready(axi_protocol_converter_0_M_AXI_ARREADY),
        .m_axi_arvalid(axi_protocol_converter_0_M_AXI_ARVALID),
        .m_axi_awaddr(axi_protocol_converter_0_M_AXI_AWADDR),
        .m_axi_awready(axi_protocol_converter_0_M_AXI_AWREADY),
        .m_axi_awvalid(axi_protocol_converter_0_M_AXI_AWVALID),
        .m_axi_bready(axi_protocol_converter_0_M_AXI_BREADY),
        .m_axi_bresp(axi_protocol_converter_0_M_AXI_BRESP),
        .m_axi_bvalid(axi_protocol_converter_0_M_AXI_BVALID),
        .m_axi_rdata(axi_protocol_converter_0_M_AXI_RDATA),
        .m_axi_rready(axi_protocol_converter_0_M_AXI_RREADY),
        .m_axi_rresp(axi_protocol_converter_0_M_AXI_RRESP),
        .m_axi_rvalid(axi_protocol_converter_0_M_AXI_RVALID),
        .m_axi_wdata(axi_protocol_converter_0_M_AXI_WDATA),
        .m_axi_wready(axi_protocol_converter_0_M_AXI_WREADY),
        .m_axi_wstrb(axi_protocol_converter_0_M_AXI_WSTRB),
        .m_axi_wvalid(axi_protocol_converter_0_M_AXI_WVALID),
        .s_axi_araddr(processing_system7_0_M_AXI_GP1_ARADDR),
        .s_axi_arburst(processing_system7_0_M_AXI_GP1_ARBURST),
        .s_axi_arcache(processing_system7_0_M_AXI_GP1_ARCACHE),
        .s_axi_arid(processing_system7_0_M_AXI_GP1_ARID),
        .s_axi_arlen(processing_system7_0_M_AXI_GP1_ARLEN),
        .s_axi_arlock(processing_system7_0_M_AXI_GP1_ARLOCK),
        .s_axi_arprot(processing_system7_0_M_AXI_GP1_ARPROT),
        .s_axi_arqos(processing_system7_0_M_AXI_GP1_ARQOS),
        .s_axi_arready(processing_system7_0_M_AXI_GP1_ARREADY),
        .s_axi_arsize(processing_system7_0_M_AXI_GP1_ARSIZE),
        .s_axi_arvalid(processing_system7_0_M_AXI_GP1_ARVALID),
        .s_axi_awaddr(processing_system7_0_M_AXI_GP1_AWADDR),
        .s_axi_awburst(processing_system7_0_M_AXI_GP1_AWBURST),
        .s_axi_awcache(processing_system7_0_M_AXI_GP1_AWCACHE),
        .s_axi_awid(processing_system7_0_M_AXI_GP1_AWID),
        .s_axi_awlen(processing_system7_0_M_AXI_GP1_AWLEN),
        .s_axi_awlock(processing_system7_0_M_AXI_GP1_AWLOCK),
        .s_axi_awprot(processing_system7_0_M_AXI_GP1_AWPROT),
        .s_axi_awqos(processing_system7_0_M_AXI_GP1_AWQOS),
        .s_axi_awready(processing_system7_0_M_AXI_GP1_AWREADY),
        .s_axi_awsize(processing_system7_0_M_AXI_GP1_AWSIZE),
        .s_axi_awvalid(processing_system7_0_M_AXI_GP1_AWVALID),
        .s_axi_bid(processing_system7_0_M_AXI_GP1_BID),
        .s_axi_bready(processing_system7_0_M_AXI_GP1_BREADY),
        .s_axi_bresp(processing_system7_0_M_AXI_GP1_BRESP),
        .s_axi_bvalid(processing_system7_0_M_AXI_GP1_BVALID),
        .s_axi_rdata(processing_system7_0_M_AXI_GP1_RDATA),
        .s_axi_rid(processing_system7_0_M_AXI_GP1_RID),
        .s_axi_rlast(processing_system7_0_M_AXI_GP1_RLAST),
        .s_axi_rready(processing_system7_0_M_AXI_GP1_RREADY),
        .s_axi_rresp(processing_system7_0_M_AXI_GP1_RRESP),
        .s_axi_rvalid(processing_system7_0_M_AXI_GP1_RVALID),
        .s_axi_wdata(processing_system7_0_M_AXI_GP1_WDATA),
        .s_axi_wid(processing_system7_0_M_AXI_GP1_WID),
        .s_axi_wlast(processing_system7_0_M_AXI_GP1_WLAST),
        .s_axi_wready(processing_system7_0_M_AXI_GP1_WREADY),
        .s_axi_wstrb(processing_system7_0_M_AXI_GP1_WSTRB),
        .s_axi_wvalid(processing_system7_0_M_AXI_GP1_WVALID));
  system_proc_sys_reset_0 proc_sys_reset
       (.aux_reset_in(xlconstant_dout),
        .dcm_locked(1'b1),
        .ext_reset_in(processing_system7_0_fclk_reset3_n),
        .interconnect_aresetn(proc_sys_reset_0_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .slowest_sync_clk(processing_system7_0_fclk_clk3));
  system_processing_system7_0 processing_system7
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .FCLK_CLK0(processing_system7_0_fclk_clk0),
        .FCLK_CLK1(processing_system7_0_fclk_clk1),
        .FCLK_CLK2(processing_system7_0_fclk_clk2),
        .FCLK_CLK3(processing_system7_0_fclk_clk3),
        .FCLK_RESET0_N(processing_system7_0_fclk_reset0_n),
        .FCLK_RESET1_N(processing_system7_0_fclk_reset1_n),
        .FCLK_RESET2_N(processing_system7_0_fclk_reset2_n),
        .FCLK_RESET3_N(processing_system7_0_fclk_reset3_n),
        .IRQ_F2P(xadc_wiz_0_ip2intc_irpt),
        .MIO(FIXED_IO_mio[53:0]),
        .M_AXI_GP0_ACLK(m_axi_gp0_aclk_1),
        .M_AXI_GP0_ARADDR(processing_system7_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARBURST(processing_system7_0_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_ARCACHE(processing_system7_0_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_ARID(processing_system7_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(processing_system7_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARLOCK(processing_system7_0_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_ARPROT(processing_system7_0_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_ARQOS(processing_system7_0_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_ARREADY(processing_system7_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARSIZE(processing_system7_0_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_ARVALID(processing_system7_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(processing_system7_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWBURST(processing_system7_0_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_AWCACHE(processing_system7_0_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_AWID(processing_system7_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWLEN(processing_system7_0_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_AWLOCK(processing_system7_0_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_AWPROT(processing_system7_0_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_AWQOS(processing_system7_0_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_AWREADY(processing_system7_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWSIZE(processing_system7_0_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_AWVALID(processing_system7_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(processing_system7_0_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(processing_system7_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP(processing_system7_0_M_AXI_GP0_BRESP),
        .M_AXI_GP0_BVALID(processing_system7_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(processing_system7_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(processing_system7_0_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(processing_system7_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(processing_system7_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP(processing_system7_0_M_AXI_GP0_RRESP),
        .M_AXI_GP0_RVALID(processing_system7_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(processing_system7_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WID(processing_system7_0_M_AXI_GP0_WID),
        .M_AXI_GP0_WLAST(processing_system7_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(processing_system7_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(processing_system7_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(processing_system7_0_M_AXI_GP0_WVALID),
        .M_AXI_GP1_ACLK(processing_system7_0_fclk_clk3),
        .M_AXI_GP1_ARADDR(processing_system7_0_M_AXI_GP1_ARADDR),
        .M_AXI_GP1_ARBURST(processing_system7_0_M_AXI_GP1_ARBURST),
        .M_AXI_GP1_ARCACHE(processing_system7_0_M_AXI_GP1_ARCACHE),
        .M_AXI_GP1_ARID(processing_system7_0_M_AXI_GP1_ARID),
        .M_AXI_GP1_ARLEN(processing_system7_0_M_AXI_GP1_ARLEN),
        .M_AXI_GP1_ARLOCK(processing_system7_0_M_AXI_GP1_ARLOCK),
        .M_AXI_GP1_ARPROT(processing_system7_0_M_AXI_GP1_ARPROT),
        .M_AXI_GP1_ARQOS(processing_system7_0_M_AXI_GP1_ARQOS),
        .M_AXI_GP1_ARREADY(processing_system7_0_M_AXI_GP1_ARREADY),
        .M_AXI_GP1_ARSIZE(processing_system7_0_M_AXI_GP1_ARSIZE),
        .M_AXI_GP1_ARVALID(processing_system7_0_M_AXI_GP1_ARVALID),
        .M_AXI_GP1_AWADDR(processing_system7_0_M_AXI_GP1_AWADDR),
        .M_AXI_GP1_AWBURST(processing_system7_0_M_AXI_GP1_AWBURST),
        .M_AXI_GP1_AWCACHE(processing_system7_0_M_AXI_GP1_AWCACHE),
        .M_AXI_GP1_AWID(processing_system7_0_M_AXI_GP1_AWID),
        .M_AXI_GP1_AWLEN(processing_system7_0_M_AXI_GP1_AWLEN),
        .M_AXI_GP1_AWLOCK(processing_system7_0_M_AXI_GP1_AWLOCK),
        .M_AXI_GP1_AWPROT(processing_system7_0_M_AXI_GP1_AWPROT),
        .M_AXI_GP1_AWQOS(processing_system7_0_M_AXI_GP1_AWQOS),
        .M_AXI_GP1_AWREADY(processing_system7_0_M_AXI_GP1_AWREADY),
        .M_AXI_GP1_AWSIZE(processing_system7_0_M_AXI_GP1_AWSIZE),
        .M_AXI_GP1_AWVALID(processing_system7_0_M_AXI_GP1_AWVALID),
        .M_AXI_GP1_BID(processing_system7_0_M_AXI_GP1_BID),
        .M_AXI_GP1_BREADY(processing_system7_0_M_AXI_GP1_BREADY),
        .M_AXI_GP1_BRESP(processing_system7_0_M_AXI_GP1_BRESP),
        .M_AXI_GP1_BVALID(processing_system7_0_M_AXI_GP1_BVALID),
        .M_AXI_GP1_RDATA(processing_system7_0_M_AXI_GP1_RDATA),
        .M_AXI_GP1_RID(processing_system7_0_M_AXI_GP1_RID),
        .M_AXI_GP1_RLAST(processing_system7_0_M_AXI_GP1_RLAST),
        .M_AXI_GP1_RREADY(processing_system7_0_M_AXI_GP1_RREADY),
        .M_AXI_GP1_RRESP(processing_system7_0_M_AXI_GP1_RRESP),
        .M_AXI_GP1_RVALID(processing_system7_0_M_AXI_GP1_RVALID),
        .M_AXI_GP1_WDATA(processing_system7_0_M_AXI_GP1_WDATA),
        .M_AXI_GP1_WID(processing_system7_0_M_AXI_GP1_WID),
        .M_AXI_GP1_WLAST(processing_system7_0_M_AXI_GP1_WLAST),
        .M_AXI_GP1_WREADY(processing_system7_0_M_AXI_GP1_WREADY),
        .M_AXI_GP1_WSTRB(processing_system7_0_M_AXI_GP1_WSTRB),
        .M_AXI_GP1_WVALID(processing_system7_0_M_AXI_GP1_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .S_AXI_HP0_ACLK(s_axi_hp0_aclk),
        .S_AXI_HP0_ARADDR(s_axi_hp0_1_ARADDR),
        .S_AXI_HP0_ARBURST(s_axi_hp0_1_ARBURST),
        .S_AXI_HP0_ARCACHE(s_axi_hp0_1_ARCACHE),
        .S_AXI_HP0_ARID(s_axi_hp0_1_ARID),
        .S_AXI_HP0_ARLEN(s_axi_hp0_1_ARLEN),
        .S_AXI_HP0_ARLOCK(s_axi_hp0_1_ARLOCK),
        .S_AXI_HP0_ARPROT(s_axi_hp0_1_ARPROT),
        .S_AXI_HP0_ARQOS(s_axi_hp0_1_ARQOS),
        .S_AXI_HP0_ARREADY(s_axi_hp0_1_ARREADY),
        .S_AXI_HP0_ARSIZE(s_axi_hp0_1_ARSIZE),
        .S_AXI_HP0_ARVALID(s_axi_hp0_1_ARVALID),
        .S_AXI_HP0_AWADDR(s_axi_hp0_1_AWADDR),
        .S_AXI_HP0_AWBURST(s_axi_hp0_1_AWBURST),
        .S_AXI_HP0_AWCACHE(s_axi_hp0_1_AWCACHE),
        .S_AXI_HP0_AWID(s_axi_hp0_1_AWID),
        .S_AXI_HP0_AWLEN(s_axi_hp0_1_AWLEN),
        .S_AXI_HP0_AWLOCK(s_axi_hp0_1_AWLOCK),
        .S_AXI_HP0_AWPROT(s_axi_hp0_1_AWPROT),
        .S_AXI_HP0_AWQOS(s_axi_hp0_1_AWQOS),
        .S_AXI_HP0_AWREADY(s_axi_hp0_1_AWREADY),
        .S_AXI_HP0_AWSIZE(s_axi_hp0_1_AWSIZE),
        .S_AXI_HP0_AWVALID(s_axi_hp0_1_AWVALID),
        .S_AXI_HP0_BID(s_axi_hp0_1_BID),
        .S_AXI_HP0_BREADY(s_axi_hp0_1_BREADY),
        .S_AXI_HP0_BRESP(s_axi_hp0_1_BRESP),
        .S_AXI_HP0_BVALID(s_axi_hp0_1_BVALID),
        .S_AXI_HP0_RDATA(s_axi_hp0_1_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP0_RID(s_axi_hp0_1_RID),
        .S_AXI_HP0_RLAST(s_axi_hp0_1_RLAST),
        .S_AXI_HP0_RREADY(s_axi_hp0_1_RREADY),
        .S_AXI_HP0_RRESP(s_axi_hp0_1_RRESP),
        .S_AXI_HP0_RVALID(s_axi_hp0_1_RVALID),
        .S_AXI_HP0_WDATA(s_axi_hp0_1_WDATA),
        .S_AXI_HP0_WID(s_axi_hp0_1_WID),
        .S_AXI_HP0_WLAST(s_axi_hp0_1_WLAST),
        .S_AXI_HP0_WREADY(s_axi_hp0_1_WREADY),
        .S_AXI_HP0_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP0_WSTRB(s_axi_hp0_1_WSTRB),
        .S_AXI_HP0_WVALID(s_axi_hp0_1_WVALID),
        .S_AXI_HP1_ACLK(s_axi_hp1_aclk),
        .S_AXI_HP1_ARADDR(s_axi_hp1_1_ARADDR),
        .S_AXI_HP1_ARBURST(s_axi_hp1_1_ARBURST),
        .S_AXI_HP1_ARCACHE(s_axi_hp1_1_ARCACHE),
        .S_AXI_HP1_ARID(s_axi_hp1_1_ARID),
        .S_AXI_HP1_ARLEN(s_axi_hp1_1_ARLEN),
        .S_AXI_HP1_ARLOCK(s_axi_hp1_1_ARLOCK),
        .S_AXI_HP1_ARPROT(s_axi_hp1_1_ARPROT),
        .S_AXI_HP1_ARQOS(s_axi_hp1_1_ARQOS),
        .S_AXI_HP1_ARREADY(s_axi_hp1_1_ARREADY),
        .S_AXI_HP1_ARSIZE(s_axi_hp1_1_ARSIZE),
        .S_AXI_HP1_ARVALID(s_axi_hp1_1_ARVALID),
        .S_AXI_HP1_AWADDR(s_axi_hp1_1_AWADDR),
        .S_AXI_HP1_AWBURST(s_axi_hp1_1_AWBURST),
        .S_AXI_HP1_AWCACHE(s_axi_hp1_1_AWCACHE),
        .S_AXI_HP1_AWID(s_axi_hp1_1_AWID),
        .S_AXI_HP1_AWLEN(s_axi_hp1_1_AWLEN),
        .S_AXI_HP1_AWLOCK(s_axi_hp1_1_AWLOCK),
        .S_AXI_HP1_AWPROT(s_axi_hp1_1_AWPROT),
        .S_AXI_HP1_AWQOS(s_axi_hp1_1_AWQOS),
        .S_AXI_HP1_AWREADY(s_axi_hp1_1_AWREADY),
        .S_AXI_HP1_AWSIZE(s_axi_hp1_1_AWSIZE),
        .S_AXI_HP1_AWVALID(s_axi_hp1_1_AWVALID),
        .S_AXI_HP1_BID(s_axi_hp1_1_BID),
        .S_AXI_HP1_BREADY(s_axi_hp1_1_BREADY),
        .S_AXI_HP1_BRESP(s_axi_hp1_1_BRESP),
        .S_AXI_HP1_BVALID(s_axi_hp1_1_BVALID),
        .S_AXI_HP1_RDATA(s_axi_hp1_1_RDATA),
        .S_AXI_HP1_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP1_RID(s_axi_hp1_1_RID),
        .S_AXI_HP1_RLAST(s_axi_hp1_1_RLAST),
        .S_AXI_HP1_RREADY(s_axi_hp1_1_RREADY),
        .S_AXI_HP1_RRESP(s_axi_hp1_1_RRESP),
        .S_AXI_HP1_RVALID(s_axi_hp1_1_RVALID),
        .S_AXI_HP1_WDATA(s_axi_hp1_1_WDATA),
        .S_AXI_HP1_WID(s_axi_hp1_1_WID),
        .S_AXI_HP1_WLAST(s_axi_hp1_1_WLAST),
        .S_AXI_HP1_WREADY(s_axi_hp1_1_WREADY),
        .S_AXI_HP1_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP1_WSTRB(s_axi_hp1_1_WSTRB),
        .S_AXI_HP1_WVALID(s_axi_hp1_1_WVALID),
        .USB0_VBUS_PWRFAULT(1'b0));
  system_xadc_0 xadc
       (.ip2intc_irpt(xadc_wiz_0_ip2intc_irpt),
        .s_axi_aclk(processing_system7_0_fclk_clk3),
        .s_axi_araddr(axi_protocol_converter_0_M_AXI_ARADDR[10:0]),
        .s_axi_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .s_axi_arready(axi_protocol_converter_0_M_AXI_ARREADY),
        .s_axi_arvalid(axi_protocol_converter_0_M_AXI_ARVALID),
        .s_axi_awaddr(axi_protocol_converter_0_M_AXI_AWADDR[10:0]),
        .s_axi_awready(axi_protocol_converter_0_M_AXI_AWREADY),
        .s_axi_awvalid(axi_protocol_converter_0_M_AXI_AWVALID),
        .s_axi_bready(axi_protocol_converter_0_M_AXI_BREADY),
        .s_axi_bresp(axi_protocol_converter_0_M_AXI_BRESP),
        .s_axi_bvalid(axi_protocol_converter_0_M_AXI_BVALID),
        .s_axi_rdata(axi_protocol_converter_0_M_AXI_RDATA),
        .s_axi_rready(axi_protocol_converter_0_M_AXI_RREADY),
        .s_axi_rresp(axi_protocol_converter_0_M_AXI_RRESP),
        .s_axi_rvalid(axi_protocol_converter_0_M_AXI_RVALID),
        .s_axi_wdata(axi_protocol_converter_0_M_AXI_WDATA),
        .s_axi_wready(axi_protocol_converter_0_M_AXI_WREADY),
        .s_axi_wstrb(axi_protocol_converter_0_M_AXI_WSTRB),
        .s_axi_wvalid(axi_protocol_converter_0_M_AXI_WVALID),
        .vauxn0(Vaux0_1_V_N),
        .vauxn1(Vaux1_1_V_N),
        .vauxn8(Vaux8_1_V_N),
        .vauxn9(Vaux9_1_V_N),
        .vauxp0(Vaux0_1_V_P),
        .vauxp1(Vaux1_1_V_P),
        .vauxp8(Vaux8_1_V_P),
        .vauxp9(Vaux9_1_V_P),
        .vn_in(Vp_Vn_1_V_N),
        .vp_in(Vp_Vn_1_V_P));
  system_xlconstant_0 xlconstant
       (.dout(xlconstant_dout));
endmodule
