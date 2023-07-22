#!/usr/bin/perl
use strict;
use warnings;
use lib "../lib";
use Volken::ZN;
use Volken::PF;
use Volken::QN;
my @lefts = ("8/9", "-8/9");
my @rights = ("25/12", "-25/12");
foreach my $left (@lefts){
	foreach my $right (@rights){
		my $left_qn = Volken::QN->new($left);
		my $right_qn = Volken::QN->new($right);
		printf "%s %s\n", $left, $right;
		printf "%s + %s = %s\n", $left, $right, ($left_qn->plus($right_qn))->value;
		printf "%s - %s = %s\n", $left, $right, ($left_qn->minus($right_qn))->value;
		printf "%s * %s = %s\n", $left, $right, ($left_qn->multiply($right_qn))->value;
		printf "%s / %s = %s\n", $left, $right, ($left_qn->divide($right_qn))->value;
		print  "\n";
	}
}
my ($one) = ("-200/108");
my $one_qn = Volken::QN->new($one);
printf "%s is equivalent to %s\n", $one, $one_qn->shrink->get("rawdata");
