// Digital-PLL wrapper
// JDD 2016

`default_nettype none   // This disables implicit variable declaration, which I really don't like as a feature as it lets bugs go unreported

module dpll_wrapper(
///////////////////////////////////////////////////////////////////////////////
// Inputs and Outputs:
///////////////////////////////////////////////////////////////////////////////
//

    input  wire     clk1,    // global clock, 125 MHz
    input  wire     clk1_2x, // this should be N times the clock, phase-locked to clk1, N matching what was input in the FIR compiler for fir_compiler_minimumphase_N_times_clk
    input  wire     clk1_3x,
    input  wire     rst,

    // analog data input/output interface
    input  wire signed [16-1:0] ADCraw0,
    input  wire signed [16-1:0] ADCraw1,
    output wire signed [16-1:0] DACout0,
    output wire signed [16-1:0] DACout1,

    // Data logger port:
    output wire [16-1:0]    LoggerData,
    output wire             LoggerData_clk_enable,
    input  wire             LoggerIsWriting,

    // System bus
    input  wire [32-1:0]    sys_addr   ,  // bus address
    input  wire [32-1:0]    sys_wdata  ,  // bus write data
    input  wire [4-1:0]     sys_sel    ,  // bus write byte select
    input  wire             sys_wen    ,  // bus write enable
    input  wire             sys_ren    ,  // bus read enable
    output wire [32-1:0]    sys_rdata  ,  // bus read data
    output wire             sys_err    ,  // bus error indicator
    output wire             sys_ack       // bus acknowledge signal

);

// Local Parameters
localparam SIGNAL_SIZE = 16;


///////////////////////////////////////////////////////////////////////////////
// Configuration Bus:
///////////////////////////////////////////////////////////////////////////////
//

wire [16-1:0]        cmd_addr;
wire [16-1:0]        cmd_data1in, cmd_data2in;
wire                 cmd_trig;

// conversion from Zynq-style parallel bus to the legacy Opal-Kelly-style bus:
assign cmd_trig    = sys_wen;
assign cmd_addr    = sys_addr [(16+2)-1:2];   // note that we divide the Zynq addresses by 4 when mapping to the DPLL addresses.  This is because the Zynq cannot address memory locations that are not on 32-bits boundaries, but the legacy bus didn't have this restriction.
assign cmd_data1in = sys_wdata[16-1:0];
assign cmd_data2in = sys_wdata[32-1:16];


///////////////////////////////////////////////////////////////////////////////
// Reset Signals:
///////////////////////////////////////////////////////////////////////////////
//

wire reset_frontend; // Trigger Frontend Reset

wire bus_rst;

reg rst_peripherals, rst_peripherals_output1, rst_peripherals_output2, rst_peripherals_internal, rst_peripherals_output1_internal, rst_peripherals_output2_internal;    // we split the reset signal in a tree to try help with the fanout, and hope that xst won't combine our register
reg rst_frontend0, rst_frontend1, rst_frontend0_internal, rst_frontend1_internal;

reg [16-1:0] reset_counter = 16'b1111111111111111;    // 2**16 cycles * 8 ns/cycle = 524 us of maximum reset time
reg [16-1:0] reset_counter_frontend = 16'b1111111111111111;   // 2**16 cycles * 8 ns/cycle = 524 us of maximum reset time

// "Reset Frontend" Trigger
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h0044)
) parallel_bus_register_phase_ok_reset_frontend (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(), 
    .update_flag(reset_frontend)
);

//assign DOUT[2] = rst_frontend0;
always @(posedge clk1) begin
    
    if (rst == 1'b1 | bus_rst == 1'b1) begin
        reset_counter <= 16'b1111111111111111;
    end
    else begin
        if (reset_counter > 0) begin
            reset_counter <= reset_counter - 1'b1;
        end
        
        // The different reset groups are compared each to a different value,
        // to make sure that Xilinx doesn't combine the registers into a single reset signal driving a very large fanout
        rst_peripherals_internal         <= ((reset_counter > 3) ? 1'b1 : 1'b0);
        rst_peripherals_output1_internal <= ((reset_counter > 4) ? 1'b1 : 1'b0);
        rst_peripherals_output2_internal <= ((reset_counter > 5) ? 1'b1 : 1'b0);
        
        // An extra register stage to help with routing
        rst_peripherals <= rst_peripherals_internal;
        rst_peripherals_output1 <= rst_peripherals_output1_internal;
        rst_peripherals_output2 <= rst_peripherals_output2_internal;
        
    end
end

always @(posedge clk1) begin
    
    if (reset_frontend == 1'b1) begin
        reset_counter_frontend <= 16'b1111111111111111;
    end
    else begin
        if (reset_counter_frontend > 0) begin
            reset_counter_frontend <= reset_counter_frontend - 1'b1;
        end
        
        // The different reset groups are compared each to a different value,
        // to make sure that Xilinx doesn't combine the registers into a single reset signal driving a very large fanout
        rst_frontend0_internal              <= ((reset_counter_frontend > 1) ? 1'b1 : 1'b0);
        rst_frontend1_internal              <= ((reset_counter_frontend > 2) ? 1'b1 : 1'b0);
        
        // An extra register stage to help with routing
        rst_frontend0 <= rst_frontend0_internal;
        rst_frontend1 <= rst_frontend1_internal;
        
    end
end


///////////////////////////////////////////////////////////////////////////////
// Digital Down Converter (DDC):
///////////////////////////////////////////////////////////////////////////////
// Brings a signal to baseband, low-pass filters it, and outputs the phase and frequency
//

wire        [12-1:0]    boxcar_filter_size = 12'd20;    // Filter with a notch at 5 MHz: 125MHz/5MHz = 25 samples
wire signed [48-1:0]    reference_frequency0;
wire signed [10-1:0]    wrapped_phase0; // phi/(2*pi) * 2**10
wire signed [10-1:0]    inst_frequency0;    // diff(phi)/(2*pi) * 2**10
wire signed [(10+12)-1:0]   inst_frequency0_filtered;   // this is the output of a boxcar filter on the inst_frequency signal, before sending to the DDR2 logger
wire signed [(10+2)-1:0]    inst_frequency0_filtered_small; // overall filter gain is only equal to its length (4) so we don't really need all the bits
wire [2-1:0]    ddc0_filter_select, ddc1_filter_select;
wire select_phase_or_freq0, select_phase_or_freq1;
wire [4-1:0]    angleSelect_0, angleSelect_1;

wire signed [48-1:0]    reference_frequency1;
wire signed [10-1:0]    wrapped_phase1;     // phi/(2*pi) * 2**10
wire signed [10-1:0]    DDC1_freq_output;   // diff(phi)/(2*pi) * 2**10
wire signed [10-1:0]    inst_frequency1;    // diff(phi)/(2*pi) * 2**10 //now output from the mux that select between DDC1_freq_output, inst_frequency0 or pll0_output
wire signed [(10+12)-1:0]   inst_frequency1_filtered;   // this is the output of a boxcar filter on the inst_frequency signal, before sending to the DDR2 logger
wire signed [(10+2)-1:0]    inst_frequency1_filtered_small; // overall filter gain is only equal to its length (4) so we don't really need all the bits

//-----------------------------------------------------------------------------
// DDC Input Registers:
//

// Reference Frequency 0 Register
parallel_bus_register_64_bits_or_less # (
    .REGISTER_SIZE(48),
    .ADDRESS(16'h8000) // h8000 and h8001
) parallel_bus_register_64_bits_or_less_freq0 (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(reference_frequency0), 
     .update_flag()
);

// "Phase or Frequency" and DDC Filter Selection Registers
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(6),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8002)
) parallel_bus_register_ddc_filter_select (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output({select_phase_or_freq1, select_phase_or_freq0, ddc1_filter_select, ddc0_filter_select}), 
     .update_flag()
);

// "Angle Selection" Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(8'b0),
    .ADDRESS(16'h8004)
) parallel_bus_register_64_bits_or_less_angleSelect (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output({angleSelect_1,angleSelect_0}), 
     .update_flag()
);

// Reference Frequency 1 Register
parallel_bus_register_64_bits_or_less # (
    .REGISTER_SIZE(48),
    .ADDRESS(16'h8010)
) parallel_bus_register_64_bits_or_less_freq1 (
     .clk(clk1), 
     .bus_strobe(cmd_trig), 
     .bus_address(cmd_addr), 
     .bus_data({cmd_data2in, cmd_data1in}), 
     .register_output(reference_frequency1), 
     .update_flag()
);

//-----------------------------------------------------------------------------
// DDC for ADC 0:
//

DDC_wideband_filters DDC0_inst (
    .rst(rst_frontend0), 
    .clk(clk1), 
    .clk_times_N(clk1_2x),
    .data_input(ADCraw0),     // 
     
    // Configuration
    .boxcar_filter_size(boxcar_filter_size),
    .reference_frequency(reference_frequency0), 
    .ddc_filter_select(ddc0_filter_select),
    
    // Reference tone output:
    .ref_cosine_out(ref_cosine_0),
    .ref_sine_out(ref_sine_0),
    
    // Used for nulling the lock phase offset:
    .lock(pll0_lock),
    .angleSelect(angleSelect_0),
     
     // Output
    .amplitude(), 
    .wrapped_phase(wrapped_phase0), 
    .inst_frequency(inst_frequency0)
);
     
//-----------------------------------------------------------------------------
// DDC for ADC 1:
//

DDC_wideband_filters DDC1_inst (
    .rst(rst_frontend1), 
    .clk(clk1), 
    .clk_times_N(clk1_2x),
    .data_input(ADCraw1),
     
     // Configuration
    .boxcar_filter_size(boxcar_filter_size),
    .reference_frequency(reference_frequency1), 
    .ddc_filter_select(ddc1_filter_select),
     
    // Reference tone output:
    .ref_cosine_out(ref_cosine_1),
    .ref_sine_out(ref_sine_1),
    
    // Used to null out the phase offset
    .lock(pll1_lock),
    .angleSelect(angleSelect_1),
     
     // Output
    .amplitude(), 
    .wrapped_phase(wrapped_phase1), 
    .inst_frequency(DDC1_freq_output) //we changed the output name from inst_frequency1 to DDC1_freq_output to be able to select the input of the Loop Filter with a multiplexer
);


///////////////////////////////////////////////////////////////////////////////
// Loop Filters:
///////////////////////////////////////////////////////////////////////////////
//

// Address Offsets
localparam LF_CH0_ADDR = 16'h7000;
localparam LF_CH1_ADDR = 16'h7010;

localparam LF_LOCK_ADDR_OFFSET =    16'h0000;
localparam LF_GAIN_P_ADDR_OFFSET =  16'h0001;
localparam LF_GAIN_I_ADDR_OFFSET =  16'h0002;
localparam LF_GAIN_II_ADDR_OFFSET = 16'h0003;
localparam LF_GAIN_D_ADDR_OFFSET =  16'h0004;
localparam LF_COEF_DF_ADDR_OFFSET = 16'h0005;
localparam LF_GAIN_OL_ADDR_OFFSET = 16'h0006;

// Channel 0 Loop Filter
wire signed [32-1:0] pll0_gainp, pll0_gaini, pll0_gainii, pll0_gaind;
wire signed [18-1:0] pll0_coefdfilter;
wire signed [16-1:0] pll0_output;
wire pll0_lock, pll0_gain_changedp, pll0_gain_changedi, pll0_gain_changedii, pll0_gain_changedd, pll0_coef_changedd;
wire pll0_gain_changed;
wire signed [32-1:0] phase_residuals0;

// Multiplexer for Channel 1 Input
wire [2-1:0] loop_filter_1_mux_selector;
wire signed [(10-1):0] inst_frequency0_to_pll1;
wire signed [(10-1):0] pll0_output_to_pll1;

// Channel 1 Loop Filter
wire signed [32-1:0] pll1_gainp, pll1_gaini, pll1_gainii, pll1_gaind;
wire signed [18-1:0] pll1_coefdfilter;
wire signed [16-1:0] pll1_output;
wire pll1_lock, pll1_gain_changedp, pll1_gain_changedi, pll1_gain_changedii, pll1_gain_changedd, pll1_coef_changedd;
wire pll1_gain_changed;
wire signed [32-1:0] phase_residuals1;

//-----------------------------------------------------------------------------
// Channel 0 Loop Filters Input Registers:
//

// Channel 0 Lock Enable Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_LOCK_ADDR_OFFSET)
) parallel_bus_register_pll0_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_lock), 
    .update_flag()
);

// Channel 0 Proportional Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_GAIN_P_ADDR_OFFSET)
) parallel_bus_register_pll0_gainp (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gainp), 
    .update_flag(pll0_gain_changedp)
);

// Channel 0 Integral Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_GAIN_I_ADDR_OFFSET)
) parallel_bus_register_pll0_gaini (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gaini), 
    .update_flag(pll0_gain_changedi)
);

// Channel 0 Double Integral Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_GAIN_II_ADDR_OFFSET)
) parallel_bus_register_pll0_gainii (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gainii), 
    .update_flag(pll0_gain_changedii)
);

// Channel 0 Derivative Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_GAIN_D_ADDR_OFFSET)
) parallel_bus_register_pll0_gaind (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_gaind), 
    .update_flag(pll0_gain_changedd)
);

// Channel 0 Derivative Filter Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(18),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH0_ADDR+LF_COEF_DF_ADDR_OFFSET)
) parallel_bus_register_pll0_coefdfilter (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll0_coefdfilter), 
    .update_flag(pll0_coef_changedd)
);

//-----------------------------------------------------------------------------
// Channel 1 Loop Filters Input Registers:
//

// Channel 1 Lock Enable Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_LOCK_ADDR_OFFSET)
) parallel_bus_register_pll1_settings (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_lock), 
    .update_flag()
);

// Channel 1 Proportional Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_GAIN_P_ADDR_OFFSET)
) parallel_bus_register_pll1_gainp (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gainp), 
    .update_flag(pll1_gain_changedp)
);

// Channel 1 Integral Gain Register 
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_GAIN_I_ADDR_OFFSET)
) parallel_bus_register_pll1_gaini (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gaini), 
    .update_flag(pll1_gain_changedi)
);

// Channel 1 Double Integral Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_GAIN_II_ADDR_OFFSET)
) parallel_bus_register_pll1_gainii (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gainii), 
    .update_flag(pll1_gain_changedii)
);

// Channel 1 Derivative Gain Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_GAIN_D_ADDR_OFFSET)
) parallel_bus_register_pll1_gaind (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_gaind), 
    .update_flag(pll1_gain_changedd)
);

// Channel 1 Derivative Filter Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(18),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(LF_CH1_ADDR+LF_COEF_DF_ADDR_OFFSET)
) parallel_bus_register_pll1_coefdfilter (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(pll1_coefdfilter), 
    .update_flag(pll1_coef_changedd)
);

// Channel 1 Input Multiplexer Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(2),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h9000)
) parallel_bus_register_mux_pll1  (
 .clk                           (clk1                       ), 
 .bus_strobe                    (cmd_trig                   ), 
 .bus_address                   (cmd_addr                   ), 
 .bus_data                      ({cmd_data2in, cmd_data1in} ), 
 .register_output               (loop_filter_1_mux_selector ), 
 .update_flag                   (                           )
);

//-----------------------------------------------------------------------------
// Channel 0 Loop Filter:
//

// This is used for bumpless change of the gain settings (TODO, most probably in the output summing block)
assign pll0_gain_changed = pll0_gain_changedp | pll0_gain_changedi | pll0_gain_changedii | pll0_gain_changedd | pll0_coef_changedd;

// Finally the PLL itself:
PLL_loop_filters_with_saturation # (
    .N_DIVIDE_P(10),
    .N_DIVIDE_I(27),
    .N_DIVIDE_II(36),
    .N_DIVIDE_D(11),
    .N_OUTPUT(16)
) PLL0_loop_filters (
    .clk(clk1), 
    .lock(pll0_lock), 
    .gain_changed(pll0_gain_changed), 
    .data_in(inst_frequency0), 
    .gain_p(pll0_gainp), 
    .gain_i(pll0_gaini), 
    .gain_ii(pll0_gainii),
    .gain_d(pll0_gaind),
    .coef_d_filter(pll0_coefdfilter),
    .phase_residuals(phase_residuals0),
    .data_out(pll0_output),
    .saturated_low(),
    .saturated_high()
);

//-----------------------------------------------------------------------------
// Multiplexer for Channel 1 Input:
//

// Change the sign of the input based on the chosen sign of the VCO gain (sign of the reference frequency)
assign inst_frequency0_to_pll1 = reference_frequency1[47] ? (-inst_frequency0) : inst_frequency0;
assign pll0_output_to_pll1 = reference_frequency1[47] ? (-pll0_output >> 6) : (pll0_output >> 6); // pll0_output is 16 bits and in2_mux is 10 bits. Keep MSBs

multiplexer_3to1_async loop_filters_1_mux (
 .clk                               (clk1                       ),
 .selector_mux                      (loop_filter_1_mux_selector ),
 .in0_mux                           (DDC1_freq_output           ), 
 .in1_mux                           (inst_frequency0_to_pll1    ),
 .in2_mux                           (pll0_output_to_pll1        ),
 .out_mux                           (inst_frequency1            )
);

//-----------------------------------------------------------------------------
// Channel 1 Loop Filter:
//

// This is used for bumpless change of the gain settings (TODO, most probably in the output summing block)
assign pll1_gain_changed = pll1_gain_changedp | pll1_gain_changedi | pll1_gain_changedii | pll1_coef_changedd;

// Finally PLL 1 itself:
PLL_loop_filters_with_saturation # (
    .N_DIVIDE_P(10),
    .N_DIVIDE_I(27),
    .N_DIVIDE_II(36),
    .N_DIVIDE_D(11),
    .N_OUTPUT(16)
) PLL1_loop_filters (
    .clk(clk1), 
    .lock(pll1_lock), 
    .gain_changed(pll1_gain_changed), 
    .data_in(inst_frequency1),
    .gain_p(pll1_gainp), 
    .gain_i(pll1_gaini), 
    .gain_ii(pll1_gainii),
    .gain_d(pll1_gaind),
    .coef_d_filter(pll1_coefdfilter),
    .phase_residuals(phase_residuals1),
    .data_out(pll1_output),
    .saturated_low(),
    .saturated_high()
);


///////////////////////////////////////////////////////////////////////////////
// Dither Generator and Lock-In: 
///////////////////////////////////////////////////////////////////////////////
// Serves to measure the DC gain and sign of the loop
// Register Addresses:
//      BASE_ADDRESS+0 - Enable register
//      BASE_ADDRESS+1 - Period register
//      BASE_ADDRESS+2 - N_periods register (~integration time)
//      BASE_ADDRESS+3 - Amplitude register
//

wire signed [16-1:0]        dither_output_to_dac0, dither_output_to_dac1;
wire signed [20-1:0]        dither_output_to_dac2;
wire signed [(16*3)-1:0]    dither0_lockin_output_to_wires, dither1_lockin_output_to_wires, dither2_lockin_output_to_wires;
wire    dither0_lockin_output_clk_enable, dither1_lockin_output_clk_enable, dither2_lockin_output_clk_enable;

//-----------------------------------------------------------------------------
// Channel 0 Dither & Lock-In:
// Include h8100, h8101, h8102, h8103
//

dither_lockin_wrapper # (
    .BASE_ADDRESS(16'h8100),
    .CMD_BUS_BITS(16),
    .N_BITS_INPUT(10),
    .N_BITS_OUTPUT(16),
    .COUNTER_BITS(27),              // 27 bits gives ~ 134 Millions clock cycles, or 1.07 seconds at 125 MHz clock rate
    .SYNC_DELAY(60),                    // should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
    .INTEGRATORS_BITS(16*3) // should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
            // but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
            // initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
            // so we'll go for 3 Wires, or a total of 48 bits for each integrator.
) dither_lockin_wrapper0 (
    .clk                 (  clk1  ),
    .data_input          (  inst_frequency0  ),

    .cmd_trig            (  cmd_trig  ),
    .cmd_addr            (  cmd_addr  ),
    .cmd_data1           (  cmd_data1in  ),
    .cmd_data2           (  cmd_data2in  ),

    .output_to_dac       (  dither_output_to_dac0  ),
    .results_output_I    (  dither0_lockin_output_to_wires  ),
    .results_output_Q    (                                  ),
    .output_clk_enable   (  dither0_lockin_output_clk_enable  )
);

//-----------------------------------------------------------------------------
// Channel 1 Dither & Lock-In:
// Include h8100, h8201, h8202, h8203
//

dither_lockin_wrapper # (
    .BASE_ADDRESS(16'h8200),
    .CMD_BUS_BITS(16),
    .N_BITS_INPUT(10),
    .N_BITS_OUTPUT(16),
    .COUNTER_BITS(27),              // 27 bits gives ~ 134 Millions clock cycles, or 1.07 seconds at 125 MHz clock rate
    .SYNC_DELAY(60),                    // should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
    .INTEGRATORS_BITS(16*3) // should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
            // but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
            // initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
            // so we'll go for 3 Wires, or a total of 48 bits for each integrator.
) dither_lockin_wrapper1 (
    .clk                 (  clk1  ),
    .data_input          (  inst_frequency1  ),

    .cmd_trig            (  cmd_trig  ),
    .cmd_addr            (  cmd_addr  ),
    .cmd_data1           (  cmd_data1in  ),
    .cmd_data2           (  cmd_data2in  ),

    .output_to_dac       (  dither_output_to_dac1  ),
    .results_output_I    (  dither1_lockin_output_to_wires  ),
    .results_output_Q    (                                  ),
    .output_clk_enable   (  dither1_lockin_output_clk_enable  )
);


///////////////////////////////////////////////////////////////////////////////
// Vector Network Analyzer (VNA):
///////////////////////////////////////////////////////////////////////////////
// Performs transfer function measurements
// Also includes its own input and output multiplexers
// Write Addresses:
//      h5000 - number_of_cycles_integration
//      h5001 - first_modulation_frequency[32-1:0], LSBs
//      h5002 - first_modulation_frequency[48-1:32], MSBs
//      h5003 - modulation_frequency_step[32-1:0], LSBs
//      h5004 - modulation_frequency_step[48-1:0], MSBs
//      h5005 - number_of_frequencies
//      h5006 - output_gain
//      h5007 - input_and_output_mux_selector
//      h5008 - mode control signals (stop, trigger_dither, bSquareWave)
//

wire signed [16-1:0] vna_output_to_dac0, vna_output_to_dac1, vna_output_to_dac2;
wire signed [16-1:0] VNA_output_to_logger;
wire VNA_output_to_logger_clk_enable;

wire trigger_vna_identification; // Trigger Vector Network Analyzer (VNA)

// VNA Identification Trigger
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(8),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h0042)
) parallel_bus_register_trigger_identification (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(), 
    .update_flag(trigger_vna_identification)
);


system_identification_vna_with_dither_wrapper system_identification_vna_inst (
    .rst(rst_frontend0), 
    .clk(clk1), 
    .cmd_addr(cmd_addr),
    .cmd_data1(cmd_data1in), 
    .cmd_data2(cmd_data2in), 
    .cmd_trig(cmd_trig), 

    // -- A rising edge here triggers the identification process
    .trigger_identification(trigger_vna_identification), 

    // -- Data inputs from the output of the systems to be identified
    .data_in1(ADCraw0),
    .data_in2(ADCraw1), 
    .data_in3({{6{inst_frequency0[9]}}, inst_frequency0}),  // the output of the DDC, sign-extended to 16 bits
    .data_in4({{6{inst_frequency1[9]}}, inst_frequency1}),

    // -- Modulation outputs to dacs
    .modulation_output_to_dac0(vna_output_to_dac0), 
    .modulation_output_to_dac1(vna_output_to_dac1), 
    .modulation_output_to_dac2(vna_output_to_dac2),

    // -- Output port which goes to the data logger which contains the identification results
    .output_to_logger(VNA_output_to_logger), 
    .output_to_logger_clk_enable(VNA_output_to_logger_clk_enable)
);
     

///////////////////////////////////////////////////////////////////////////////
// Primary DAC Outputs:
///////////////////////////////////////////////////////////////////////////////
// Output combiners before sending the results to the DACs.
// Limits output to user specified range.
//

wire signed [16-1:0] manual_offset_dac0, positive_limit_dac0, negative_limit_dac0;
wire dac0_railed_negative, dac0_railed_positive;

wire signed [16-1:0] manual_offset_dac1, positive_limit_dac1, negative_limit_dac1;
wire dac1_railed_negative, dac1_railed_positive;

//-----------------------------------------------------------------------------
// DAC Output Summation Input Registers:
//

// Channel 0 Manual Offset Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h6000)
) parallel_bus_register_manual_offset_dac0 (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(manual_offset_dac0), 
    .update_flag()
);

// Channel 1 Manual Offset Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(0),
    .ADDRESS(16'h6001)
) parallel_bus_register_manual_offset_dac1 (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(manual_offset_dac1), 
    .update_flag()
);

// Channel 0 Output Limits Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE({16'd32767, 16'd0}),
    .ADDRESS(16'h6101)
) parallel_bus_register_dac0_limits (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({positive_limit_dac0, negative_limit_dac0}), 
    .update_flag()
);

// Channel 1 Output Limits Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE({16'd32767, 16'd0}),
    .ADDRESS(16'h6102)
) parallel_bus_register_dac1_limits (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output({positive_limit_dac1, negative_limit_dac1}), 
    .update_flag()
);

//-----------------------------------------------------------------------------
// Channel 0 DAC Output Sum:
//

output_summing # (
    .INPUT_SIZE       (16),
    .OUTPUT_SIZE      (16)
) output_summing_dac0 (
    .clk              (  clk1                       ), 
    .in0              (  dither_output_to_dac0      ), 
    .in1              (  vna_output_to_dac0         ), 
    .in2              (  pll0_output                ), 
    .in3              (  manual_offset_dac0         ), 
    .data_output      (  DACout0                    ), 
    .positive_limit   (  positive_limit_dac0        ),
    .negative_limit   (  negative_limit_dac0        ),
    .railed_positive  (  dac0_railed_positive       ),
    .railed_negative  (  dac0_railed_negative       )
);


//-----------------------------------------------------------------------------
// Channel 1 DAC Output Sum:
//

output_summing # (
    .INPUT_SIZE       (16),
    .OUTPUT_SIZE      (16)
) output_summing_dac1 (  
    .clk              (  clk1                       ), 
    .in0              (  dither_output_to_dac1      ), 
    .in1              (  vna_output_to_dac1         ), 
    .in2              (  pll1_output                ), 
    .in3              (  manual_offset_dac1         ), 
    .data_output      (  DACout1                    ), 
    .positive_limit   (  positive_limit_dac1        ),
    .negative_limit   (  negative_limit_dac1        ),
    .railed_positive  (  dac1_railed_positive       ),
    .railed_negative  (  dac1_railed_negative       )
);


// ///////////////////////////////////////////////////////////////////////////////
// // Pulse Width Managed (PWM) DAC Output:
// ///////////////////////////////////////////////////////////////////////////////

// wire [8:0] pwm_level;

// parallel_bus_register_32bits_or_less # (
//     .REGISTER_SIZE(9),
//     .REGISTER_DEFAULT_VALUE(9'b00000000),
//     .ADDRESS(16'h6621)
// )
// parallel_bus_register_pwm_level (
//     .clk(clk1), 
//     .bus_strobe(cmd_trig), 
//     .bus_address(cmd_addr), 
//     .bus_data({cmd_data2in, cmd_data1in}), 
//     .register_output(pwm_level), 
//     .update_flag()
// );

// PWM_generator # (
//     .NUMBER_OF_BITS(8)
// )
// PWM_generator_inst (
//     .clk(clk1),
//     .level(pwm_level),
//     .dout(DOUT[0])
// );


///////////////////////////////////////////////////////////////////////////////
// Frequency Counters:
///////////////////////////////////////////////////////////////////////////////
// Counts the frequency with no dead-time using a short bandlimiting filter  + an integrate and dump.
// Dual Mode, select either triangular or rectangular averaging
// Output rate will be 1 Hz
// Results are sent to a FIFO which goes to an Opal Kelly PipeOut

wire triangular_mode;   // triangular_mode='1' means a triangular averaging of the frequency, triangular_mode='0' means rectangular averaging of the frequency

wire signed [64-1:0] counter0_out;
wire counter0_out_clk_enable, counter0_out_clk_enable_faster;

wire signed [64-1:0] counter1_out;
wire counter1_out_clk_enable;

//-----------------------------------------------------------------------------
// Frequency Counter Input Registers:
//

// Counter Mode Register (triangular or rectangular averaging)
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(1),
    .REGISTER_DEFAULT_VALUE(12'b1),
    .ADDRESS(16'h8501)
) parallel_bus_register_counter_mode (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(triangular_mode), 
    .update_flag()
);

//-----------------------------------------------------------------------------
// Channel 0 Counter:
//

dual_type_frequency_counter dual_type_frequency_counter_inst0 (
    .rst(rst_frontend0),
    .clk(clk1), 
    .data_input(inst_frequency0), 
    .N_gate_time(32'd125000000), 
    .N_times_faster_gate_time(32'd125000000), 
    .triangular_mode(triangular_mode), 
    .output_clk_enable_N_times_faster(counter0_out_clk_enable_faster), 
    .data_output(counter0_out), 
    .output_clk_enable(counter0_out_clk_enable)
);
  
//-----------------------------------------------------------------------------
// Channel 1 Counter:
//

dual_type_frequency_counter dual_type_frequency_counter_inst1 (
    .rst(rst_frontend0),    // the 0 here is not a typo: we want the two counters to stay synchronized even during a reset
    .clk(clk1), 
    .data_input(inst_frequency1), 
    .N_gate_time(32'd125000000), 
    .N_times_faster_gate_time(32'd125000000), 
    .triangular_mode(triangular_mode), 
    .output_clk_enable_N_times_faster(), 
    .data_output(counter1_out), 
    .output_clk_enable(counter1_out_clk_enable)
);


///////////////////////////////////////////////////////////////////////////////
// Data Logger Interface:
///////////////////////////////////////////////////////////////////////////////
// Selects the desired input for the Data Logger (formerly DDR2 logger)
//

wire    [16-1:0]         selector;

// counter connected to a free input on the multiplexer, helps for debugging
reg     [32-1:0]  debugging_counter;
always @(posedge clk1) debugging_counter <= debugging_counter + 1'b1;

//-----------------------------------------------------------------------------
// Data Logger Multiplexer Input Registers:
//

// Multiplexer Input Selection Register
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(16),
    .REGISTER_DEFAULT_VALUE(1'b0),
    .ADDRESS(16'h0003)
) parallel_bus_register_logger_mux_select (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(selector), 
    .update_flag()
);

//-----------------------------------------------------------------------------
// Data Logger Input Multiplexer:
//

multiplexer_NbitsxMsignals_to_Nbits # (
    .N_bits_per_signal(17)  // 16 bits per signal + clock enable in MSB : simply put a static 1'b1 if signal is always valid
) multiplexer_NbitsxMsignals_to_Nbits_inst (
    .clk(clk1), 
    .in0({1'b1, ADC0_multiplexed}), 
    .in1({1'b1, ADC1_multiplexed}), 
    .in2({1'b1, {6{inst_frequency0[10-1]}}, inst_frequency0}), // Inst freq after DDC 0, sign extended to 16 bits
    .in3({1'b1, {6{inst_frequency1[10-1]}}, inst_frequency1}), // Inst freq after DDC 1, sign extended to 16 bits
    .in4({VNA_output_to_logger_clk_enable, VNA_output_to_logger}), // VNA output
    .in5({1'b1, debugging_counter[16-1:0]}),  // counter, simply for debugging the DDR2 Logger/USB link
    .in6({1'b1, DACout0[SIGNAL_SIZE-1:SIGNAL_SIZE-16]}), 
    .in7({1'b1, DACout1[SIGNAL_SIZE-1:SIGNAL_SIZE-16]}), 
    .in8({1'b1, 16'b0}),
    //.in9({crash_monitor_output_to_logger_clk_enable, crash_monitor_output_to_logger}),
    .in9({1'b0, 8'b0}),
    .selector(selector[4:0]), 
    .selected_output({LoggerData_clk_enable, LoggerData})
);


///////////////////////////////////////////////////////////////////////////////
// Auxiliary Data Logger Multiplexer:
///////////////////////////////////////////////////////////////////////////////
// This one is more specialized, as it monitors the state of the DDR2 logger and adds auxilary data to the start of the data stream.
// It also adds a 16-bits magic word to help diagnose bus sync issues.
// Currently all we do is add one sample of the DDC reference tone near the start of the data packet when the ADC is selected.
//

// Collection of wires used to add auxilary data to the stream going to the Data logger.
wire signed [16-1:0]    ref_cosine_0, ref_sine_0, ref_cosine_1, ref_sine_1;
wire signed [16-1:0]    ADC0_multiplexed, ADC1_multiplexed;

aux_data_mux aux_data_mux_inst (
    .clk(clk1), 
    .write_mode(LoggerIsWriting), 
    .ADC0(ADCraw0), 
    .ADC1(ADCraw1), 
    .ref_cosine_0(ref_cosine_0), 
    .ref_sine_0(ref_sine_0), 
    .ref_cosine_1(ref_cosine_1), 
    .ref_sine_1(ref_sine_1), 
    .ADC0_multiplexed(ADC0_multiplexed), 
    .ADC1_multiplexed(ADC1_multiplexed)
);


///////////////////////////////////////////////////////////////////////////////
// Residuals Monitor:
///////////////////////////////////////////////////////////////////////////////
// This module outputs high if the abs value of the phase residuals is above a certain threshold.
// The output of this module triggers the crash monitor
//

wire signed [32-1:0] phase_residuals0_threshold;
wire [10-1:0] freq_residuals0_threshold;
wire residuals0_are_above_threshold_phase, residuals0_are_above_threshold_freq;
reg residuals0_are_above_threshold;

wire signed [32-1:0] phase_residuals1_threshold;
wire residuals1_are_above_threshold;

//-----------------------------------------------------------------------------
// Residuals Monitor Input Registers:
//

// sets the phase residuals threshold for DAC0:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8400)
) parallel_bus_register_phase_residuals0_threshold (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(phase_residuals0_threshold), 
    .update_flag()
);

// sets the phase residuals threshold for DAC1:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(32),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8401)
) parallel_bus_register_phase_residuals1_threshold (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(phase_residuals1_threshold), 
    .update_flag()
);

// sets the frequency residuals threshold for DAC0:
parallel_bus_register_32bits_or_less # (
    .REGISTER_SIZE(10),
    .REGISTER_DEFAULT_VALUE(32'b0),
    .ADDRESS(16'h8410)
) parallel_bus_register_freq_residuals0_threshold (
    .clk(clk1), 
    .bus_strobe(cmd_trig), 
    .bus_address(cmd_addr), 
    .bus_data({cmd_data2in, cmd_data1in}), 
    .register_output(freq_residuals0_threshold), 
    .update_flag()
);

//-----------------------------------------------------------------------------
// Residuals Monitor Channel 0:
//

// Channel 0 Phase Residuals
residuals_monitor # (
    .N_BITS_DATA(32)
) residuals_monitor_inst0 (
    .clk(clk1), 
    .phase_residuals(phase_residuals0), 
    .residuals_threshold(phase_residuals0_threshold), 
    .residuals_are_above_threshold(residuals0_are_above_threshold_phase)
);

// Channel 0 Frequency Residuals
residuals_monitor # (
    .N_BITS_DATA(10)
) residuals_monitor_inst0_freq (
    .clk(clk1), 
    .phase_residuals(inst_frequency0), 
    .residuals_threshold(freq_residuals0_threshold), 
    .residuals_are_above_threshold(residuals0_are_above_threshold_freq)
);
 
// The two trigger conditions are ORed together:
always @(posedge clk1) residuals0_are_above_threshold <= residuals0_are_above_threshold_phase | residuals0_are_above_threshold_freq;
     
//-----------------------------------------------------------------------------
// Residuals Monitor Channel 1:
//

// Channel 1 Phase Residuals
residuals_monitor # (
    .N_BITS_DATA(32)
) residuals_monitor_inst1 (
    .clk(clk1), 
    .phase_residuals(phase_residuals1), 
    .residuals_threshold(phase_residuals1_threshold), 
    .residuals_are_above_threshold(residuals1_are_above_threshold)
);


///////////////////////////////////////////////////////////////////////////////
// LEDs:
///////////////////////////////////////////////////////////////////////////////
// The module which drives the front panel LEDs:
// These LEDs don't map directly to LEDs on the RedPitaya, but they still show up in the Python PC GUI so we left them there.
// They could eventually be mapped to some of the LEDs on the RP, although we don't have the nice Reg/Green LEDS anymore (only orange).
//

wire  LED_G0, LED_G1;
wire  LED_R0, LED_R1;

assign LED_G0 = 1'b1;

// DAC 0 Railed LED
Status_LED_driver # (
    .N_BITS_COUNTER(23) // 125 MHz/2**23 = 14.9 Hz
) Status_LED_driver0 (
    .clk(clk1), 
    .lock_on(pll0_lock), 
    .residuals_above_threshold(residuals0_are_above_threshold), 
    .railed((dac0_railed_negative | dac0_railed_positive)), 
    .red_LED(LED_R0), 
    .green_LED() // LED_G0
);

// DAC 1 Railed LED
Status_LED_driver # (
    .N_BITS_COUNTER(23) // 125 MHz/2**23 = 14.9 Hz
) Status_LED_driver1 (
    .clk(clk1), 
    .lock_on(pll1_lock), 
    .residuals_above_threshold(residuals1_are_above_threshold), 
    .railed((dac1_railed_negative | dac1_railed_positive)), 
    .red_LED(LED_R1), 
    .green_LED(LED_G1)
);


///////////////////////////////////////////////////////////////////////////////
// Legacy "Opal Kelly" Interface
///////////////////////////////////////////////////////////////////////////////
// Legacy interface used to read out data from the DPPL module
// Read Addresses:
//      h0025 - status_flags
//      h0026 - dither0_lockin_output[32-1: 0], LSBs (writes MSBs to register)
//          h0027 - dither0_lockin_output_reg[64-1:32], MSBs
//      h0029 - dither1_lockin_output[32-1:0], LSBs (writes MSBs to register)
//          h002A - dither1_lockin_output_reg[64-1:32], MSBs
//      h0030 - zdtc_samples_number_counter (synchronously writes counter0_out, counter1_out, DAC0_out, DAC1_out to registers)
//          h0031 - counter0_out_reg[32-1:0], LSBs
//          h0032 - counter0_out_reg[64-1:32], MSBs
//          h0033 - counter1_out_reg[32-1:0], LSBs
//          h0034 - counter1_out_reg[64-1:32], MSBs
//          h0035 - DAC0_out_reg
//          h0036 - DAC1_out_reg
//      h0038 - fifo_prog_empty (<10 words left)
//      h0039 - fifo_dout
//      h0040 - fifo_data_count_max
// Write Addresses:
//      h0041 - bWritesEnabled (write counter for I/O test)
//      h0042 - fifo_srst (reset fifio)
//

reg [32-1:0]    zdtc_samples_number_counter;
wire [32-1:0]   status_flags = 32'b0;
// two legacy flags that made sense when the counters were sent to a fifo... should be removed eventually
wire            counter0_fifo_has_too_little_samples;   // Frequency counter 0 (1 Hz writes)
wire            counter1_fifo_has_too_little_samples;   // Frequency counter 1 (1 Hz writes)

// Increment ZDTC Counter
always @(posedge clk1) begin
    zdtc_samples_number_counter <= (counter0_out_clk_enable_faster == 1'b1 ? zdtc_samples_number_counter + 1'b1 : zdtc_samples_number_counter);
end

// Status Flags
assign status_flags[0]  = counter0_fifo_has_too_little_samples;
assign status_flags[1]  = counter1_fifo_has_too_little_samples;
assign status_flags[2]  = 1'b0; // PipeOutA1Empty;
assign status_flags[3]  = 1'b0; // crash_monitor_has_data;
assign status_flags[4]  = LED_G0;
assign status_flags[5]  = LED_R0;
assign status_flags[6]  = LED_G1;
assign status_flags[7]  = LED_R1;
assign status_flags[8]  = 1'b0; // LED_G[2]
assign status_flags[9]  = 1'b0; // LED_R[2]
assign status_flags[10] = 1'b0; // residuals_ceo_fifo_has_too_little_samples;
assign status_flags[11] = 1'b0; // residuals_optical_fifo_has_too_little_samples;

//-----------------------------------------------------------------------------
// Read "Opal Kelly" Registers:
// This module implements all of the register/status readout to the Zynq
//

registers_read registers_read_inst (
    .clk(clk1),
    // Registers inputs (to be read)
    .status_flags(status_flags),
    // these get sampled internally together even though they go through multiple reads by the CPU
    .dither0_lockin_output({  {16{dither0_lockin_output_to_wires[47]}} , dither0_lockin_output_to_wires}),  // manual sign extension from 48 to 64 bits
    // these get sampled internally together even though they go through multiple reads by the CPU
    .dither1_lockin_output({  {16{dither1_lockin_output_to_wires[47]}} , dither1_lockin_output_to_wires}),  // manual sign extension from 48 to 64 bits
    // these get sampled internally together even though they go through multiple reads by the CPU
    .zdtc_samples_number_counter(zdtc_samples_number_counter),
    .counter0_out(counter0_out),
    .counter1_out(counter1_out),
    .DAC0_out({  {16{DACout0[15]}} , DACout0}),   // manual sign extension from 16 to 32 bits
    .DAC1_out({  {16{DACout1[15]}} , DACout1}),

    // internal configuration bus
    .cmd_addr        (  cmd_addr                       ),  // address, note the divide by 4 again to map between zynq addresses and the legacy DPLL addresses
    .sys_wdata       (  sys_wdata                      ),  // write data
    .sys_sel         (  sys_sel                        ),  // write byte select
    .sys_wen         (  sys_wen                        ),  // write enable
    .sys_ren         (  sys_ren                        ),  // read enable
    .sys_rdata       (  sys_rdata                      ),  // read data
    .sys_err         (  sys_err                        ),  // error indicator
    .sys_ack         (  sys_ack                        )   // acknowledge signal
);



endmodule
