#!/usr/bin/perl

use strict;
use warnings;

my $size = 10;

my $odd_flag = 1;
my $quarter_pi = 0;
foreach my $index ( (0..($size-1)) ){
    my $current = 1/(2*$index+1);
    if($odd_flag){
	$quarter_pi += $current;
	$odd_flag = 0;
    }else{
	$quarter_pi -= $current;
	$odd_flag = 1;
    }
    printf "%4d: %s\n", $index, $quarter_pi*4;
}
