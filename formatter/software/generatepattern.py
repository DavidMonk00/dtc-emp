def main():
    pattern_file = open("input.txt", "w")
    source = [line.strip() for line in open("source.txt")]
    frames = 64
    header = 6
    pattern_file.write("Board Processor_1\n")
    pattern_file.write(" Quad/Chan :        q00c0              q00c1              q00c2              q00c3      \n")
    pattern_file.write("      Link :         00                 01                 02                 03        \n")
    for i in range(frames):
        line = "Frame %04d : " % i
        if (i < header):
            for j in range(4):
                line += "0v%016x " % 0
        else:
            line += "1v%s " % source[i]
            for j in range(3):
                line += "1v%016x " % 0
        pattern_file.write(line + "\n")
    pattern_file.close()


if __name__ == '__main__':
    main()
