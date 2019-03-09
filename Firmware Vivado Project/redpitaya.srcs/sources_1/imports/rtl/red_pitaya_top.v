/**
 * $Id: red_pitaya_top.v 1271 2014-02-25 12:32:34Z matej.oblak $
 *
 * @brief Red Pitaya TOP module. It connects external pins and PS part with 
 *        other application modules. 
 *
 * @Author Matej Oblak
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */


/**
 * GENERAL DESCRIPTION:
 *
 * Top module connects PS part with rest of Red Pitaya applications.  
 *
 *
 *                   /-------\      
 *   PS DDR <------> |  PS   |      AXI <-> custom bus
 *   PS MIO <------> |   /   | <------------+
 *   PS CLK -------> |  ARM  |              |
 *                   \-------/              |
 *                                          |
 *                            /-------\     |
 *                         -> | SCOPE | <---+
 *                         |  \-------/     |
 *                         |                |
 *            /--------\   |   /-----\      |
 *   ADC ---> |        | --+-> |     |      |
 *            | ANALOG |       | PID | <----+
 *   DAC <--- |        | <---- |     |      |
 *            \--------/   ^   \-----/      |
 *                         |                |
 *                         |  /-------\     |
 *                         -- |  ASG  | <---+ 
 *                            \-------/     |
 *                                          |
 *             /--------\                   |
 *    RX ----> |        |                   |
 *   SATA      | DAISY  | <-----------------+
 *    TX <---- |        | 
 *             \--------/ 
 *               |    |
 *               |    |
 *               (FREE)
 *
 *
 * Inside analog module, ADC data is translated from unsigned neg-slope into
 * two's complement. Similar is done on DAC data.
 *
 * Scope module stores data from ADC into RAM, arbitrary signal generator (ASG)
 * sends data from RAM to DAC. MIMO PID uses ADC ADC as input and DAC as its output.
 *
 * Daisy chain connects with other boards with fast serial link. Data which is
 * send and received is at the moment undefined. This is left for the user.
 * 
 */

module red_pitaya_top (
   // PS connections (Processing System)
   inout  wire  [54-1: 0] FIXED_IO_mio       ,
   inout  wire            FIXED_IO_ps_clk    ,
   inout  wire            FIXED_IO_ps_porb   ,
   inout  wire            FIXED_IO_ps_srstb  ,
   inout  wire            FIXED_IO_ddr_vrn   ,
   inout  wire            FIXED_IO_ddr_vrp   ,
   // DDR RAM
   inout  wire  [15-1: 0] DDR_addr           ,
   inout  wire  [ 3-1: 0] DDR_ba             ,
   inout  wire            DDR_cas_n          ,
   inout  wire            DDR_ck_n           ,
   inout  wire            DDR_ck_p           ,
   inout  wire            DDR_cke            ,
   inout  wire            DDR_cs_n           ,
   inout  wire  [ 4-1: 0] DDR_dm             ,
   inout  wire  [32-1: 0] DDR_dq             ,
   inout  wire  [ 4-1: 0] DDR_dqs_n          ,
   inout  wire  [ 4-1: 0] DDR_dqs_p          ,
   inout  wire            DDR_odt            ,
   inout  wire            DDR_ras_n          ,
   inout  wire            DDR_reset_n        ,
   inout  wire            DDR_we_n           ,

   // ADC
   input  wire  [16-1: 2] adc_dat_a_i        ,  // ADC CH1
   input  wire  [16-1: 2] adc_dat_b_i        ,  // ADC CH2
   input  wire            adc_clk_p_i        ,  // ADC data clock
   input  wire            adc_clk_n_i        ,  // ADC data clock
   //output wire  [ 2-1: 0] adc_clk_o          ,  // optional ADC clock source
   output wire            adc_cdcs_o         ,  // ADC clock duty cycle stabilizer
   
   // DAC
   output wire  [14-1: 0] dac_dat_o          ,  // DAC combined data
   output wire            dac_wrt_o          ,  // DAC write
   output wire            dac_sel_o          ,  // DAC channel select
   output wire            dac_clk_o          ,  // DAC clock
   output wire            dac_rst_o          ,  // DAC reset
   
   // PWM DAC
   output wire  [ 4-1: 0] dac_pwm_o          ,  // serial PWM DAC
   
   // XADC
   input  wire  [ 5-1: 0] vinp_i             ,  // voltages p
   input  wire  [ 5-1: 0] vinn_i             ,  // voltages n
   
   // Expansion connector
   inout  wire  [ 8-1: 0] exp_p_io           ,
   inout  wire  [ 8-1: 0] exp_n_io           ,
   
   // SATA connector
   output wire  [ 2-1: 0] daisy_p_o          ,  // line 1 is clock capable
   output wire  [ 2-1: 0] daisy_n_o          ,
   input  wire  [ 2-1: 0] daisy_p_i          ,  // line 1 is clock capable
   input  wire  [ 2-1: 0] daisy_n_i          ,
   
   // LED
   output wire  [ 8-1: 0] led_o       
);


