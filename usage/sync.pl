#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::File;

my $left = "/home/endofhope/home/tmp/1";
my $right = "/home/endofhope/home/tmp/3";

my $file = Volken::File->new;
$file->unite($left, $right);
