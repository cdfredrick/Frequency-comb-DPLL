onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib work clk_10MHz_sync_opt

do {wave.do}

view wave
view structure
view signals

do {clk_10MHz_sync.udo}

run -all

quit -force