////////////////////////////////////////////////////////////////////////////////
//  Connections to PS (Processing System)
////////////////////////////////////////////////////////////////////////////////
//

wire  [  4-1: 0] fclk               ; //[0]-125MHz, [1]-250MHz, [2]-50MHz, [3]-200MHz
wire  [  4-1: 0] frstn              ;

wire             ps_sys_clk         ;
wire             ps_sys_rstn        ;
wire  [ 32-1: 0] ps_sys_addr        ;
wire  [ 32-1: 0] ps_sys_wdata       ;
wire  [  4-1: 0] ps_sys_sel         ;
wire             ps_sys_wen         ;
wire             ps_sys_ren         ;
wire  [ 32-1: 0] ps_sys_rdata       ;
wire             ps_sys_err         ;
wire             ps_sys_ack         ;

// AXI masters
wire             axi1_clk    , axi0_clk    ;
wire             axi1_rstn   , axi0_rstn   ;
wire  [ 32-1: 0] axi1_waddr  , axi0_waddr  ;
wire  [ 64-1: 0] axi1_wdata  , axi0_wdata  ;
wire  [  8-1: 0] axi1_wsel   , axi0_wsel   ;
wire             axi1_wvalid , axi0_wvalid ;
wire  [  4-1: 0] axi1_wlen   , axi0_wlen   ;
wire             axi1_wfixed , axi0_wfixed ;
wire             axi1_werr   , axi0_werr   ;
wire             axi1_wrdy   , axi0_wrdy   ;

wire rd_do_t;
wire wr_do_t;
wire ack_timout_t;
wire ack_combine_t;

red_pitaya_ps i_ps (
  .FIXED_IO_mio       (  FIXED_IO_mio                ),
  .FIXED_IO_ps_clk    (  FIXED_IO_ps_clk             ),
  .FIXED_IO_ps_porb   (  FIXED_IO_ps_porb            ),
  .FIXED_IO_ps_srstb  (  FIXED_IO_ps_srstb           ),
  .FIXED_IO_ddr_vrn   (  FIXED_IO_ddr_vrn            ),
  .FIXED_IO_ddr_vrp   (  FIXED_IO_ddr_vrp            ),
  // DDR
  .DDR_addr      (DDR_addr    ),
  .DDR_ba        (DDR_ba      ),
  .DDR_cas_n     (DDR_cas_n   ),
  .DDR_ck_n      (DDR_ck_n    ),
  .DDR_ck_p      (DDR_ck_p    ),
  .DDR_cke       (DDR_cke     ),
  .DDR_cs_n      (DDR_cs_n    ),
  .DDR_dm        (DDR_dm      ),
  .DDR_dq        (DDR_dq      ),
  .DDR_dqs_n     (DDR_dqs_n   ),
  .DDR_dqs_p     (DDR_dqs_p   ),
  .DDR_odt       (DDR_odt     ),
  .DDR_ras_n     (DDR_ras_n   ),
  .DDR_reset_n   (DDR_reset_n ),
  .DDR_we_n      (DDR_we_n    ),

  .fclk_clk_o    (fclk        ),
  .fclk_rstn_o   (frstn       ),
  // ADC analog inputs
  .vinp_i        (vinp_i      ),  // voltages p
  .vinn_i        (vinn_i      ),  // voltages n
   // system read/write channel
  .sys_clk_o     (ps_sys_clk  ),  // system clock
  .sys_rstn_o    (ps_sys_rstn ),  // system reset - active low
  .sys_addr_o    (ps_sys_addr ),  // system read/write address
  .sys_wdata_o   (ps_sys_wdata),  // system write data
  .sys_sel_o     (ps_sys_sel  ),  // system write byte select
  .sys_wen_o     (ps_sys_wen  ),  // system write enable
  .sys_ren_o     (ps_sys_ren  ),  // system read enable
  .sys_rdata_i   (ps_sys_rdata),  // system read data
  .sys_err_i     (ps_sys_err  ),  // system error indicator
  .sys_ack_i     (ps_sys_ack  ),  // system acknowledge signal
  // AXI masters
  .axi1_clk_i    (axi1_clk    ),  .axi0_clk_i    (axi0_clk    ),  // global clock
  .axi1_rstn_i   (axi1_rstn   ),  .axi0_rstn_i   (axi0_rstn   ),  // global reset
  .axi1_waddr_i  (axi1_waddr  ),  .axi0_waddr_i  (axi0_waddr  ),  // system write address
  .axi1_wdata_i  (axi1_wdata  ),  .axi0_wdata_i  (axi0_wdata  ),  // system write data
  .axi1_wsel_i   (axi1_wsel   ),  .axi0_wsel_i   (axi0_wsel   ),  // system write byte select
  .axi1_wvalid_i (axi1_wvalid ),  .axi0_wvalid_i (axi0_wvalid ),  // system write data valid
  .axi1_wlen_i   (axi1_wlen   ),  .axi0_wlen_i   (axi0_wlen   ),  // system write burst length
  .axi1_wfixed_i (axi1_wfixed ),  .axi0_wfixed_i (axi0_wfixed ),  // system write burst type (fixed / incremental)
  .axi1_werr_o   (axi1_werr   ),  .axi0_werr_o   (axi0_werr   ),  // system write error
  .axi1_wrdy_o   (axi1_wrdy   ),  .axi0_wrdy_o   (axi0_wrdy   ),  // system write ready
  .rd_do_o       (rd_do_t      ),
  .wr_do_o       (wr_do_t      ),
  .ack_timout_o  (ack_timout_t ),
  .ack_combine_o (ack_combine_t)
);


