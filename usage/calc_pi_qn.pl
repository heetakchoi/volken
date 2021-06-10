#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::QN;
use Volken::PF;
use Volken::ZN;

# my $size = 10000;
my $size = 10;

my $odd_flag = 1;
my $quarter_pi = Volken::QN->new("0");
my $denominator = Volken::ZN->new("-1");
foreach my $index ( (0..($size-1)) ){
	$denominator = $denominator->plus(Volken::ZN->new("2"));
	my $current = Volken::QN->new("1")->divide(Volken::QN->new($denominator->value));
	if($odd_flag){
		$quarter_pi = $quarter_pi->plus($current);
		$odd_flag = 0;
	}else{
		$quarter_pi = $quarter_pi->minus($current);
		$odd_flag = 1;
	}
	printf "%4d: %s\n", $index, $quarter_pi->value;
}
