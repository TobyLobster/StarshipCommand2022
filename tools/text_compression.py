import argparse
import re

token_limit = 160           # 32 tokens (byte values 128-159)

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
        length_in_bytes = 1 + ((len(self.bitarray) + 7)//8)
        if length_in_bytes > 255:
            print("ERROR: String too long (" + str(length_in_bytes) + ")")
            exit(1)
        result.append(length_in_bytes)

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

def detokenise_entry(key, everyone, mains, tokens):
    result = []
    token_keys = list(tokens.keys())

    for b in everyone[key]:
        if b >= 128:
            result.extend(detokenise_entry(token_keys[b-128], everyone, mains, tokens))
        else:
            result.append(b)

    return result

def detokenise(byte_dict):
    mains = {}
    tokens = {}

    found_token_start = False
    for entry in byte_dict:
        if entry == "award_you_the_order_of_the":
            found_token_start = True
        if found_token_start:
            tokens[entry] = byte_dict[entry]
        else:
            mains[entry] = byte_dict[entry]

    result_dict = {}
    for entry in mains:
        result = detokenise_entry(entry, byte_dict, mains, tokens)
        result_dict[entry] = result
    return result_dict



def find_subsequence(start_index, full_list, sub_list):
    sub_length = len(sub_list)
    for idx in range(start_index, len(full_list) - sub_length + 1):
        if tuple(full_list[idx : idx + sub_length]) == sub_list:
            return idx
    return -1

def calculate_saving(byte_dict, sub_list):
    # count instances of the sub_list
    saving = (0, sub_list)
    for entry in byte_dict:
        list_index = find_subsequence(list_index, val, saving[1])
        if list_index >= 0:
            list_index += len(saving[1])
# TODO:
#            saving +=
#    return saving

def add_run(instances_dict, entry_index, start, byte_list):
    # We add the (entry_index, start) instance as an entry to the dictionary
    # We make the dictionary key a tuple because tuples are hashable
    key = tuple(byte_list)

    # if the key doesn't yet exist in the dictionary, then add an empty list
    if not key in instances_dict:
        instances_dict[key] = []

    # Add the instance to the list of instances within the dictionary
    instances_dict[key].append((entry_index, start))


def stringify(byte_list):
    result=""
    mode=""
    for b in byte_list:
        if (b >=32) and (b<127):
            if mode == "int":
                result += ","
            if mode!="char":
                result += "\'"
            result += chr(b)
            mode = "char"
        else:
            if mode == "char":
                result += "\'"
            if mode != "":
                result += ","
            result += str(b)
            mode="int"
    if mode=="char":
        result += "\'"
    return result

def find_best_saving(byte_dict):
    # We find all instances of repeated pairs of bytes from the byte_dict.
    # Then we use that to find all repeated triples, etc.
    #
    # instances_of_length[2] are all the instances of pairs used more than once,
    # instances_of_length[3] are all the instances of triples used more than once, etc.
    #
    # Each entry of instances_of_length is a dictionary keyed by a pair of bytes from the
    # byte_dict, whose value is a list of the instances of that run in the byte_dict.
    # Each instance is a tuple (entry, start)
    instances_of_length = []
    instances_of_length.append({})
    instances_of_length.append({})
    instances_of_length.append({})

    # Gather all instances of each pair of bytes
    best_saving = (0, "")
    substrings = []
    entry_index = 0
    for entry_key in byte_dict:
        entry = byte_dict[entry_key]
        len_entry = len(entry)
        for start_index in range(0, len_entry - 1):
            add_run(instances_of_length[2], entry_index, start_index, entry[start_index : start_index+2])
        entry_index += 1

    # Remove those only used once
    delete = [key for key in instances_of_length[2] if len(instances_of_length[2][key]) == 1]
    for key in delete:
        del instances_of_length[2][key]

    # Each of these pairs may be the start of a longer repeated instance
    max_length = 0
    for i in instances_of_length:
        result = len(i)
        if result > max_length:
            max_length = result

    # Now get all instances of length 3, based on the repeated instances of length 2
    # then get all instances of length 4, based on the repeated instances of length 3
    # etc until we are done
    ordered_keys = list(byte_dict.keys())
    best_saving   = 0
    best_byte_list = None
    for n in range(3, max_length):
        # Create all n-tuple instances, based on the (n-1)-tuple instances
        instances_of_length.append({})
        for byte_list in instances_of_length[n-1]:
            for instance in instances_of_length[n-1][byte_list]:
                entry_index = instance[0]
                start_index = instance[1]
                entry = byte_dict[ordered_keys[entry_index]]
                if len(entry) >= (start_index+n):
                    add_run(instances_of_length[n], entry_index, start_index, entry[start_index : start_index+n])

        # Remove all instances that are only used once
        delete = [key for key in instances_of_length[n] if len(instances_of_length[n][key]) == 1]
        for key in delete:
            del instances_of_length[n][key]

        for byte_list in instances_of_length[n]:
            # TODO: Really we should only be counting non-overlapping instances
            num_instances =len(instances_of_length[n][byte_list])
            old_cost = num_instances * n
            new_cost = n+1 + num_instances

            saving = old_cost - new_cost
            if saving >= best_saving:
                best_saving = saving
                best_byte_list = byte_list

    return (best_saving, best_byte_list)

def tokenise(byte_dict, saving):
    global next_token
    additional_dict = {}
    found_sequence = False
    for entry in byte_dict:
        finding_sequence = True
        while(finding_sequence):
            val = byte_dict[entry]
            list_index = find_subsequence(0, val, saving[1])
            if list_index >= 0:
                # Replace substring with token
                new_val = val[0:list_index] + [next_token] + val[list_index + len(saving[1]):]
                byte_dict[entry] = new_val
                additional_dict["token" + str(next_token)] = list(saving[1])
                found_sequence = True
            else:
                finding_sequence = False
    assert(found_sequence)

    byte_dict.update(additional_dict)
    next_token += 1
    return

def retokenise(byte_dict):
    getting_better = True
    global next_token
    next_token = 128
    while getting_better and (next_token < token_limit):
        saving = find_best_saving(byte_dict)
        getting_better = saving[0] > 0
        if getting_better:
#            print("Saving", saving[0], "bytes by tokenising", stringify(saving[1]))
            tokenise(byte_dict, saving)
#            output_dict(byte_dict, "sc_text_out_tokenised.txt")

def output_dict(byte_dict, output_filename):
    with open(output_filename, 'w') as f:
        for entry in byte_dict:
            f.write(entry + "\n")
            f.write("    !text ")

            in_string = False
            for b in byte_dict[entry]:
                if (b < 32) or (b >= 127):
                    if in_string:
                        in_string = False
                        f.write('",')
                    f.write(str(b) + ",")
                else:
                    if not in_string:
                        f.write('"')
                        in_string = True
                    if chr(b) == '"':
                        f.write('\\')
                    f.write(chr(b))

            if in_string:
                f.write('"')
            f.write("\n")



def compress(byte_dict):
    global conc
    global commonest_entries

    # get concordance of bytes
    for entry in byte_dict:
        for b in byte_dict[entry]:
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

    for entry in byte_dict:
        compressed_data[entry] = compress_string(byte_dict[entry])

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
                assert (entry < token_limit)
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
byte_dict = {}
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
                byte_dict[label] = string_bytes
            label = line
            string_bytes = []

if label:
    byte_dict[label] = string_bytes

#byte_dict = detokenise(byte_dict)
#output_dict(byte_dict, "sc_text_out.txt")
retokenise(byte_dict)
#output_dict(byte_dict, "sc_text_out.txt")

compress(byte_dict)

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

