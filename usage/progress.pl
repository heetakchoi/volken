#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Util;
use Volken::Progress;

my $util = Volken::Util->new;
my $file = $ARGV[0];
unless(defined($file) and -e $file){
    die "Usage: perl progress.pl [file]\n";
}

printf "Estimating line count of %s ...\n", $file;
my $progress = Volken::Progress->new($file);
printf "Total count: %s\n", $util->commify($progress->get("total"));
print  "processing...\n";
open(my $fh, "<", $file);
my $line_number = 0;
while(my $line=<$fh>){
    $progress->proceed();
    chomp($line);

    if($progress->checked()){
	print $progress->show(1);
    }
}
close($fh);
print $progress->end();

