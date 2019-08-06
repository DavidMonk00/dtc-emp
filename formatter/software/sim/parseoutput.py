import re
import numpy as np


class ldata:
    def __init__(self, string):
        data = string.split(" ")
        self.data = int(data[0][4:], 16)
        self.valid = bool(data[1])
        self.start = bool(data[2])
        self.strobe = bool(data[3])

    def __getitem___(self, index):
        return self.data[index]


def parse(string):
    data = []
    i = 0
    start, end, depth = 0, 0, 0
    while (i < len(string)):
        if (string[i] == '{'):
            if (depth == 0):
                start = i
            depth += 1
        elif (string[i] == '}'):
            depth -= 1
            if (depth == 0):
                end = i
                data.append(string[start+1:end])
        i += 1
    if len(data) == 0:
        return ldata(string)
    else:
        for i in range(len(data)):
            data[i] = parse(data[i])
    return data


class Signal:
    def __init__(self, path):
        self.path = path
        self.data = []

    def append(self, string):
        self.data = [i for i in self.data if i]
        if string[0] == '{':
            self.data.append([])
            string = string[1:-1]
            data = string.split(" ")
            for entry in data:
                reg = re.search("(?<=\').*", entry)
                if (reg):
                    if (reg.group()[0] == 'h'):
                        try:
                            self.data[-1].append(int(reg.group()[1:], 16))
                        except ValueError:
                            self.data[-1].append(0)
        else:
            reg = re.search("(?<=\').*", string)
            if (reg):
                if (reg.group()[0] == 'h'):
                    try:
                        self.data.append(int(reg.group()[1:], 16))
                    except ValueError:
                        self.data.append(0)
            else:
                try:
                    self.data.append(int(string))
                except ValueError:
                    self.data.append(0)

    def size(self):
        return np.array(self.data).shape


def parseEventFile(file):
    signals = [
        Signal("/testbench/links_in\(0\)"),
        Signal("/testbench/links_out\(0\)"),
        Signal("/testbench/links_out\(1\)")
    ]
    lines = [line.strip() for line in open(file)]
    for line in lines:
        for signal in signals:
            reg = re.search("(?<=%s\ ).*" % signal.path, line)
            if (reg):
                print(reg.group())
                signal.append(reg.group())

    for signal in signals:
        print(signal.size())


def parseListFile(file):
    lines = [line.strip() for line in open(file)]
    f = open("output.txt", "w")
    f.write("header,data\n")
    for i in range(2, len(lines)):
        lines[i] = parse(lines[i])
        f.write("%d,%d\n" % (lines[i][1][3].data, lines[i][1][2].data))
        f.write("%d,%d\n" % (lines[i][1][1].data, lines[i][1][0].data))
    f.close()


def main():
    parseListFile("list2.lst")


if __name__ == '__main__':
    main()
