#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Prob;

my $prob = Volken::Prob->new;
my @cases = $prob->nCr(2, (1, 2, 3));
foreach my $case (@cases){
    printf "%s\n", join(" ", @$case);
}
