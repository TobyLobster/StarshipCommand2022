# See https://stardot.org.uk/forums/viewtopic.php?p=299667#p299667

##################################
# Image.py      written by ash73 #
#                                #
# v0.4                 13Dec2020 #
##################################

# This is a python 3 script to transfer files between a host computer and a BBC micro emulator,
# such as BeebEm, via disk images. It has functions to scan disk images, insert files, extract
# files, delete files and compact the disk. It can read single-sided and double-sided DFS images.

# Specify the disk, type and side first, then the command(s) to run. Commands can be daisy chained
# for batch processes. The script can de-tokenise BASIC programs extracted from the disk.

# The script generates a .inf file for any files extracted from the disk image. When inserting
# a file it looks for a .inf file with the same name to get the load & execution addresses and
# if it doesn't find one prompts the user to enter them instead.

# Richard Russell's tokenise utility is used to re-tokenise BASIC programs - thanks RR!

# Check you have python 3 installed, and python is included in your PATH. Python 3 can be installed
# alongside older versions without changing the default version.

# To check python: python --version
# To run script:   python image.py <command(s)> (if python 3 is default)
#                  python3 image.py <command(s)>
#                  image.py <command(s)>

# COMMANDS
# catalogue: image.py -d <disk> [-t <type> -s <side>] -cat
# extract:   image.py -d <disk> [-t <type> -s <side>] -e <file>
# insert:    image.py -d <disk> [-t <type> -s <side>] -i <file>
# delete:    image.py -d <disk> [-t <type> -s <side>] -del <file>
# compact:   image.py -d <disk> [-t <type> -s <side>] -compact

# Parameters in [square brackets] are optional.

# type = ssd (single-sided), dsd (double-sided interleaved), dss (double-sided sequential)
# type is set automatically from the disk image file extension if not explicit.

# side = 0 (default), 2

# -extract and -insert process raw files without modification.
# use -extract* (or -e*) to de-tokenise files, and -insert* (or -i*) to re-tokenise them.

# Commands can be abbreviated:

# -help     -?
# -disk	    -d
# -type	    -t
# -side	    -s
# -cat	    -c
# -extract  -e
# -extract* -e*
# -insert   -i
# -insert*  -i*
# -delete   -del
# -compact  -com

# Commands can be combined:

# e.g. to catalogue a disk before and after compacting:
# image.py -d mydisk.ssd -cat -compact -cat

# e.g. to catalogue disk side 2 after compacting and inserting a tokenised BASIC file:
# image.py -d mydisk.dsd -s 2 -compact -i* basprog -cat

# Specify the disk/type/side FIRST when combining commands:
# e.g. image.py -d foo.dsd -s 2 -cat -e file1 -e* file2
#               ^^^^^^^^^^



import sys
import os.path
import subprocess
import shutil

