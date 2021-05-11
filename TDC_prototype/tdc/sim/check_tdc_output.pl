#!/usr/bin/perl
#
# read text TDC output and check for hit-trigger times
#
use strict;
use Data::Dumper;

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
	push @trigs, $thing;
#	print "Save trigger: ", Dumper($thing);
    } elsif( $d[0] eq 'S') {
	$thing->{evn} = $d[7];
	$thing->{chan} = $d[2];
	push @hits, $thing;
#	print "Save hit: ", Dumper($thing);
    } else {
	print "WHAT? $line\n";
    }
}

my $ntrig = $#trigs+1;
my $nhits = $#hits+1;

print "$ntrig triggers, $nhits hits\n";

# for each trigger, find matching hits
foreach my $trig ( @trigs ) {
    my $tyme = $trig->{tyme};
    my $evn = $trig->{evn};
    print "T $tyme $evn: ";
    foreach my $hit ( @hits ) {
	if( $hit->{evn} eq $evn) {
	    my $hevn = $hit->{evn};
	    my $htim = $hit->{tyme};
	    my $chan = $hit->{chan};
	    my $diff = $tyme - $htim;
	    print " $diff";
#	    print "  $hevn $chan $htim $diff\n";
	}
    }
    print "\n";
}
