import sys
import re

start_pattern = re.compile(r'^ *pydis_start *$')
end_pattern = re.compile(r'^ *pydis_end *$')
instruction_pattern = re.compile(r"^\s+(ADC|AND|ASL|BCC|BCS|BEQ|BIT|BMI|BNE|BPL|BRK|BVC|BVS|CLC|CLD|CLI|CLV|CMP|CPX|CPY|DEC|DEX|DEY|EOR|INC|INX|INY|JMP|JSR|LDA|LDX|LDY|LSR|NOP|ORA|PHA|PHP|PLA|PLP|ROL|ROR|RTI|RTS|SBC|SEC|SED|SEI|STA|STX|STY|TAX|TAY|TSX|TXA|TXS|TYA|!byte|!word|!32|!text)(\s.*)?$", re.I)

for line in sys.stdin:
    line = line.rstrip()
    if (end_pattern.search(line) != None):
        break
    if (start_pattern.search(line) != None):
        continue
    match = instruction_pattern.search(line)
    if (match != None):
        line = line.rstrip().ljust(69, ' ') + " ; "

    print(line)