class DiskImage:

    def __init__(self):

        # constants
        self.DISKTYPES = ['DFS/WDFS<256K', 'WDFS>256K', 'HDFS(SS)', 'HDFS(DS)']

        self.BOOTOPTS  = ['NOTHING', 'LOAD', 'RUN', 'EXEC']

                        # omits 141 (line numbers)
        self.TOKENS    = [(128,"AND"),      \
                         (129,"DIV"),       \
                         (130,"EOR"),       \
                         (131,"MOD"),       \
                         (132,"OR"),        \
                         (133,"ERROR"),     \
                         (134,"LINE"),      \
                         (135,"OFF"),       \
                         (136,"STEP"),      \
                         (137,"SPC"),       \
                         (138,"TAB("),      \
                         (139,"ELSE"),      \
                         (140,"THEN"),      \
                         (142,"OPENIN"),    \
                         (143,"PTR"),       \
                         (144,"PAGE"),      \
                         (145,"TIME"),      \
                         (146,"LOMEM"),     \
                         (147,"HIMEM"),     \
                         (148,"ABS"),       \
                         (149,"ACS"),       \
                         (150,"ADVAL"),     \
                         (151,"ASC"),       \
                         (152,"ASN"),       \
                         (153,"ATN"),       \
                         (154,"BGET"),      \
                         (155,"COS"),       \
                         (156,"COUNT"),     \
                         (157,"DEG"),       \
                         (158,"ERL"),       \
                         (159,"ERR"),       \
                         (160,"EVAL"),      \
                         (161,"EXP"),       \
                         (162,"EXT"),       \
                         (163,"FALSE"),     \
                         (164,"FN"),        \
                         (165,"GET"),       \
                         (166,"INKEY"),     \
                         (167,"INSTR("),    \
                         (168,"INT"),       \
                         (169,"LEN"),       \
                         (170,"LN"),        \
                         (171,"LOG"),       \
                         (172,"NOT"),       \
                         (173,"OPENUP"),    \
                         (174,"OPENOUT"),   \
                         (175,"PI"),        \
                         (176,"POINT("),    \
                         (177,"POS"),       \
                         (178,"RAD"),       \
                         (179,"RND"),       \
                         (180,"SGN"),       \
                         (181,"SIN"),       \
                         (182,"SQR"),       \
                         (183,"TAN"),       \
                         (184,"TO"),        \
                         (185,"TRUE"),      \
                         (186,"USR"),       \
                         (187,"VAL"),       \
                         (188,"VPOS"),      \
                         (189,"CHR$"),      \
                         (190,"GET$"),      \
                         (191,"INKEY$"),    \
                         (192,"LEFT$("),    \
                         (193,"MID$("),     \
                         (194,"RIGHT$("),   \
                         (195,"STR$"),      \
                         (196,"STRING$("),  \
                         (197,"EOF"),       \
                         (198,"AUTO"),      \
                         (199,"DELETE"),    \
                         (200,"LOAD"),      \
                         (201,"LIST"),      \
                         (202,"NEW"),       \
                         (203,"OLD"),       \
                         (204,"RENUMBER"),  \
                         (205,"SAVE"),      \
                         (206,"EDIT"),      \
                         (207,"PTR"),       \
                         (208,"PAGE"),      \
                         (209,"TIME"),      \
                         (210,"LOMEM"),     \
                         (211,"HIMEM"),     \
                         (212,"SOUND"),     \
                         (213,"BPUT"),      \
                         (214,"CALL"),      \
                         (215,"CHAIN"),     \
                         (216,"CLEAR"),     \
                         (217,"CLOSE"),     \
                         (218,"CLG"),       \
                         (219,"CLS"),       \
                         (220,"DATA"),      \
                         (221,"DEF"),       \
                         (222,"DIM"),       \
                         (223,"DRAW"),      \
                         (224,"END"),       \
                         (225,"ENDPROC"),   \
                         (226,"ENVELOPE"),  \
                         (227,"FOR"),       \
                         (228,"GOSUB"),     \
                         (229,"GOTO"),      \
                         (230,"GCOL"),      \
                         (231,"IF"),        \
                         (232,"INPUT"),     \
                         (233,"LET"),       \
                         (234,"LOCAL"),     \
                         (235,"MODE"),      \
                         (236,"MOVE"),      \
                         (237,"NEXT"),      \
                         (238,"ON"),        \
                         (239,"VDU"),       \
                         (240,"PLOT"),      \
                         (241,"PRINT"),     \
                         (242,"PROC"),      \
                         (243,"READ"),      \
                         (244,"REM"),       \
                         (245,"REPEAT"),    \
                         (246,"REPORT"),    \
                         (247,"RESTORE"),   \
                         (248,"RETURN"),    \
                         (249,"RUN"),       \
                         (250,"STOP"),      \
                         (251,"COLOUR"),    \
                         (252,"TRACE"),     \
                         (253,"UNTIL"),     \
                         (254,"WIDTH"),     \
                         (255,"OSCLI")]

        # attributes
        self.disk  = ""
        self.type  = "ssd" # "ssd" single-sided, "dsd" double-sided interleaved, "dss" double-sided sequential
        self.side  = "0"   # "0" or "2"
        self.verbose_level = 0


    def help(self):

        print("Image.py - v0.4 13Dec2020, written by ash73")
        print("")
        print("catalogue: image.py -d <disk> [-t <type> -s <side>] -cat")
        print("extract:   image.py -d <disk> [-t <type> -s <side>] -e <file>")
        print("insert:    image.py -d <disk> [-t <type> -s <side>] -i <file>")
        print("delete:    image.py -d <disk> [-t <type> -s <side>] -del <file>")
        print("compact:   image.py -d <disk> [-t <type> -s <side>] -compact")
        print("")
        print("type = ssd (single-sided), dsd (interleaved), dss (sequential)")
        print("")
        print("type is set by file extension if not explicit.")
        print("")
        print("side = 0 (default), 2")
        print("")
        print("-extract and -insert transfer raw files without modification.")
        print("")
        print("-extract* (or -e*) to de-tokenise, -insert* (or -i*) to tokenise.")
        print("")
        print("Commands:")
        print("-help -?, -disk -d, -type -t, -side -s, -cat -c, -extract -e")
        print("-extract* -e*, -insert -i, -insert* -i*, -delete -del, -compact -com\n")

    def verbose(i):
        self.verbose_level = i

    def set_disk(self, disk):

        # error checks
        if not(os.path.exists(disk)):
            print("ERROR: disk image not found")
            sys.exit()

        self.disk = disk

        # use extension to guess type
        i = disk.rfind(".")

        if disk[i:] == ".ssd":
            self.set_type("ssd")

        elif disk[i:] == ".dsd":
            self.set_type("dsd")

        elif disk[i:] == ".dss":
            self.set_type("dss")

        else:
            self.set_type("ssd")

        # select default side
        self.set_side("0")


    def set_type(self, type):

        # error checks
        if type !="ssd" and type != "dsd" and type != "dss":
            print("ERROR: invalid type (valid = ssd, dsd, dss")
            sys.exit()

        self.type = type


    def set_side(self, side):

        # error checks
        if self.type == "ssd" and side != "0":
            print("ERROR: invalid side (disk is single-sided)")
            sys.exit()

        if side != "0" and side != "2":
            print("ERROR: invalid side (use 0 or 2)")
            sys.exit()

        self.side = side


    def _scan(self):

        # disk arrays
        self._side0     = bytearray()
        self._side2     = bytearray()
        self._disk_data = bytearray() # acts as a pointer to selected side data

        # disk data
        self.disk_sectors = 0
        self.disk_title   = ""
        self.disk_cycle   = 0
        self.disk_files   = 0
        self.disk_boot    = 0
        self.disk_type    = 0

        # file data (for all files on disk)
        self.file_name    = []
        self.file_lock    = []
        self.file_load    = []
        self.file_exec    = []
        self.file_length  = []
        self.file_sector  = []
        self.sectors_used = []

        # error checks
        if self.disk == "":
            print("ERROR: no disk image specified")
            sys.exit()

        if not(os.path.exists(self.disk)):
            print("ERROR: disk image not found")
            sys.exit()

        # need to know number of sectors to read disk
        with open(self.disk, 'rb') as f:
            data = f.read(512)
            self.disk_sectors = (data[0x106] & 0b00000011) * 0x100 + data[0x107]

        # read disk data
        with open(self.disk, 'rb') as f:

            if self.type == "ssd":

                # single-sided
                self._side0 += f.read(self.disk_sectors * 256)

            elif self.type == "dsd":

                # double-sided interleaved
                i = 0
                while i < self.disk_sectors:
                    self._side0 += f.read(10 * 256)
                    self._side2 += f.read(10 * 256)
                    i += 10

            elif self.type == "dss":

                # double-sided sequential
                self._side0 += f.read(self.disk_sectors * 256)
                self._side2 += f.read(self.disk_sectors * 256)

        # expand if clipped
        self._side0.extend([0] * (self.disk_sectors * 256 - len(self._side0)))
        self._side2.extend([0] * (self.disk_sectors * 256 - len(self._side2)))

        # select side and catalogue
        if self.side == "0":
            self._disk_data = self._side0 # bytearray is mutable... changes to disk_data ALSO change side0
        else:
            self._disk_data = self._side2 # as above

        # catalogue data
        data = self._disk_data[0:512]

        # parse catalogue data
        self.disk_title   = (data[0:7 + 1] + data[0x100:0x103 + 1]).decode('Latin-1').strip()
        self.disk_cycle   = data[0x104]
        self.disk_files   = data[0x105] >> 3
        self.disk_boot    = (data[0x106] >> 4) & 0b00000011
        self.disk_type    = (data[0x106] >> 2) & 0b00000011
        # disk_sectors = (data[0x106] & 0b00000011) * 0x100 + data[0x107]

        # abort if not DFS disk
        if self.disk_type > 0:
            print("ERROR: cannot process this disk type")
            sys.exit()

        # parse file data
        for i in range(0, self.disk_files):

            p = (i + 1) * 8

            # d.filename
            s = chr(data[p + 7] & 0b01111111) + "."
            for i2 in range(0, 7):
                s += chr(data[p + i2] & 0b01111111)
            self.file_name.append(s.strip())

            # lock
            if (data[p + 7] >> 7):
                self.file_lock.append("L")
            else:
                self.file_lock.append(" ")

            # load address
            addr = data[p + 0x101] * 0x100 + data[p + 0x100]
            hb   = (data[p + 0x106] >> 2) & 0b00000011
            if hb == 3:
                addr += 0xFFFF0000
            else:
                addr += hb * 0x10000
            self.file_load.append(addr)

            # exec address
            addr = data[p + 0x103] * 0x100 + data[p + 0x102]
            hb   = (data[p + 0x106] >> 6) & 0b00000011
            if hb == 3:
                addr += 0xFFFF0000
            else:
               addr += hb * 0x10000
            self.file_exec.append(addr)

            # file length
            length = data[p + 0x105] * 0x100 + data[p + 0x104]
            hb     = (data[p + 0x106] >> 4) & 0b00000011
            length += hb * 0x10000
            self.file_length.append(length)

            # start sector
            self.file_sector.append((data[p + 0x106] & 0b00000011) * 0x100 + data[p + 0x107])

        # sectors used
        self.sectors_used = ["X","X"] + ["-"] * (self.disk_sectors - 2)
        for i in range(self.disk_files):

            for i2 in range(-(-self.file_length[i] // 256)): # round up

                self.sectors_used[self.file_sector[i] + i2] = "X"


    def catalogue(self):

        # scan disk-image
        self._scan()

        # print summary
        if self.type != "ssd":
            s = " (side " + self.side + ")"
        else:
            s = ""
        print("\n")
        print("Disk image   : " + self.disk + s)
        print("Disk title   : " + str(self.disk_title))
        print("# of files   : " + str(self.disk_files))
        print("Boot option  : " + str(self.disk_boot) + "(" + self.BOOTOPTS[self.disk_boot] + ")")
        print("Sectors      : " + str(self.disk_sectors))
        print("Disk cycle   : " + str(self.disk_cycle))
        # print("Disk type    : " + self.DISKTYPES[self.disk_type])
        print("\r\nFILENAME     LOAD     EXEC     SIZE     SEC\r\n")

        for i in range(self.disk_files):
            print(self.file_name[i].ljust(10) + " " \
                + self.file_lock[i] + " " \
                + '{:08X}'.format(self.file_load[i]) + " " \
                + '{:08X}'.format(self.file_exec[i]) + " " \
                + '{:08X}'.format(self.file_length[i]) + " " \
                + '{:03X}'.format(self.file_sector[i]))

        print("\nSectors used:")
        matrix = [self.sectors_used[i : i + 40] for i in range(0, len(self.sectors_used), 40)]
        for r in matrix:
            print(",".join(r).replace(",", ""))


    def extract(self, file, detokenise = False):

        # scan disk-image
        self._scan()

        # error checks
        if file == "":
            print("ERROR: file not specified")
            sys.exit()

        # assume dir $ if none specified
        if file[1] != ".":
            file = "$." + file

        # find the file
        try:
            # Beeb does not distinguish case
            file_name_ucase = [item.upper() for item in self.file_name]
            file_index = file_name_ucase.index(file.upper())
            print("extracting " + file + " from " + self.disk + "...")
        except:
            print("ERROR: file not found")
            sys.exit()

        # get the file data
        start = self.file_sector[file_index] * 256
        data  = self._disk_data[start : start + self.file_length[file_index]]

        # check for BASIC file
        bas_file = (self.file_exec[file_index] & 0xFFFF > 0x8000 and self.file_exec[file_index] & 0xFFFF < 0x80FF)
        if detokenise:
            if not bas_file:
                print("WARNING: " + file + " does not have a typical exec address for a BASIC file...")
            print("de-tokenising file...")

        # container for file
        file_data = bytearray()

        # extract file and de-tokenise if required
        in_quotes = False
        i = 0
        while i < len(data):
            if detokenise:

                # new line is followed by line number (hb/lb)
                if data[i] == 13:
                    if i + 3 < len(data):
                        file_data += (chr(13) + str(data[i+1]*256 + data[i+2])).encode('Latin-1')
                        # extra byte for line length can be skipped
                        i += 3
                    else:
                        # eof
                        file_data += chr(13).encode('Latin-1')
                        i = len(data)
                    in_quotes = False

                # ignore special chrs inside quotes
                elif data[i] == 34:

                    in_quotes = not(in_quotes)
                    file_data += chr(34).encode('Latin-1')

                # line number token
                elif data[i] == 141:

                    # calc line number
                    target = data[i+2] - 64 + (data[i+3] - 64) * 256
                    if data[i+1] == 68:
                        target += 64
                    elif data[i+1] == 100:
                        target += 192
                    elif data[i+1] == 116:
                        target += 128

                    file_data += str(target).encode('Latin-1')
                    i += 3

                # keyword tokens
                elif not(in_quotes) and data[i] >= 128 and data[i] <= 255:

                    # retrieve token text
                    t = ""
                    for token in self.TOKENS:
                        if token[0] == data[i]:
                            t = token[1]

                    file_data += t.encode('Latin-1')

                # standard text
                else:
                    file_data += chr(data[i]).encode('Latin-1')

            # generic file data
            else:
                file_data += chr(data[i]).encode('Latin-1')

            # loop until eof
            i += 1

        # write file on host
        filename = self.file_name[file_index]
        print("writing " + filename + " on host...")
        with open(filename, "wb") as f:
            f.write(file_data)

        # write .inf file on host
        print("writing " + filename + ".inf on host...")
        t = (self.file_name[file_index]).ljust(12) \
                + '{:08X}'.format(self.file_load[file_index]) + "  " \
                + '{:08X}'.format(self.file_exec[file_index]) + "  " \
                + self.file_lock[file_index].ljust(3) \
                + '{:08X}'.format(self.file_length[file_index])

        with open(filename + ".inf", "wb") as f:
            f.write(t.encode('Latin-1'))


    def insert(self, file, tokenise = False):

        # scan disk-image
        self._scan()

        # error checks
        if not(os.path.exists(file)):
            print("ERROR: file not found")
            sys.exit()

        # assume dir $ if none specified
        if file[1] != ".":
            target = "$." + file
        else:
            target = file

        # tokenise BASIC file
        if tokenise:
            print("tokenising file...")

            # files are tokenised using separate utility written by Richard Russell - thanks RR!
            if not (os.path.exists("tokenise.exe") or os.path.exists("tokenise")):
                print("ERROR: 'tokenise' utility required to tokenise BASIC programs")
                print("This can be downloaded from stardot.org.uk")
                sys.exit()

            # tokenise will produce file called "abb"
            f = file[0:2] + "abb"
            if os.path.exists(f):
                os.remove(f)

            # call tokenise utility
            if sys.platform == "win32":

                # windows
                info = subprocess.STARTUPINFO()
                info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                info.wShowWindow = subprocess.SW_HIDE
                cmd = ['tokenise', file]
                with subprocess.Popen(cmd, stdout=subprocess.PIPE, startupinfo=info) as proc:
                    print(proc.stdout.read().strip(b'').decode('ascii'))
            else:

                # linux ("linux" or "linux2") or OS X ("darwin")
                cmd = ['./tokenise', file]
                with subprocess.Popen(cmd, stdout=subprocess.PIPE) as proc:
                    print(proc.stdout.read().strip(b'').decode('ascii'))

            if not os.path.exists(f):
                print("ERROR: failed to tokenise file")
                sys.exit()

            # copy .inf file matching original filename
            if os.path.exists(file + ".inf"):
                print("using " + file + ".inf as " + f + ".inf")
                shutil.copyfile(file + ".inf", f + ".inf")

            # insert tokenised file
            file = f

        # check if file already exists on disk image
        try:
            # Beeb does not distinguish case
            file_name_ucase = [item.upper() for item in self.file_name]
            file_index = file_name_ucase.index(target.upper())
        except:
            file_index = -1

        if file_index != -1:
            print("WARNING: file already exists in disk image")
            s = input("are you sure? ")
            if s.find("Y") == -1 and s.find("y") == -1:
                print("aborted")
                sys.exit()

        # check sufficient space on disk
        size = os.path.getsize(file)
        sectors = -(-size // 256) # round up

        # reset used sectors to empty if replacing file (re-scan after)
        if file_index != -1:
            i = self.file_sector[file_index] # start sector
            s = -(-self.file_length[file_index] // 256) # round up
            for i in range(i, i + s):
                self.sectors_used[i] = "-"

        if self.sectors_used.count("-") < sectors:
            print("ERROR: insufficient space")
            sys.exit()

        # find the first space big enough
        start_sector = (''.join(self.sectors_used)).find("-" * sectors)
        if start_sector == -1:
            print("ERROR: disk needs compacting first")
            sys.exit()

        # get file attributes
        if (os.path.exists(file + ".inf")):
            if (self.verbose_level > 0):
                print("found " + file + ".inf...")

            with open(file + ".inf", "r") as f:
                s = f.read()

                # file
                i = s.find(" ")
                f = s[0:i]
                if f[1] != ".":
                    f = "$." + f

                if f.upper() != target.upper():
                    print("ERROR: .inf does not refer to the same file")
                    sys.exit()
                else:
                    target = f # match case

                # load
                while s[i] == " ":
                    i += 1
                i2 = i
                i = s.find(" ",i)
                s1 = s[i2:i]

                # exec
                while s[i] == " ":
                    i += 1
                i2 = i
                i = s.find(" ",i)
                s2 = s[i2:i]

                # lock
                i = s.find("L",i)
                if i != -1:
                    lock = "L"
                else:
                    lock = " "

        else:

            s1 = input("Enter load address (hex): 0x")
            s2 = input("Enter exec address (hex): 0x")
            s3 = input("Lock (y/n)?")

            if s3.find("Y") != -1 or s3.find("y") != -1:
                lock = "L"
            else:
                lock = " "

        try:
            load_addr = int(s1, 16)
        except:
            print("ERROR: invalid load address")
            sys.exit()

        try:
            exec_addr = int(s2, 16)
        except:
            print("ERROR: invalid exec address")
            sys.exit()

        if (self.verbose_level > 0):
            print("load: " + hex(load_addr), "exec: " + hex(exec_addr),
                  "length: " + hex(size), "sector: " + hex(start_sector))

        # check for BASIC file
        bas_file = (exec_addr & 0xFFFF > 0x8000 and exec_addr & 0xFFFF < 0x80FF)
        if bas_file and not tokenise:
            print("NOTE: BASIC program not tokenised (*exec and save)")

        # get file from host
        with open(file, 'rb') as f:
            file_data = f.read()

        # insert into disk data
        i = 0
        for b in file_data:
            self._disk_data[start_sector * 256 + i] = b
            i += 1

        # update catalogue
        if file_index == -1:

            # catalogue must be in ascending sector order
            i = 0
            if self.disk_files > 0:
                while start_sector < self.file_sector[i]:
                    i += 1
                    if i == len(self.file_sector):
                        break

            # insert file
            self.file_name.insert(i, target)
            self.file_lock.insert(i, lock)
            self.file_load.insert(i, load_addr)
            self.file_exec.insert(i, exec_addr)
            self.file_length.insert(i, size)
            self.file_sector.insert(i, start_sector)
            self.disk_files += 1

        else:

            # replace file
            self.file_name[file_index] = target
            self.file_lock[file_index] = lock
            self.file_load[file_index] = load_addr
            self.file_exec[file_index] = exec_addr
            self.file_length[file_index] = size
            self.file_sector[file_index] = start_sector

        # update disk data
        self.disk_cycle += 1
        self._disk_data[0x104] = self.disk_cycle
        self._disk_data[0x105] = self.disk_files << 3

        # update _disk_data from file data
        self._update_catalogue()

        # write changes to disk image
        self._write_to_disk()

        # refresh
        self._scan()


    def delete(self, file):

        # scan disk-image
        self._scan()

        # assume dir $ if none specified
        if file[1] != ".":
            file = "$." + file
        else:
            file = file

        # check file exists on disk image
        try:
            # Beeb does not distinguish case
            file_name_ucase = [item.upper() for item in self.file_name]
            file_index = file_name_ucase.index(file.upper())
        except:
            file_index = -1

        if file_index == -1:
            print("ERROR: file not found")
            sys.exit()
        else:
            s = input("WARNING: Delete " + file + " from " + self.disk + " - are you sure (y/n)?")
            if s.find("Y") == -1 and s.find("y") == -1:
                print("aborted")
                sys.exit()

        # delete file from file data
        del self.file_name[file_index]
        del self.file_lock[file_index]
        del self.file_load[file_index]
        del self.file_exec[file_index]
        del self.file_length[file_index]
        del self.file_sector[file_index]
        self.disk_files -= 1

        # update disk data
        self.disk_cycle += 1
        self._disk_data[0x104] = self.disk_cycle
        self._disk_data[0x105] = self.disk_files << 3

        # update _disk_data from file data
        self._update_catalogue()

        # write changes to disk image
        self._write_to_disk()

        # refresh
        self._scan()


    def compact(self):

        # scan disk-image
        self._scan()

        if self.type == "ssd":
            print("compacting " + self.disk + "...")
        else:
            print("compacting " + self.disk + " (side " + str(self.side) + ")...")

        # calculate relocation sectors
        new_file_sector = []
        s = 2
        new_file_sector.append(s)

        for i in range(self.disk_files, 0, -1):
            s += -(-self.file_length[i - 1] // 256) # round up
            new_file_sector.append(s)

        new_file_sector = new_file_sector[:-1]
        new_file_sector.reverse()

        # make copy of disk data
        disk_copy = bytearray()
        for b in self._disk_data:
            disk_copy.append(b)

        # compact
        for i in range(0, self.disk_files):

            p = (i + 1) * 8

            # start sector
            hb = new_file_sector[i] // 256
            lb = new_file_sector[i] - hb * 256

            # modify bits 0 & 1
            self._disk_data[p + 0x106] = (self._disk_data[p + 0x106] & 0b11111100) | (hb & 0b00000011)
            self._disk_data[p + 0x107] = lb

            # move file to new location
            source = self.file_sector[i] * 256
            target = new_file_sector[i] * 256

            for b in range(0, self.file_length[i]):
                self._disk_data[target + b] = disk_copy[source + b]

        # update disk data
        self.disk_cycle += 1
        self._disk_data[0x104] = self.disk_cycle

        # write changes to disk image
        self._write_to_disk()

        # refresh
        self._scan()


    def _update_catalogue(self):

        # update catalogue entries in _disk_data before writing to disk
        for i in range(0, self.disk_files):

            p = (i + 1) * 8

            # filename
            for i2 in range(0, 7):
                if i2 < len(self.file_name[i]) - 2:
                    self._disk_data[p + i2] = ord(self.file_name[i][i2 + 2])
                else:
                    self._disk_data[p + i2] = 32 # pad with spaces

            # directory
            self._disk_data[p + 7] = ord(self.file_name[i][0])

            # lock
            if self.file_lock[i] == "L":
                self._disk_data[p + 7] = self._disk_data[p + 7] | 0b10000000 # set top bit
            else:
                self._disk_data[p + 7] = self._disk_data[p + 7] & 0b01111111 # clear top bit

            # load address
            if self.file_load[i] & 0xFFFF0000 == 0xFFFF0000:
                hhb = 3
            else:
                hhb = self.file_load[i] // 0x10000

            # modify bits 2 & 3
            self._disk_data[p + 0x106] = (self._disk_data[p + 0x106] & 0b11110011) | ((hhb << 2) & 0b00001100)

            x = self.file_load[i] & 0xFFFF
            hb = x // 256
            lb = x - hb * 0x100
            self._disk_data[p + 0x100] = lb
            self._disk_data[p + 0x101] = hb

            # exec address
            if self.file_exec[i] & 0xFFFF0000 == 0xFFFF0000:
                hhb = 3
            else:
                hhb = self.file_exec[i] // 0x10000

            # modify bits 6 & 7
            self._disk_data[p + 0x106] = (self._disk_data[p + 0x106] & 0b00111111) | ((hhb << 6) & 0b11000000)

            x = self.file_exec[i] & 0xFFFF
            hb = x // 256
            lb = x - hb * 0x100
            self._disk_data[p + 0x102] = lb
            self._disk_data[p + 0x103] = hb

            # file length
            hhb = self.file_length[i] // 0x10000

            # modify bits 4 & 5
            self._disk_data[p + 0x106] = (self._disk_data[p + 0x106] & 0b11001111) | ((hhb << 4) & 0b00110000)

            x = self.file_length[i] & 0xFFFF
            hb = x // 256
            lb = x - hb * 0x100
            self._disk_data[p + 0x104] = lb
            self._disk_data[p + 0x105] = hb

            # start sector
            hb = self.file_sector[i] // 256
            lb = self.file_sector[i] - hb * 256

            # modify bits 0 & 1
            self._disk_data[p + 0x106] = (self._disk_data[p + 0x106] & 0b11111100) | (hb & 0b00000011)
            self._disk_data[p + 0x107] = lb


    def _write_to_disk(self):

        if (self.verbose_level > 0):
            print("\nwriting changes to " + self.disk + "...\n")
        with open(self.disk, 'wb') as f:

            if self.type == "ssd":

                # single-sided
                f.write(self._side0)

            elif self.type == "dsd":

                # double-sided interleaved
                i = 0
                while i < self.disk_sectors:

                    f.write(self._side0[i*256 : (i+10)*256])
                    f.write(self._side2[i*256 : (i+10)*256])
                    i += 10

            elif self.type == "dss":

                # double-sided sequential
                f.write(self._side0)
                f.write(self._side2)


def main(args):

    # disk image object
    disk_image = DiskImage()

    # parse command line
    if len(args) == 0:
        disk_image.help()

    i=0
    while i < len(args):

        if args[i] == "-help" or args[i] == "-?":
            disk_image.help()

        elif args[i] == "-disk" or args[i] == "-d":
            disk_image.set_disk(args[i + 1])

        elif args[i] == "-type" or args[i] == "-t":
            disk_image.set_type(args[i + 1])

        elif args[i] == "-side" or args[i] == "-s":
            disk_image.set_side(args[i + 1])

        elif args[i] == "-cat" or args[i] == "-c":
            disk_image.catalogue()

        elif args[i] == "-extract" or args[i] == "-e":
            disk_image.extract(args[i + 1])

        elif args[i] == "-extract*" or args[i] == "-e*": # de-tokenises BASIC programs
            disk_image.extract(args[i + 1], True)

        elif args[i] == "-insert" or args[i] == "-i":
            disk_image.insert(args[i + 1])

        elif args[i] == "-insert*" or args[i] == "-i*": # re-tokenises BASIC programs
            disk_image.insert(args[i + 1], True)

        elif args[i] == "-delete" or args[i] == "-del":
            disk_image.delete(args[i + 1])

        elif args[i] == "-compact" or args[i] == "-com":
            disk_image.compact()

        elif args[i] == "-verbose" or args[i] == "-v":
            disk_image.verbose(1)

        i += 1


# do it!
main(sys.argv[1:])

