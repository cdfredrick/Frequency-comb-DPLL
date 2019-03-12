create_generated_clock -name i_hk/dna_clk -source [get_pins adc_data_clk_pll_inst/inst/mmcm_adv_inst/CLKOUT0] -divide_by 8 [get_pins i_hk/dna_clk_reg/Q]
create_generated_clock -name dac_clk_o -source [get_pins ODDR_inst_oddr_dac_clk/C] -divide_by 1 [get_ports dac_clk_o]
create_generated_clock -name dac_sel_o -source [get_pins ODDR_inst_oddr_dac_sel/C] -divide_by 1 [get_ports dac_sel_o]
create_generated_clock -name dac_wrt_o -source [get_pins ODDR_inst_oddr_dac_wrt/C] -divide_by 1 [get_ports dac_wrt_o]
set_input_delay -clock [get_clocks adc_clk_p_i] -min -add_delay -0.100 [get_ports {adc_dat_a_i[*]}]
set_input_delay -clock [get_clocks adc_clk_p_i] -max -add_delay 0.700 [get_ports {adc_dat_a_i[*]}]
set_input_delay -clock [get_clocks adc_clk_p_i] -min -add_delay -0.100 [get_ports {adc_dat_b_i[*]}]
set_input_delay -clock [get_clocks adc_clk_p_i] -max -add_delay 0.700 [get_ports {adc_dat_b_i[*]}]




