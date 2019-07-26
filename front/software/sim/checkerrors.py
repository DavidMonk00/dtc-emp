import re
import sys


def main():
    print("--- Error Summary ---")
    err_no = 0
    filename = sys.argv[1]
    lines = [line.strip() for line in open(filename)]
    for line in lines:
        reg = re.search("(?<=Errors\: )[0-9]*", line)
        if (reg):
            print(line)
            err_no += int(reg.group())
    print("Total Errors: %d" % err_no)
    print("---------------------")


if __name__ == '__main__':
    main()
