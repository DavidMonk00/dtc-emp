######################################################################
#
# File name : Testbench_compile.do
# Created on: Thu Jul 25 13:59:19 BST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -64 -incr -work xil_defaultlib  \
"../../../../../proj/dtc-front/top/top.srcs/sources_1/ip/blk_mem_gen_2/blk_mem_gen_2_sim_netlist.v" \
"../../../../../proj/dtc-front/top/top.srcs/sources_1/ip/blk_mem_gen_3/blk_mem_gen_3_sim_netlist.v" \
"../../../../../proj/dtc-front/top/top.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v" \
"../../../../../proj/dtc-front/top/top.srcs/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_0_sim_netlist.v" \
"../../../../../proj/dtc-front/top/top.srcs/sources_1/ip/xdma_0/xdma_0_sim_netlist.v" \

vcom -64 -93 -work xil_defaultlib  \
"../../../../emp-fwk/components/framework/firmware/hdl/emp_framework_decl.vhd" \
"../../../../emp-fwk/boards/serenity/dc_ku15p/firmware/hdl/emp_device_decl.vhd" \
"../../../../emp-fwk/components/datapath/firmware/hdl/emp_data_types.vhd" \
"../../firmware/hdl/DataTypes.vhd" \

vcom -64 -93 -work xil_defaultlib  \
"../../firmware/hdl/utilities.vhd" \
"../../firmware/hdl/FunkyMiniBus.vhd" \
"../../firmware/hdl/GenPromClocked.vhd" \

vcom -64 -93 -work xil_defaultlib  \
"../../firmware/hdl/CICStubPipe.vhd" \
"../../firmware/hdl/StubPipe.vhd" \
"../../firmware/hdl/RouterInputReformatting.vhd" \
"../../firmware/hdl/GetCorrectionMatrix.vhd" \
"../../firmware/hdl/CoordinateCorrector2.vhd" \
"../../firmware/hdl/LinkFormatter.vhd" \
"../../firmware/hdl/StubFormatter.vhd" \
"../../firmware/hdl/algo.vhd" \
"../../firmware/hdl/LinkGenerator.vhd" \

vcom -64 -93 -work xil_defaultlib  \
"../../firmware/hdl/Testbench.vhd" \


# compile glbl module
#vlog -work xil_defaultlib "glbl.v"