////////////////////////////////////////////////////////////////////////////////
// System Bus Decoder & Multiplexer
////////////////////////////////////////////////////////////////////////////////
// Breaks memory addresses into 8 regions.
//

wire              sys_clk   = ps_sys_clk  ;
wire              sys_rstn  = ps_sys_rstn ;
wire  [  32-1: 0] sys_addr  = ps_sys_addr ;
wire  [  32-1: 0] sys_wdata = ps_sys_wdata;
wire  [   4-1: 0] sys_sel   = ps_sys_sel  ;
wire  [8   -1: 0] sys_wen   ;
wire  [8   -1: 0] sys_ren   ;
wire  [8*32-1: 0] sys_rdata ;
wire  [8* 1-1: 0] sys_err   ;
wire  [8* 1-1: 0] sys_ack   ;
wire  [8   -1: 0] sys_cs    ;

wire [32-1:0] segment_selector;

// Only send read/write enable bits to the channel selected in the 6th hex
// 0x40000000: channel 0 is DPLL
// 0x40100000: channel 1 is BRAM-based data logger
// 0x40200000: channel 2 is to read data in the RAM for addr_packed
// 0x40300000: channel 3 is "Housekeeping"
// 0x40400000: channel 4 is AMS
// 0x40500000: channel 5 is VCO Output Multiplexer
// 0x40600000: channel 6 is VCO for DAC
// 0x40700000: channel 7 is FREE

