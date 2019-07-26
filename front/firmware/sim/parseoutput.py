import re
import numpy as np


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


def main():
    signals = [Signal("/testbench/links_in"), Signal("/testbench/links_out")]
    lines = [line.strip() for line in open("event.lst")]
    for line in lines:
        # reg = re.search("\@[0-9]* ", line)
        # if (reg):
        #     print(line)
        for signal in signals:
            reg = re.search("(?<=%s\ ).*" % signal.path, line)
            if (reg):
                signal.append(reg.group())

    for signal in signals:
        print(signal.size())


if __name__ == '__main__':
    main()
