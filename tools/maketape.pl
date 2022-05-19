#!/usr/bin/perl -w
use Digest::CRC qw[crc];
print "UEF File!\x00\x01\x00";
chunk(0x110,pack"v",500); # carrier
my $loader=shift;
open F, "<$loader" or die "$loader: $!";
undef $/; # slurp
$data=<F>;
$data2=substr($data,0,255);
$data=substr($data,255);
$fn="STAR2022";
$load=0xffff0500;
$exec=0xffff0509;
$blkno=0;
$blklen=length$data;
$flags=0x80;
my $header=$fn.pack"CVVvvCV",0,
    $load,$exec,$blkno,$blklen,$flags,0xe28ce1;
$header='*'.$header.pack"n",crc($header,16,0,0,0,0x1021,0,0);

$data.=pack"n",crc($data,16,0,0,0,0x1021,0,0);
$data2=reverse $data2;

my $main=shift;
open F, "<$main" or die "$main: $!";
$raw = <F>;
chunk(0x100,$header.$data.$data2.$raw);

sub chunk {
    my ($id,$data)=@_;
    print pack"vV",$id,length$data;
    print $data;
}
