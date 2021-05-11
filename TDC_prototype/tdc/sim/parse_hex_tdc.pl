#!/usr/bin/perl
#
# parse hex TDC output data
#
#   "# Trig len 52 Data len 28
#   "E 18156 ns 200000011B1C0000
#   "E 22964 ns 2000000165EC0001
#   "E 23008 ns 400000000378A018
#
# upper 4 bits are type:  1 = IDLE (shouldn't occur)
#   2 = header (trigger)  4 = DATA (TDC hit)
#
# trigger word:
#   32 evn        51..20
#   2  phase      19,18
#   18 event no   17..0
#
# TDC word:
#   6 le_time      27,22
#   2 le_phase     21,20
#   6 te_time      19..14
#   2 te_phase     13,12
#   8 trigger_num  11,4
#   2 buffer_num   3,2
#   1 glitch       1
#   1 error        0


while( $line = <>) {
    chomp $line;

    if( $line =~ /^#/) {
	print "$line\n";
    } elsif( $line =~ /\w/) {
	my ($rec,$tyme,$data) = $line =~ /^(\w+)\s+(\d+) ns (\w+)/;
	my $idat = hex $data;
	my $type = ($idat >> 60) & 15;
	if( $type == 4) {

	    my $le_time = ($idat >> 22) & 0x3f;
	    my $le_phase = ($idat >> 20) & 3;
	    my $te_time = ($idat >> 14) & 0x3f;
	    my $te_phase = ($idat >> 12) & 3;
	    my $trig_num = ($idat >> 4) & 0xff;
	    my $buffer_num = ($idat >> 2) & 3;
	    my $glitch = ($idat >> 1) & 1;
	    my $error = $idat & 1;

	    printf "SIPM %6d LE: (%d, %d)  TE: (%d, %d) bufr: %d\n",
		$trig_num, $le_time, $le_phase, $te_time, $te_phase, $buffer_num;
		

	} elsif( $type == 2) {
	    my $dtime = ($idat >> 20) & 0xffffffff;
	    my $dphase = ($idat >> 18) & 3;
	    my $devn = $idat & 0x3ffff;
	    printf "TRIG %6d %8d %d\n",$devn, $dtime, $dphase;
	} else {
	    print "Unknown type!\n";
	}

    }
}
