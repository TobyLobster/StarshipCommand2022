#!/usr/bin/perl -w
use Digest::CRC qw[crc];

print "UEF File!\x00\x0a\x00";          # magic string, zero terminator and UEF 0.10 version number
chunk(0x110,pack"v",500);               # carrier tone
chunk(0x100,0xdc);                      # one dummy byte to break the carrier tone (this helps the OS/hardware latch onto the carrier tone when loading I think)
chunk(0x110,pack"v",500);               # carrier tone

# get first loader binary data (from tape.asm, which assembles the decompression code at $0401 and first loader binary code at $0500 upwards)
my $loader=shift;
open F, "<$loader" or die "$loader: $!";
undef $/; # slurp
$first_load_data=<F>;
$decompression_code = substr($first_load_data,0,255);   # the first 255 bytes is decompression code
$first_load_data    = substr($first_load_data,255);     # remainder of the first loader program

$fn     = "STAR2022";                   # file name
$load   = 0xffff0500;                   # load address
$exec   = 0xffff0509;                   # exec address, after a short BASIC program
$blkno  = 0;                            # block zero
$blklen = length$first_load_data;       # length of block
$flags  = 0x80;                         #

# construct header data
my $first_load_header=$fn.pack"CVVvvCV",0,$load,$exec,$blkno,$blklen,$flags,0xe28ce1;
$first_load_header='*'.$first_load_header.pack"n",crc($first_load_header,16,0,0,0,0x1021,0,0);

# construct actual first load binary data including CRC
$first_load_data.=pack"n",crc($first_load_data,16,0,0,0,0x1021,0,0);

$decompression_code=reverse $decompression_code;    # decompression code is loaded backwards

# the game binary
# Set $tape_exo_data to be the binary code of the main game, loaded from three compressed files:  '<file>.tape.1.exo', '<file>.tape.2.exo', '<file>.tape.3.exo'
while (my $main=shift) {
    open F, "<$main" or die "$main: $!";
    $tape_exo_data .= <F>;
}
chunk(0x100,$first_load_header.$first_load_data);   # header and first loader ($500 upwards from tape.asm)
chunk(0x110,pack"v",50);                            # short carrier tone
chunk(0x100,$decompression_code.$tape_exo_data);    # decompression code ($401-$4ff) then the three
                                                    # compressed files (.exo) containing the main game
                                                    # binary from three chunks (.1.exo, .2.exo, .3.exo)
chunk(0x110,pack"v",500);                           # final carrier tone

#sub file {
#    my $fn=shift;
#    open F, "<$fn" or die "$fn: $!";
#    $tape_exo_data.=<F>;
#}

sub chunk {
    my ($id,$data)=@_;
    print pack"vV",$id,length$data;
    print $data;
}
