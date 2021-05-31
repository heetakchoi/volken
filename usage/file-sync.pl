#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::File;

# my $left = "s-from";
my $left = "s-from";
my $right = "s-to";

my $option = shift;
$option = "check" unless(defined($option));

my $file = Volken::File->new;
if("check" eq $option){
	$file->check($left, $right);
}elsif("sync" eq $option){
	$file->sync($left, $right);
}else{
	$file->sync_silent($left, $right);
}
printf "Copied %d in the %d files\n", $file->get_copy_count, $file->get_check_count;
