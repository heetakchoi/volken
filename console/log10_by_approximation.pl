#!/usr/bin/perl

use strict;
use warnings;

my $N = $ARGV[0];
$N = 2 unless(defined($N));

my %hash = (10=>1,
	    3.16228=>2,
	    1.77828=>4,
	    1.33352=>8,
	    1.15478=>16,
	    1.074607=>32,
	    1.036633=>64,
	    1.018152=>128,
	    1.009035=>256,
	    1.0045073=>512,
	    1.0022511=>1024);

my $current = $N;
my @powers = ();
my @indices = ();

foreach my $onepower (sort {$b<=>$a} keys %hash){
    my $index = $hash{$onepower};
    if($current >= $onepower){
	push(@powers, $onepower);
	push(@indices, 1/$index);
	$current /= $onepower;
    }
}
push(@indices, ($current - 1)/2.3025);
my $result = 0;
foreach (@indices){
    $result += $_;
}
printf "clog %s = %s\n", $N, $result;
