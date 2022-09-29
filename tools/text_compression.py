import argparse
import re

compressed_data = {}
encoding = {}
conc = {}
commonest_entries = {}

class BitStream:
    bitarray = []

    def clear(self):
        self.bitarray = []

    def append(self, bits, value):
        bit = 1 << (bits-1)
        for i in range(0, bits):
            self.bitarray.append((value & bit) != 0)
            bit >>= 1

    def pad_with(self, bits, value, bits2, value2):
        assert(bits+bits2 >= 7)
        if len(self.bitarray) % 8 == 0:
            return
        bytes_so_far = (len(self.bitarray)+7)//8
        self.append(bits, value)
        if bytes_so_far == (len(self.bitarray)+7)//8:
            # first padding was insufficient
            self.append(bits2, value2)

        self.bitarray = self.bitarray[:bytes_so_far*8]

    def get_byte_list(self):
        result = []
        # how many bytes follow?
        result.append(1 + ((len(self.bitarray) + 7)//8))

        offset_in_byte = 0
        next_byte = 0
        for b in self.bitarray:
            if b:
                next_byte |= 1 << offset_in_byte
            offset_in_byte += 1

            # if we have filled a byte's worth of data, add it to the result
            # then prepare to start the next byte
            if (offset_in_byte == 8):
                result.append(next_byte)
                next_byte = 0
                offset_in_byte = 0

        # finish off last byte
        if (offset_in_byte != 0):
            result.append(next_byte)

        return result

def parse_hex_byte(line):
    match = re.search(r'[0-9a-fA-F]+', line)
    if match:
        value = int("0x" + match.group(), 16)
        line = line[match.span()[1]:]
        return(value, line)

    print("Failed" + line)
    return (0, None)

def parse_decimal_byte(line):
    match = re.search(r'[0-9]+', line)
    if match:
        value = int(match.group())
        line = line[match.span()[1]:]
        return(value, line)

    print("Failed: " + line)
    return (0, None)

def parse_byte(line, result):
    if (line[0] == '$'):
        (value, line) = parse_hex_byte(line[1:])
    else:
        (value, line) = parse_decimal_byte(line)

    result.append(value)
    return(line)

def parse_string(line, result):
    isInString = False
    inEscapeSequence = False
    done = False

    while not done:
        # deal with escape sequences first
        if (inEscapeSequence):
            result.append(ord(line[0]))
            line = line[1:]
            inEscapeSequence = False
            continue

        # regular character (not in an escape sequence)
        if line[0] == '\"':
            line = line[1:]
            isInString = not isInString
        elif line[0] == '\\':
            inEscapeSequence = True
            line = line[1:]
            continue
        else:
            if isInString:
                result.append(ord(line[0]))
            line = line[1:]

        done = not isInString
    #print (''.join(map(chr,result)))
    return(line)

def parse_bytes(rawline, count):
    line = rawline.strip()
    result = []
    while line and (len(line) > 0):
        if (line[0] == '\"'):
            line = parse_string(line, result)
        else:
            line = parse_byte(line, result)
        line = line.lstrip().lstrip(",").lstrip()

    if line==None:
        print("Error parsing at line " + str(count) + "\n" + rawline);
        exit(-1)

    # skip any spaces and comma from the start of the string
    return (result, line)

def compress(string_dict):
    global conc
    global commonest_entries

    # get concordance of bytes
    for entry in string_dict:
        for b in string_dict[entry]:
            if b < 128: # skip tokens
                if not (b in conc):
                    conc[b] = 1
                else:
                    conc[b] += 1

    conc = dict(sorted(conc.items(), key= lambda x:-x[1]))

    commonest_entries = dict(list(conc.items())[0: 29])
    #print("Commonest characters:", list(commonest_entries.keys()))

    depth = 0
    counter = 0
    for entry in commonest_entries:
#        encoding[entry] = [30 for i in range(depth)]
        encoding[entry] = (counter % 31)
        counter += 1
        if (counter % 32) == 0:
            depth += 1

    for entry in string_dict:
        compressed_data[entry] = compress_string(string_dict[entry])

def compress_string(string):
    global commonest_entries

    result = BitStream()
    result.clear()
    common_list = list(commonest_entries.keys())
    for entry in string:
        if entry in commonest_entries:
            assert (entry < 128)
            result.append(5, common_list.index(entry))
        else:
            if entry >= 128:
                assert (entry < 160)
                result.append(5, 31)
                result.append(5, entry & 31)
            elif entry < 32:
                result.append(5, 30)
                result.append(5, entry)
            else:
                result.append(5, 29)
                result.append(7, entry)

    result.pad_with(5,30, 7,0)
    return result

# Construct an argument parser
all_args = argparse.ArgumentParser()

# Add arguments to the parser
all_args.add_argument("--input",  required=True, help="acme-like input text")
all_args.add_argument("--output", required=True, help="compressed text as acme asm file")
args = vars(all_args.parse_args())

lines = []
label = ""
string_bytes = []
string_dict = {}
compressed_data = {}
encoding = {}
conc = {}
commonest_entries = {}

with open(args["input"]) as f:
    count = 0
    for line in f:
        count += 1
        line = line.split(';')[0].rstrip()
        if (len(line) == 0):
            continue
        if (line[0] == ' '):
            line = line.strip()
            if (len(line) == 0):
                continue
            if (line.startswith("!text ") or line.startswith("!byte ")):
                line = line[6:]
                (my_bytes,_) = parse_bytes(line, count)
                string_bytes.extend(my_bytes)
            else:
                print("error, can't understand line " + str(count) + "'" + line + "'")

        else:
            if label:
                string_dict[label] = string_bytes
            label = line
            string_bytes = []

if label:
    string_dict[label] = string_bytes

compress(string_dict)

with open(args["output"], 'w') as f:
    i = 0
    for entry in compressed_data:
        f.write(entry.ljust(40) + " = " + str(i) + "\n")
        i += 1
        f.write("")

    f.write("\ntext_header_data\n")
    for entry in encoding:
        f.write("    !byte " + str(entry).ljust(20) + "; ")
        if ((entry >= 32) and (entry < 127)):
            f.write("'" + chr(entry) + "'")
        else:
            f.write(str(entry).rjust(3))
        f.write(": " + str(conc[entry]).rjust(3) + ", " + str(encoding[entry]) + "\n")

    f.write("\ntext_data\n")
    for entry in compressed_data:
        f.write(";" + entry + "\n")

        data = compressed_data[entry].get_byte_list()
        for b in data:
            f.write("    !byte " + str(b) + "\n")

