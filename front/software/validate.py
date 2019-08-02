import pandas as pd

cpp = pd.read_csv("c++/output.txt")
vhdl = pd.read_csv("sim/output.txt")

for i in (cpp.data - vhdl.data).values:
    try:
        print(bin(int(i)))
    except ValueError:
        print(bin(0))
