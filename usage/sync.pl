#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::File;

# my $left = "/home1/irteam/backup/back-work-2020-02-12_15-22-08/www/survey_file_root";
# my $right = "/home1/irteam/work/www/survey_file_root";

my $left = "/home1/irteam/tmp/work-304";
my $right = "/home1/irteam/tmp/work-305";

my $file = Volken::File->new;
$file->unite($left, $right, 1);
