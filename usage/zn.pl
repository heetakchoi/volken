#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;

my ($left, $right, $result);
my @lefts = ("7");
my @rights = ("5");
# my @lefts = ("123", "-123");
# my @rights = ("99", "-99");
# my @lefts = (-10..10);
# my @rights = (-5..5);
################################################################################
# print "#"x80;
# print "\nplus\n";
# foreach my $left_key ( @lefts ){
# 	foreach my $right_key ( @rights ){
# 		$left = Volken::ZN->new($left_key);
# 		$right = Volken::ZN->new($right_key);
# 		$result = $left->plus($right);
# 		if($result->value == $left->rawdata + $right->rawdata){
# 			printf "OK %s\n", $result->value;
# 		}else{
# 			printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;		
# 			printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata + $right->rawdata;
# 		}
# 	}
# }
################################################################################
print "#"x80;
print "\nminus\n";
foreach my $left_key ( @lefts ){
	foreach my $right_key ( @rights ){
		$left = Volken::ZN->new($left_key);
		$right = Volken::ZN->new($right_key);
		$result = $left->minus($right);
		if($result->value == $left->rawdata - $right->rawdata){
			printf "OK %s\n", $result->value;
		}else{
			printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
			printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata - $right->rawdata;
		}
	}
}
################################################################################
# print "#"x80;
# print "\nmultiply\n";
# foreach my $left_key ( @lefts ){
# 	foreach my $right_key ( @rights ){
# 		$left = Volken::ZN->new($left_key);
# 		$right = Volken::ZN->new($right_key);
# 		$result = $left->multiply($right);
# 		if($result->value == $left->rawdata * $right->rawdata){
# 			printf "OK %s\n", $result->value;
# 		}else{
# 			printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
# 			printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata * $right->rawdata;
# 		}
# 	}
# }
################################################################################
# print "#"x80;
# print "\nETC.\n";

# $left = Volken::ZN->new("-123");
# $right = Volken::ZN->new("123");
# $result = $left->plus($right);
# if($result->value == $left->rawdata + $right->rawdata){
# 	printf "OK %s\n", $result->value;
# }else{
# 	printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
# 	printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata + $right->rawdata;
# }
