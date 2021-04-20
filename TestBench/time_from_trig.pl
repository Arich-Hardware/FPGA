#!/usr/bin/perl
# look at TDC input data, find hits which should  match a trigger

use strict;

my $debug = 0;

my $win_before = 100;		# default time before trigger in ns
my $win_after = 0;		# default time after trigger in ns

my $narg = $#ARGV + 1;
if( $narg < 1) {
    print "usage: $0 <input_file> [<begin> <end>}\n";
    print "   <begin> is time before trigger in ns (default: 100)\n";
    print "   <end>   is time after trigger in ns (default: 0)\n";
    exit;
}

if( $narg == 3) {
    $win_before = $ARGV[1];
    $win_after = $ARGV[2];
}

print "Search window from T-$win_before to T+$win_after\n";

my $infile = $ARGV[0];
open FIN, "< $infile" or die "Opening $infile: $!";

my $ntrig = 0;			# count triggers
my $nhit = 0;			# count hits
my $nmatch = 0;			# count matches

my $last_time = 0;		# remember last time
my $file_line = 1;		# count input file lines

my @triggers;			# array to store triggers in order
my @hits;

while( my $line = <FIN>) {
    chomp $line;		# clean trailing newlines
    if( $line =~ /^S/) {	# SiPM hit
	++$nhit;
	my ($time, $chan, $wid) = $line =~ /S\s([0-9.]*)\s(\d*)\s([0-9.]*)$/;
	print "Hit: at $time channel $chan width $wid\n" if($debug);
	# store hits
	push @hits, { time => $time,
		      chan => $chan,
		      wid => $wid,
		      line => $file_line,
		      nmatch => 0};
	$last_time = $time;
    } elsif( $line =~ /^T/) {	# trigger
	my ($time) = $line =~ /T\s([0-9.]*)$/;
	print "Trigger at $time\n" if( $debug);
	# store triggers
	push @triggers, { time => $time, 
			  line => $file_line,
			  tstart => $time - $win_before, 
			  tend => $time + $win_after,
			  nmatch => 0};
	$last_time = $time;
	++$ntrig;
    } elsif( $line =~ /^#/) {	# comment

    } else {
	print "Bad input data in $line\n";
    }
    ++$file_line;
}

# look for matches very inefficiently!

foreach my $trig ( @triggers ) {
    foreach my $hit ( @hits) {
	my $delta_t = sprintf "%5.1f ns", $hit->{time} - $trig->{time};
	if( $hit->{time} >= $trig->{tstart} && $hit->{time} <= $trig->{tend}) {
	    print "Hit at $hit->{time} (L$hit->{line})",
		" matches trigger at $trig->{time} (L$trig->{line})",
		" (dt=$delta_t)\n";
	    if( $hit->{nmatch}) {
		print "   (duplicate)\n";
	    } else {
		$hit->{nmatch}++;
	    }
	    $trig->{nmatch}++;
	    ++$nmatch;
	}
    }
    print "Trigger at $trig->{time} matched $trig->{nmatch} hits\n"
	if( !$trig->{nmatch} || $trig->{nmatch} > 1);
}


print "Processed $ntrig triggers, $nhit hits in $last_time ns\n";
my $trig_rate = $ntrig / ($last_time*1e-9);
my $hit_rate = $nhit / ($last_time*1e-9);
print "     Trigger rate: " . nice_rate( $trig_rate) . "\n";
print "Hit rate (all ch): " . nice_rate( $hit_rate) . "\n";
print "Number of matches: $nmatch\n";

#
# format a rate as Hz, MHz etc nicely given a rate in Hz
#
sub nice_rate {
    my $hz = shift @_;
    my $fmt = "%8.2f";		# generic format
    my $str = "";
    if( $hz < 1000) {
	$str = sprintf $fmt . " Hz", $hz;
    } elsif( $hz < 1e6) {
	$str = sprintf $fmt . " kHz", $hz/1000;
    } elsif( $hz < 1e9) {
	$str = sprintf $fmt . " MHz", $hz/1e6;
    } elsif( $hz < 1e12) {
	$str = sprintf $fmt . " GHz", $hz/1e6;
    } else {
	$str = sprintf "%g Hz", $hz;
    }
    return $str;
}

