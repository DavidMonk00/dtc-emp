#!/usr/bin/env bash

echo "Compiling library..."
mkdir -p modelsim_lib

bin_path="/opt/MentorGraphics/modeltech/bin"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep source Testbench_compile.do 2>&1 | tee compile.log

echo "Checking for errors..."
python checkerrors.py compile.log

echo "Running ModelSim..."
cp ../data/* ./
ExecStep $bin_path/vsim $1 -64  -do "do {Testbench_simulate.do}" -l simulate.log
python parseoutput.py
