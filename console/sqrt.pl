#!/usr/bin/perl

use strict;
use warnings;

my $N = $ARGV[0];
$N = 10 unless(defined($N));

my $an = $N/2;
my $try_num = 0;
while(1){
    $try_num ++;
    my $neo_an = ($an + $N/$an)/2;
    $an = $neo_an;
    last if(abs($an ** 2 - $N)<0.00001);
}
printf "N: %s, sqrt(N): %s, approximated: %s (%dth)\n",
    $N, sqrt($N), $an, $try_num;
