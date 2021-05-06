#!/usr/bin/perl
#
# generate pulses sweeping past trigger window for TDC behavior study
#
# output format;
# S <time> <channel> <width>
# T <time>

my $trigger_spacing = 200;	# trigger spacing in ns
my $early_time = -140;		# early pulse time WRT trigger
my $late_time = 20;		# late pulse time WRT trigger
my $time_step = 4;		# time step in ns

my $nsteps = int($late_time - $early_time / $time_step);
my $sim_time = ($nsteps+1) * $trigger_spacing;

my $width = 20;			# fixed width for now

 print "# Sweep pulse from $early_time to $late_time in steps of $time_step\n";
 print "# Number of steps: $nsteps  Simulation total time: $sim_time (all ns)\n";

my $trig_time = 200;		# start at 200ns

for( my $dt=$early_time; $dt <= $late_time; $dt += $time_step) {
    my $pulse_time = $trig_time + $dt;
    print "# Trigger at: $trig_time delta-t: $dt  pulse time: $pulse_time\n";

    my $pulse_fmt = sprintf "S %8.1f %d %6.1f\n", $pulse_time, 0, $width;
    my $trig_fmt = sprintf "T %8.2f\n", $trig_time;

    if( $pulse_time < $trig_time) {
	print $pulse_fmt, $trig_fmt;
    } else {
	print $trig_fmt, $pulse_fmt;
    }	

    $trig_time += $trigger_spacing;
}
