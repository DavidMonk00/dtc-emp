from glob import glob
import re


class DepBuilder:
    def __init__(self, metadata={
        "paths": {
            "hdl": "../firmware/hdl/*",
            "data": "../firmware/data/*"
        },
        "prefix": {"data": "../data/"}
    }):
        self.files = []
        self.metadata = metadata
        self.getSources()

    def getFiles(self, path, prefix=""):
        sources = glob(path)
        files = []
        for source in sources:
            reg = re.search("[^\/]*$", source)
            if (reg):
                files.append(prefix + reg.group())
        self.files += files
        return files

    def getSources(self):
        for i in self.metadata["paths"]:
            if (i in self.metadata["prefix"]):
                self.getFiles(
                    self.metadata["paths"][i],
                    self.metadata["prefix"][i])
            else:
                self.getFiles(self.metadata["paths"][i])

    def build(self):
        print("Add this to dep file:")
        print()
        for source in self.files:
            print("src " + source)


def main():
    b = DepBuilder()
    b.build()


if __name__ == '__main__':
    main()
