#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;
use Volken::PF;
use Volken::QN;

my ($left, $right) = ("2/9", "1/4");
my $left_qn = Volken::QN->new($left);
my $right_qn = Volken::QN->new($right);
printf "%s + %s = %s\n", $left, $right, ($left_qn->plus($right_qn))->get("rawdata");
printf "%s - %s = %s\n", $left, $right, ($left_qn->minus($right_qn))->get("rawdata");
printf "%s * %s = %s\n", $left, $right, ($left_qn->multiply($right_qn))->get("rawdata");
printf "%s / %s = %s\n", $left, $right, ($left_qn->divide($right_qn))->get("rawdata");

my ($one) = ("6/9");
my $one_qn = Volken::QN->new($one);
printf "%s is equals %s\n", $one, $one_qn->reduce->get("rawdata");



