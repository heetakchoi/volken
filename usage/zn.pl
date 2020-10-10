#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;

my ($left, $right, $result);

print "#"x80;
print "\nplus\n";

$left = Volken::ZN->new("68");
$right = Volken::ZN->new("40");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("99");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("123");
$right = Volken::ZN->new("-99");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("-99");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("99");
$right = Volken::ZN->new("123");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-99");
$right = Volken::ZN->new("123");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("99");
$right = Volken::ZN->new("-123");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-99");
$right = Volken::ZN->new("-123");
$result = $left->plus($right);
printf "%s + %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

#
print "#"x80;
print "\nminus\n";

$left = Volken::ZN->new("123");
$right = Volken::ZN->new("99");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("99");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("123");
$right = Volken::ZN->new("-99");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("-99");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("99");
$right = Volken::ZN->new("123");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-99");
$right = Volken::ZN->new("123");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("99");
$right = Volken::ZN->new("-123");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

$left = Volken::ZN->new("-99");
$right = Volken::ZN->new("-123");
$result = $left->minus($right);
printf "%s - %s = %s\n", $left->rawdata, $right->rawdata, $result->value;

print "#"x80;
print "\nmultiply\n";

$left = Volken::ZN->new("123");
$right = Volken::ZN->new("99");
$result = $left->multiply($right);
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata * $right->rawdata;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("99");
$result = $left->multiply($right);
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata * $right->rawdata;

$left = Volken::ZN->new("123");
$right = Volken::ZN->new("-99");
$result = $left->multiply($right);
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata * $right->rawdata;

$left = Volken::ZN->new("-123");
$right = Volken::ZN->new("-99");
$result = $left->multiply($right);
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $result->value;
printf "%s * %s = %s\n", $left->rawdata, $right->rawdata, $left->rawdata * $right->rawdata;