assign segment_selector = (sys_addr - 32'h40000000) >> (4*(6-1));
assign sys_cs = 8'h01 << segment_selector;

//assign sys_cs = 8'h01 << sys_addr[22:20];
 
assign sys_wen = sys_cs & {8{ps_sys_wen}};
assign sys_ren = sys_cs & {8{ps_sys_ren}};

assign ps_sys_rdata = sys_rdata[sys_addr[22:20]*32+:32];

assign ps_sys_err   = |(sys_cs & sys_err);
assign ps_sys_ack   = |(sys_cs & sys_ack);

// unused system bus slave ports

// assign sys_rdata[5*32+:32] = 32'h0; 
// assign sys_err  [5       ] =  1'b0;
// assign sys_ack  [5       ] =  1'b1;

// assign sys_rdata[4*32+:32] = 32'h0; 
// assign sys_err  [4       ] =  1'b0;
// assign sys_ack  [4       ] =  1'b1;

assign sys_rdata[7*32+:32] = 32'h0; 
assign sys_err  [7       ] =  1'b0;
assign sys_ack  [7       ] =  1'b1;


////////////////////////////////////////////////////////////////////////////////
// Clock Distribution and Synchronization
////////////////////////////////////////////////////////////////////////////////
//

// ADC Clock and Reset Signals
wire                adc_clk;
wire                adc_clk_2x;
wire                adc_clk_3x;
reg                 adc_rstn;

// DAC Clock and Reset Signals
wire                  dac_clk_iqsel;
wire                  dac_clk_iqclk;
wire                  dac_clk_iqwrt;
reg                   dac_rst;

// PLL Signals
wire                pll_locked;

// PWM Clock and Reset Signals
wire                  pwm_clk ;
reg                   pwm_rstn;

// Daisy Chain Clock signal
wire clk_out_10;

// ADC Data Clock PLL
adc_data_clk_pll adc_data_clk_pll_inst (
    // Inputs
    .clk_in1_n(adc_clk_n_i),
    .clk_in1_p(adc_clk_p_i),
    .resetn(frstn[0]), // reset - active low
    // Outputs
    .clk_adc_1x(adc_clk),       // ADC clock 125 MHz
    .clk_adc_2x(adc_clk_2x),    // ADC clock 250 MHz
    .clk_adc_3x(adc_clk_3x),    // ADC clock 375 MHz
    .clk_dac_iqsel(dac_clk_iqsel),    // DAC IQSEL clock 62.5 MHz
    .clk_dac_iqclk(dac_clk_iqclk),    // DAC IQCLK clock 125 MHz +90 DGR (2 ns)
    .clk_dac_iqwrt(dac_clk_iqwrt),    // DAC clock 125 MHz +112.5 DGR (2.5 ns)
    .clk_out_10MHz(clk_out_10),    // Daisy chain clock 10 MHz
    .locked(pll_locked)
);
assign pwm_clk = adc_clk_2x;

// ADC reset (active low) 
always @(posedge adc_clk)
adc_rstn <=  frstn[0] &  pll_locked;

// DAC reset (active high)
always @(posedge dac_clk_iqsel)
dac_rst  <= ~frstn[0] | ~pll_locked;

// PWM reset (active low)
always @(posedge pwm_clk)
pwm_rstn <=  frstn[0] &  pll_locked;


////////////////////////////////////////////////////////////////////////////////
// ADC I/O
////////////////////////////////////////////////////////////////////////////////
//

// ADC CDCS Output Register
reg adc_cdcs_reg = 1'b1;    // ADC clock duty cycle stabilizer is enabled

// ADC Data Input Buffer
wire  [16-1: 2] adc_dat_a_i_buff;   // ADC CH1 buffer
wire  [16-1: 2] adc_dat_b_i_buff;   // ADC CH2 buffer

// ADC Data Input Register
wire        [14-1:0] adc_dat_a, adc_dat_b;
reg  signed [14-1:0] adc_a    , adc_b    ;

// ADC Encoder clock
//// generating ADC encoder clock is disabled
//assign adc_clk_o = 2'b10;
//ODDR i_adc_clk_p ( .Q(adc_clk_o[0]), .D1(1'b1), .D2(1'b0), .C(fclk[0]), .CE(1'b1), .R(1'b0), .S(1'b0));
//ODDR i_adc_clk_n ( .Q(adc_clk_o[1]), .D1(1'b0), .D2(1'b1), .C(fclk[0]), .CE(1'b1), .R(1'b0), .S(1'b0));

// ADC CDCS Output Buffer
OBUF #(
    .IOSTANDARD("LVCMOS18") // Specify the output I/O standard
) OBUF_inst_adc_cdcs_o (
  .O(adc_cdcs_o),   // Buffer output (connect directly to top-level port)
  .I(adc_cdcs_reg)  // Buffer input
);

// ADC-A Data Input Buffer
IBUF #(
  .IBUF_LOW_PWR("FALSE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
  .IOSTANDARD("LVCMOS18")  // Specify the input I/O standard
) IBUF_inst_adc_dat_a_i[16-1:2] (
  .O(adc_dat_a_i_buff),     // Buffer output
  .I(adc_dat_a_i)      // Buffer input (connect directly to top-level port)
);

// ADC-B Data Input Buffer
IBUF #(
  .IBUF_LOW_PWR("FALSE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
  .IOSTANDARD("LVCMOS18")  // Specify the input I/O standard
) IBUF_inst_adc_dat_b_i[16-1:2] (
  .O(adc_dat_b_i_buff),     // Buffer output
  .I(adc_dat_b_i)      // Buffer input (connect directly to top-level port)
);

// ADC Data Input Register
//// lowest 2 bits reserved for 16bit ADC (Current is only 14bit)
assign adc_dat_a = adc_dat_a_i_buff[16-1:2];
assign adc_dat_b = adc_dat_b_i_buff[16-1:2];
//// transform offset binary representation into 2's complement (invert MSB)
always @(posedge adc_clk)
begin
  adc_a <= {adc_dat_a[14-1], ~adc_dat_a[(14-1)-1:0]};
  adc_b <= {adc_dat_b[14-1], ~adc_dat_b[(14-1)-1:0]};
end
    

////////////////////////////////////////////////////////////////////////////////
// DAC I/O
////////////////////////////////////////////////////////////////////////////////
//

// DAC signals
reg          [14-1:0] dac_dat_a, dac_dat_b;
wire         [14-1:0] dac_a    , dac_b    ;

// output registers + 2's complement to offset binary
always @(posedge dac_clk_iqsel)
begin
  dac_dat_a <= {dac_a[14-1], ~dac_a[(14-1)-1:0]};
  dac_dat_b <= {dac_b[14-1], ~dac_b[(14-1)-1:0]};
end

