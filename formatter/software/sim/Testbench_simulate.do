######################################################################
#
# File name : Testbench_simulate.do
# Created on: Mon Jun 24 11:38:30 BST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L xil_defaultlib -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.Testbench

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {Testbench_wave.do}

view wave
view structure
view signals

do {Testbench.udo}


add list  sim:/testbench/links_in
add list  sim:/testbench/links_out
run 2000ns
write list /home/dmonk/Firmware/dtc-fw/src/dtc-front/front/software/sim/list2.lst
quit
