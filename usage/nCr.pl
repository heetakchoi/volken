#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::NumberOfCases;

my $noc = Volken::NumberOfCases->new((1, 2, 3));
my @result_cases = $noc->nCr(2);
foreach my $result_case (@result_cases){
    printf "%s\n", join(" ", @$result_case);
}
print "===\n";
@result_cases = $noc->nCr(2, (1, 2, 3, 4));
foreach my $result_case (@result_cases){
    printf "%s\n", join(" ", @$result_case);
}