// DDR outputs
//ODDR oddr_dac_clk          (.Q(dac_clk_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_iqwrt), .CE(1'b1), .R(1'b0   ), .S(1'b0));
//ODDR oddr_dac_wrt          (.Q(dac_wrt_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_iqclk), .CE(1'b1), .R(1'b0   ), .S(1'b0));
//ODDR oddr_dac_sel          (.Q(dac_sel_o), .D1(1'b1     ), .D2(1'b0     ), .C(dac_clk_iqsel), .CE(1'b1), .R(dac_rst), .S(1'b0));
//ODDR oddr_dac_rst          (.Q(dac_rst_o), .D1(dac_rst  ), .D2(dac_rst  ), .C(dac_clk_iqsel), .CE(1'b1), .R(1'b0   ), .S(1'b0));
//ODDR oddr_dac_dat [14-1:0] (.Q(dac_dat_o), .D1(dac_dat_b), .D2(dac_dat_a), .C(dac_clk_iqsel), .CE(1'b1), .R(dac_rst), .S(1'b0));

// DAC IQCLK DDR Output Register
ODDR #(
  .DDR_CLK_EDGE("SAME_EDGE") // D1,D2 available concurrently
) ODDR_inst_oddr_dac_clk (
  .Q(dac_clk_o),   // 1-bit DDR output
  .C(dac_clk_iqclk),   // IQCLK clock input, 125 MHz + 90 DGR (+2 ns)
  .CE(1'b1), // Clock enabled
  .D1(1'b1), // Clock passthrough input (positive edge)
  .D2(1'b0), // Clock passthrough input (negative edge)
  .R(1'b0)   // No reset
);

// DAC IQWRT DDR Output Register
ODDR #(
  .DDR_CLK_EDGE("SAME_EDGE") // D1,D2 available concurrently
) ODDR_inst_oddr_dac_wrt (
  .Q(dac_wrt_o),   // 1-bit DDR output
  .C(dac_clk_iqwrt),   // IQWRT clock input
  .CE(1'b1), // Clock enabled
  .D1(1'b1), // Clock passthrough input (positive edge)
  .D2(1'b0), // Clock passthrough input (negative edge)
  .R(1'b0)   // No reset
);

// DAC IQSEL DDR Output Register
ODDR #(
  .DDR_CLK_EDGE("SAME_EDGE") // D1,D2 available concurrently
) ODDR_inst_oddr_dac_sel (
  .Q(dac_sel_o),   // 1-bit DDR output
  .C(dac_clk_iqsel),   // IQSEL clock input, 62.5 MHz
  .CE(1'b1), // Clock enabled
  .D1(1'b1), // Clock passthrough input (positive edge)
  .D2(1'b0), // Clock passthrough input (negative edge)
  .R(1'b0)   // No reset
);

// DAC Data DDR Output Registers
ODDR #(
  .DDR_CLK_EDGE("SAME_EDGE") // D1,D2 available concurrently
) ODDR_inst_oddr_dac_dat[14-1:0] (
  .Q(dac_dat_o),        // 14-bit DDR output
  .C(dac_clk_iqsel),    // IQSEL clock input, 62.5 MHz
  .CE(1'b1),            // Clock enabled
  .D1(dac_dat_b),       // 14-bit data input (positive edge)
  .D2(dac_dat_a),       // 14-bit data input (negative edge)
  .R(1'b0)              // No reset
);

// DAC IQRESET DDR Output Register
ODDR #(
  .DDR_CLK_EDGE("SAME_EDGE") // D1,D2 available concurrently
) ODDR_inst_oddr_dac_rst (
  .Q(dac_rst_o),        // 1-bit DDR output
  .C(dac_clk_iqsel),    // IQSEL clock input, 62.5 MHz
  .CE(1'b1),            // Clock enabled
  .D1(dac_rst),         // IQRESET passthrough (positive edge)
  .D2(dac_rst),         // IQRESET passthrough (negative edge)
  .R(1'b0)              // No reset
);


////////////////////////////////////////////////////////////////////////////////
//  Digital-PLL module
////////////////////////////////////////////////////////////////////////////////
// 2 inputs, 2 outputs
//

wire signed [15:0] ADCraw0, ADCraw1;
wire signed [15:0] DACout0, DACout1;
wire [16-1:0] LoggerData;
wire LoggerData_clk_enable;
wire LoggerIsWriting;

reg dpll_output_selector;

wire [ 32-1:0] dpll_output;
wire dpll_ack;
wire [ 32-1:0] addr_packed_output;
wire addr_packed_ack;

reg selected_ack;
reg [32-1:0] selected_output;

wire fifo_empty;
wire fifo_full;


wire debug_out_1;
wire debug_out_2;
wire debug_out_3;
wire debug_out_4;

reg [26-1:0] led_counter;

assign ADCraw0 = {adc_a, 2'b0};
assign ADCraw1 = {adc_b, 2'b0};
// assign dac_a = DACout0[16-1:2];   // converts 16 bits DACout to 14 bits for dac_a
// assign dac_b = DACout1[16-1:2];   // converts 16 bits DACout to 14 bits for dac_b

wire dpll_rst = 1'b0; // I don't know if we can use the RedPitaya's reset because I don't know if it is clock-synchronous or not. In any case, it does not matter because we have the sys_bus driven resets.

// DPLL Wrapper
dpll_wrapper dpll_wrapper_inst (
  
  .clk1                    (  adc_clk                    ), // global clock, designed for 100 MHz clock rate
  .clk1_2x                 (  adc_clk_2x                 ), // this should be 2 times the clock, phase-locked to clk1, N matching what was input in the FIR compiler for fir_compiler_minimumphase_N_times_clk
  .clk1_3x                 (  adc_clk_3x                 ),
  .rst                     (  dpll_rst                   ), // currently only use the resets driven by the system bus

  // analog data input/output interface
  .ADCraw0                 (  ADCraw0                    ),
  .ADCraw1                 (  ADCraw1                    ),
  .DACout0                 (  DACout0                    ),
  .DACout1                 (  DACout1                    ),

  // Data logger port:
  .LoggerData              (  LoggerData                 ),
  .LoggerData_clk_enable   (  LoggerData_clk_enable      ),
  .LoggerIsWriting         (  LoggerIsWriting            ),

  // System bus
  .sys_addr                (  sys_addr                   ),  // address
  .sys_wdata               (  sys_wdata                  ),  // write data
  .sys_sel                 (  sys_sel                    ),  // write byte select
  .sys_wen                 (  sys_wen[0]                 ),  // write enable
  .sys_ren                 (  sys_ren[0]                 ),  // read enable
  .sys_rdata               (  sys_rdata[ 0*32+31: 0*32]  ),  // read data                     -- sys_rdata[ 0*32+31: 0*32]
  .sys_err                 (  sys_err[0]                 ),  // error indicator
  .sys_ack                 (  sys_ack[0]                 )   // acknowledge signal            -- sys_ack[0]
);

// 
addr_packed addr_packed_inst (
  .clk                    ( adc_clk                   ),
  .rst                    ( adc_rstn                  ),
  .sys_addr               ( sys_addr                  ),
  .sys_wdata              ( sys_wdata                 ),
  .sys_wen                ( sys_wen[0]                ),
  .sys_ren                ( sys_ren[2]                ),
  .sys_rdata              ( sys_rdata[ 2*32+31: 2*32] ),
  .sys_err                ( sys_err[2]                ),
  .sys_ack                ( sys_ack[2]                ),
  .out_empty              ( fifo_empty                ),
  .out_full               ( fifo_full                 )
);


always @(posedge adc_clk) begin
  if (adc_rstn == 1'b0) begin
    led_counter <= 26'h0;
  end
  else begin
    led_counter <= led_counter + 26'h1;
  end
end

assign led_o = {fifo_empty, fifo_full, led_counter[25], 4'b0};


////////////////////////////////////////////////////////////////////////////////
// BRAM Data Logger
////////////////////////////////////////////////////////////////////////////////
// BRAM-based data logger, replaces the Red Pitaya oscilloscope application, but has much simpler behavior:
// The write port is directly controlled by the DPLL module, while the reads happen through the Zynq sys_bus
//

// // for testing independently of the DPLL module:
// assign LoggerData = adc_a;
// assign LoggerData_clk_enable = 1'b1;

ram_data_logger ram_data_logger_i (
  .clk                  (  adc_clk                    ),
  
  // data input interface
  .data_in              (  LoggerData                 ),
  .data_in_clk_enable   (  LoggerData_clk_enable      ),
  // control interface
  .is_writing           (  LoggerIsWriting            ),
  
  // CPU interface
  .sys_addr             (  sys_addr                   ),  // address
  .sys_wdata            (  sys_wdata                  ),  // write data
  .sys_sel              (  sys_sel                    ),  // write byte select
  .sys_wen              (  sys_wen[1]                 ),  // write enable
  .sys_ren              (  sys_ren[1]                 ),  // read enable
  .sys_rdata            (  sys_rdata[ 1*32+31: 1*32]  ),  // read data
  .sys_err              (  sys_err[1]                 ),  // error indicator
  .sys_ack              (  sys_ack[1]                 )   // acknowledge signal
  );


////////////////////////////////////////////////////////////////////////////////
//  House Keeping (HK)
////////////////////////////////////////////////////////////////////////////////
//

wire  [  8-1: 0] exp_p_in , exp_n_in ;
wire  [  8-1: 0] exp_p_out, exp_n_out;
wire  [  8-1: 0] exp_p_dir, exp_n_dir;

wire  [  8-1: 0] exp_p_in_hk , exp_n_in_hk ;
wire  [  8-1: 0] exp_p_out_hk, exp_n_out_hk;
wire  [  8-1: 0] exp_p_dir_hk, exp_n_dir_hk;

wire  [ 8-1: 0] led_o_hk;

wire            digital_loop_hk;

red_pitaya_hk i_hk (
  // system signals
  .clk_i           (  adc_clk                    ),  // clock
  .rstn_i          (  adc_rstn                   ),  // reset - active low
  // LED
  .led_o           (  led_o_hk                   ),  // LED output
  // global configuration
  .digital_loop    (  digital_loop_hk            ),
  // Expansion connector
  .exp_p_dat_i     (  exp_p_in_hk                ),  // input data
  .exp_p_dat_o     (  exp_p_out_hk               ),  // output data
  .exp_p_dir_o     (  exp_p_dir_hk               ),  // 1-output enable
  .exp_n_dat_i     (  exp_n_in_hk                ),
  .exp_n_dat_o     (  exp_n_out_hk               ),
  .exp_n_dir_o     (  exp_n_dir_hk               ),
   // System bus
  .sys_addr        (  sys_addr                   ),  // address
  .sys_wdata       (  sys_wdata                  ),  // write data
  .sys_sel         (  sys_sel                    ),  // write byte select
  .sys_wen         (  sys_wen[3]                 ),  // write enable
  .sys_ren         (  sys_ren[3]                 ),  // read enable
  .sys_rdata       (  sys_rdata[ 3*32+31: 3*32]  ),  // read data
  .sys_err         (  sys_err[3]                 ),  // error indicator
  .sys_ack         (  sys_ack[3]                 )   // acknowledge signal
);

// // always @(posedge adc_clk) begin
// //   if (adc_rstn == 1'b0) begin
// //     led_counter <= 26'h0;
// //   end
// //   else begin
// //     led_counter <= led_counter + 26'h1;
// //   end
// // end


assign exp_n_out = {8'b10000000};
assign exp_p_out = {8'b00000000};
assign exp_n_dir = {8'b11111111};
assign exp_p_dir = {8'b11111111};

IOBUF i_iobufp [8-1:0] (.O(exp_p_in), .IO(exp_p_io), .I(exp_p_out_hk), .T(~exp_p_dir) );
IOBUF i_iobufn [8-1:0] (.O(exp_n_in), .IO(exp_n_io), .I(exp_n_out_hk), .T(~exp_n_dir) );


////////////////////////////////////////////////////////////////////////////////
// VCO and output mux
////////////////////////////////////////////////////////////////////////////////
// Channel 5
//

wire signed [14-1 : 0] to_DAC0;
wire signed [14-1 : 0] to_DAC1;

mux_internal_vco mux_vco (
  .clk            ( adc_clk                   ), // clock
  .DACin0         ( DACout0                   ), // output of the DPLL channel a
  .DACin1         ( DACout1                   ), // output of the DPLL channel b
  // internal configuration bus
  .sys_addr       ( sys_addr                  ), // address
  .sys_wdata      ( sys_wdata                 ), // write data
  .sys_sel        ( sys_sel                   ), // write byte select
  // communication bus for the vco
  .sys_wen_vco    (sys_wen[6]                 ), // write enable for the vco
  .sys_ren_vco    (sys_ren[6]                 ), // read enable for the vco
  .sys_rdata_vco  (sys_rdata[ 6*32+31: 6*32]  ), // read data for the vco
  .sys_err_vco    (sys_err[6]                 ), // error indicator for the vco
  .sys_ack_vco    (sys_ack[6]                 ), // acknowledge signal for the vco
  // communication bus for the mux
  .sys_wen_mux    (sys_wen[5]                 ), // write enable for the mux
  .sys_ren_mux    (sys_ren[5]                 ), // read enable for the mux
  .sys_rdata_mux  (sys_rdata[ 5*32+31: 5*32]  ), // read data for the mux
  .sys_err_mux    (sys_err[5]                 ), // error indicator for the mux
  .sys_ack_mux    (sys_ack[5]                 ), // acknowledge signal for the mux
  // output
  .DACa_out       ( to_DAC0                  ), // output to the dac (from vco or directly from dpll)
  .DACb_out       ( to_DAC1                  )  // output to the dac (from vco or directly from dpll)
  );

assign dac_a = to_DAC0;
assign dac_b = to_DAC1;


////////////////////////////////////////////////////////////////////////////////
//  Oscilloscope application
////////////////////////////////////////////////////////////////////////////////
// JDD: I kept this here just because it seems like we need to keep the axi0 and axi1 modules,
// otherwise the Zynq PS hangs up everytime we try to access the FPGA's address space.
// Eventually I should figure out how to properly remove them without this lock-up problem.
// It could simply be related to the fact that axi0_clk and axi1_clk are in fact connected to adc_clk inside this module,
// but it could also be that we need to 'ack' transactions in some manner which is implemented by the axi-fifos inside...
//

wire trig_asg_out ;

red_pitaya_scope i_scope (
  // ADC
  // .adc_a_i         (  adc_a                      ),  // CH 1
  // .adc_b_i         (  adc_b                      ),  // CH 2
  .adc_clk_i       (  adc_clk                    ),  // clock
  .adc_rstn_i      (  adc_rstn                   ),  // reset - active low
  // .trig_ext_i      (  exp_p_in[0]                ),  // external trigger
  // .trig_asg_i      (  trig_asg_out               ),  // ASG trigger
  // AXI0 master                 // AXI1 master
  .axi0_clk_o    (axi0_clk   ),  .axi1_clk_o    (axi1_clk   ),
  .axi0_rstn_o   (axi0_rstn  ),  .axi1_rstn_o   (axi1_rstn  ),
  .axi0_waddr_o  (axi0_waddr ),  .axi1_waddr_o  (axi1_waddr ),
  .axi0_wdata_o  (axi0_wdata ),  .axi1_wdata_o  (axi1_wdata ),
  .axi0_wsel_o   (axi0_wsel  ),  .axi1_wsel_o   (axi1_wsel  ),
  .axi0_wvalid_o (axi0_wvalid),  .axi1_wvalid_o (axi1_wvalid),
  .axi0_wlen_o   (axi0_wlen  ),  .axi1_wlen_o   (axi1_wlen  ),
  .axi0_wfixed_o (axi0_wfixed),  .axi1_wfixed_o (axi1_wfixed),
  .axi0_werr_i   (axi0_werr  ),  .axi1_werr_i   (axi1_werr  ),
  .axi0_wrdy_i   (axi0_wrdy  ),  .axi1_wrdy_i   (axi1_wrdy  )
  // // System bus
  // .sys_addr        (  sys_addr                   ),  // address
  // .sys_wdata       (  sys_wdata                  ),  // write data
  // .sys_sel         (  sys_sel                    ),  // write byte select
  // .sys_wen         (  sys_wen[1]                 ),  // write enable
  // .sys_ren         (  sys_ren[1]                 ),  // read enable
  // .sys_rdata       (  sys_rdata[ 1*32+31: 1*32]  ),  // read data
  // .sys_err         (  sys_err[1]                 ),  // error indicator
  // .sys_ack         (  sys_ack[1]                 )   // acknowledge signal
);


////////////////////////////////////////////////////////////////////////////////
//  Analog mixed signals (AMS)
////////////////////////////////////////////////////////////////////////////////
//  XADC and slow PWM DAC control
//

wire  [ 24-1: 0] pwm_cfg_a;
wire  [ 24-1: 0] pwm_cfg_b;
wire  [ 24-1: 0] pwm_cfg_c;
wire  [ 24-1: 0] pwm_cfg_d;

red_pitaya_ams i_ams (
  // power test
 .clk_i           (  adc_clk                    ),  // clock
 .rstn_i          (  adc_rstn                   ),  // reset - active low
 // PWM configuration
 .dac_a_o         (  pwm_cfg_a                  ),
 .dac_b_o         (  pwm_cfg_b                  ),
 .dac_c_o         (  pwm_cfg_c                  ),
 .dac_d_o         (  pwm_cfg_d                  ),
  // System bus
 .sys_addr        (  sys_addr                   ),  // address
 .sys_wdata       (  sys_wdata                  ),  // write data
 .sys_sel         (  sys_sel                    ),  // write byte select
 .sys_wen         (  sys_wen[4]                 ),  // write enable
 .sys_ren         (  sys_ren[4]                 ),  // read enable
 .sys_rdata       (  sys_rdata[ 4*32+31: 4*32]  ),  // read data
 .sys_err         (  sys_err[4]                 ),  // error indicator
 .sys_ack         (  sys_ack[4]                 )   // acknowledge signal
);

red_pitaya_pwm pwm [4-1:0] (
 // system signals
 .clk   (pwm_clk ),
 .rstn  (pwm_rstn),
 // configuration
 .cfg   ({pwm_cfg_d, pwm_cfg_c, pwm_cfg_b, pwm_cfg_a}),
 // PWM outputs
 .pwm_o (dac_pwm_o),
 .pwm_s ()
);


////////////////////////////////////////////////////////////////////////////////
//  Daisy chain
////////////////////////////////////////////////////////////////////////////////
//  simple communication module
//

reg [3-1:0] daisy_counter;

always @(posedge adc_clk) begin
  if (adc_rstn == 1'b0) begin
    daisy_counter <= 3'h0;
  end
  else begin
    daisy_counter <= daisy_counter + 3'h1;
  end
end

assign daisy_p_o = {clk_out_10, 1'bz};  //Important : if you want to use only one of the signals (p or n), terminate the other one with a 50 Ohm. To do so
assign daisy_n_o = {~clk_out_10, 1'bz};   // we built a SATA connector with 2 SMA connector at the end (one for the "p" and one for the "n" signal).


endmodule
