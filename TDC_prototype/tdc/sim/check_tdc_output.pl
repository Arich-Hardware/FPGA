#!/usr/bin/perl
#
# read text TDC output and check for hit-trigger times
#
use strict;
use Data::Dumper;

my $cdt = 35;			# countdown time constant

# fancy way to return list of unique values from list from perlmaven.com
sub uniq {
    my %seen;
    return grep { !$seen{$_}++ } @+;
}

#
# collect triggers in a list, and hits in another one
#
my @trigs;
my @hits;

while( my $line = <>) {
    chomp $line;
    my @d = split ' ', $line;
    my $thing = { tyme => $d[1]};
    if( $d[0] eq 'T') {
	$thing->{evn} = $d[4];
	$thing->{ttime} = $d[2];
	push @trigs, $thing;
    } elsif( $d[0] eq 'S') {
	$thing->{evn} = $d[7];
	$thing->{chan} = $d[2];
	$thing->{let} = $d[3];	# leading edge time
	$thing->{lep} = $d[4];	# leading edge phase
	$thing->{tet} = $d[5];	# trailing edge time
	$thing->{tep} = $d[6];	# trailing edge phase
	push @hits, $thing;
    } else {
	print "WHAT? $line\n";
    }
}

my $ntrig = $#trigs+1;
my $nhits = $#hits+1;

print "$ntrig triggers, $nhits hits\n";

# for each trigger, find matching hits
foreach my $trig ( @trigs ) {
    my $ttime = $trig->{ttime};
    my $tyme = $trig->{tyme};
    my $evn = $trig->{evn};
    print "T $evn $ttime:\n";
    foreach my $hit ( @hits ) {
	if( $hit->{evn} eq $evn) {
	    my $chan = $hit->{chan};
	    my $ttime = $ttime - $hit->{let};
	    print " ($chan $ttime)\n";

	}
    }
    print "\n";
}
