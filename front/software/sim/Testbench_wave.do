######################################################################
#
# File name : Testbench_wave.do
# Created on: Tue Jun 11 10:22:00 BST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
#if { [catch {[add wave *]}] } {}

### General Simulation ###
#add wave sim:/testbench/clk

### LinkFormatter ###
add wave sim:/testbench/AlgoInstance/CICStubPipe(0)(1)
add wave sim:/testbench/AlgoInstance/LinkFormatterInstance/StubArray
add wave -divider

### StubFormatter ###
add wave sim:/testbench/AlgoInstance/StubFormatterInstance/gStubFormatter(1)/address
add wave sim:/testbench/AlgoInstance/StubFormatterInstance/StubPipeIn(0)(1)
add wave sim:/testbench/AlgoInstance/StubFormatterInstance/gStubFormatter(1)/pos_lut_out
add wave sim:/testbench/AlgoInstance/StubFormatterInstance/gStubFormatter(1)/xy
add wave sim:/testbench/AlgoInstance/StubFormatterInstance/StubArray(1)
add wave -divider

### GetCorrectionMatrix ###
add wave sim:/testbench/AlgoInstance/GetCorrectionMatrixInstance/gGetCorrectionMatrix(1)/address
add wave sim:/testbench/AlgoInstance/GetCorrectionMatrixInstance/gGetCorrectionMatrix(1)/data
add wave sim:/testbench/AlgoInstance/GetCorrectionMatrixInstance/MatricesOut(1)
add wave -divider

### CoordinateCorrector ###
add wave sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeIn(0)(0)
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/MatricesIn(0)
add wave sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubArray(0)
add wave -divider
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeIn(0)(0).payload.r
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff.r_1
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff.r_2
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff_second.r_1
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector.r_1
add wave -divider
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeIn(0)(0).payload.z
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff.z
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff_second.z
add wave -radix decimal sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector.z
add wave -divider

#add wave sim:/testbench/AlgoInstance/FormattedStubPipe(0)(0)
#add wave sim:/testbench/AlgoInstance/CorrectedStubPipe(0)(0)
add wave -divider

### CoordinateCorrector ###
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeIn(0)(0).intrinsic
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/MatricesIn(0)
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector_buff.phi
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeIn(3)(0).payload.phi
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/gCoordinateCorrector(0)/vector.phi
#add wave -position insertpoint sim:/testbench/AlgoInstance/CoordinateCorrectorInstance/StubPipeOut(0)(0)
#add wave -divider
#add wave -radix decimal -position insertpoint sim:/testbench/AlgoInstance/StubFormatterInstance/gStubFormatter(0)/xy

#add wave -divider

add wave -position insertpoint sim:/testbench/links_in
add wave -position insertpoint sim:/testbench/links_out
