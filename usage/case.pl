#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Cases;

my $cases = Volken::Cases->new((1, 2, 3));
my @result_cases = $cases->nCr(2);
foreach my $result_case (@result_cases){
    printf "%s\n", join(" ", @$result_case);
}

print "\n===\n";
@result_cases = $cases->nCr(2, (1, 2, 3, 4));
foreach my $result_case (@result_cases){
    printf "%s\n", join(" ", @$result_case);
}


