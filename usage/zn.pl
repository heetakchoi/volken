#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;

my ($left, $right, $result, $quotient, $remainder);

my @lefts = (102, 100003);
my @rights = (5, 25);

# my @flags = (1,1,1,1,1);
my @flags = (0,0,0,1,0);

if($flags[0]){
	print "#"x80;
	print "\nplus\n";
	foreach my $left_key ( @lefts ){
		foreach my $right_key ( @rights ){
			$left = Volken::ZN->new($left_key);
			$right = Volken::ZN->new($right_key);
			$result = $left->plus($right);
			if($result->value == $left->value + $right->value){
				printf "OK %s\n", $result->value;
			}else{
				printf "%s + %s = %s\n", $left->value, $right->value, $result->value;		
				printf "%s + %s = %s\n", $left->value, $right->value, $left->value + $right->value;
			}
		}
	}
}
if($flags[1]){
	print "#"x80;
	print "\nminus\n";
	foreach my $left_key ( @lefts ){
		foreach my $right_key ( @rights ){
			$left = Volken::ZN->new($left_key);
			$right = Volken::ZN->new($right_key);
			$result = $left->minus($right);
			if($result->value == $left->value - $right->value){
				printf "OK %s\n", $result->value;
			}else{
				printf "%s - %s = %s\n", $left->value, $right->value, $result->value;
				printf "%s - %s = %s\n", $left->value, $right->value, $left->value - $right->value;
			}
		}
	}
}
if($flags[2]){
	print "#"x80;
	print "\nmultiply\n";
	foreach my $left_key ( @lefts ){
		foreach my $right_key ( @rights ){
			$left = Volken::ZN->new($left_key);
			$right = Volken::ZN->new($right_key);
			$result = $left->multiply($right);
			if($result->value == $left->value * $right->value){
				printf "OK %s\n", $result->value;
			}else{
				printf "%s * %s = %s\n", $left->value, $right->value, $result->value;
				printf "%s * %s = %s\n", $left->value, $right->value, $left->value * $right->value;
			}
		}
	}
}
if($flags[3]){
	print "#"x80;
	print "\nquotient and remainder\n";
	foreach my $left_key ( @lefts ){
		foreach my $right_key ( @rights ){
			$left = Volken::ZN->new($left_key);
			$right = Volken::ZN->new($right_key);
			($quotient, $remainder) = $left->quotient_and_remainder($right);

			printf "A: %s = %s * %s + %s\n", $left->value, $right->value, $quotient->value, $remainder->value;
			# printf "B: %s = %s * %s + %s\n", $left->value, $right->value, int ($left->value / $right->value), $left->value % $right->value;

		}
	}
}
if($flags[4]){
	print "#"x80;
	print "\nETC.\n";

	$left = Volken::ZN->new("-123");
	$right = Volken::ZN->new("123");
	$result = $left->plus($right);
	if($result->value == $left->value + $right->value){
		printf "OK %s\n", $result->value;
	}else{
		printf "%s + %s = %s\n", $left->value, $right->value, $result->value;
		printf "%s + %s = %s\n", $left->value, $right->value, $left->value + $right->value;
	}
}
