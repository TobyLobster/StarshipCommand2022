#!/usr/bin/python3

import re

# Load the exclusions file
with open("exclusions.txt") as file:
    exclusions = [line.rstrip() for line in file]

# Load the symbols file
text = open("build/STAR.symbols.txt", "r")

sym = dict()

for line in text:
    # Remove the leading spaces and newline character
    line = line.strip()

    # e.g. "	a_over_32_plus_ten_times_y	= $4165	; ?"

#    match = re.match(r"\s+([A-Za-z_0-9]+)\s+=\s+\$([0-9a-f][0-9a-f][0-9a-f][0-9a-f]).*", line)
#    print(line)
    match = re.match(r"\s*([A-Za-z_0-9]+)\s*=\s*\$([0-9a-f][0-9a-f][0-9a-f][0-9a-f]).*", line)
    if match:
        name = match.groups(1)[0]
        addr = int(match.groups(1)[1], 16)
        sym[addr] = name
text.close()

symbols=dict(sorted(sym.items(),key= lambda x:x[0]))
#print(symbols)


def symbol_for_addr(symbols, addr):
    oldaddr = 0
    oldname = "unknown (before symbols)"
    for symaddr in symbols:
        if (addr >= oldaddr) and (addr < symaddr):
            return oldname
        oldaddr = symaddr
        oldname = symbols[symaddr]
    return "unknown (after symbols)"


# Open the file in read mode
text = open("trace.txt", "r")

# Create an empty dictionary
d = dict()

# Loop through each line of the file
for line in text:
    # Remove the leading spaces and newline character
    line = line.strip()

    match = re.match(r"\d+ +m`\$([0-9a-f][0-9a-f][0-9a-f][0-9a-f])", line)
    if match:
        addr = int(match.groups(1)[0], 16)

        # Check if the word is already in dictionary
        if addr in d:
            # Increment count of word by 1
            d[addr] = d[addr] + 1
        else:
            # Add the word to dictionary with count 1
            d[addr] = 1
text.close()

results=dict(sorted(d.items(),key= lambda x:x[1]))


# make new dictionary of symbols and total instruction counts
sy = dict()

oldsymbol = ""
oldtotal = 0
for key in list(results.keys()):
    symbol = symbol_for_addr(symbols, key)
    if not symbol in exclusions:
        if symbol == oldsymbol:
            oldtotal += results[key]
        else:
            sy[oldsymbol] = oldtotal
            print(oldsymbol + ":", oldtotal)
            oldtotal = results[key]

        oldsymbol = symbol

if oldtotal > 0:
    print(oldsymbol + ":", oldtotal)
    sy[oldsymbol] = oldtotal

sy=dict(sorted(sy.items(),key= lambda x:x[1]))


# Print the contents of dictionary
for key in sy:
    print(key+":", sy[key])
