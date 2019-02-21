vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/work

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap work questa_lib/msim/work

vlog -work xil_defaultlib -64 -sv "+incdir+../../../ipstatic" \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work work -64 "+incdir+../../../ipstatic" \
"../../../../redpitaya.srcs/sources_1/ip/clk_10MHz_sync/clk_10MHz_sync_clk_wiz.v" \
"../../../../redpitaya.srcs/sources_1/ip/clk_10MHz_sync/clk_10MHz_sync.v" \

vlog -work work \
"glbl.v"

