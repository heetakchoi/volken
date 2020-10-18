#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;
use Volken::PF;
use Volken::QN;

my ($left, $right) = ("8/9", "25/12");
my $left_qn = Volken::QN->new($left);
my $right_qn = Volken::QN->new($right);
printf "%s + %s = %s\n", $left, $right, ($left_qn->plus($right_qn))->reduce->get("rawdata"); #value;
printf "%s - %s = %s\n", $left, $right, ($left_qn->minus($right_qn))->reduce->get("rawdata"); #value;
printf "%s * %s = %s\n", $left, $right, ($left_qn->multiply($right_qn))->reduce->get("rawdata"); #value;
printf "%s / %s = %s\n", $left, $right, ($left_qn->divide($right_qn))->reduce->get("rawdata"); #value;

# my ($one) = ("200/108");
# my $one_qn = Volken::QN->new($one);
# printf "%s is equivalent to %s\n", $one, $one_qn->reduce->get("rawdata");



