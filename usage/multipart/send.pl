#!/usr/bin/perl

use strict;
use warnings;

use lib "../../lib";
use Volken::Https;
use Volken::Part;

my $https = Volken::Https->new;
$https->host("google.com")->url("/search")
    ->header("host","www.google.com");

my $part1 = Volken::Part->new;
$part1->name("q")
    ->value("photo");
$https->add_part($part1);

# my $part2 = Volken::Part->new;
# $part2->name("file_name1")
#     ->filename("dare.txt")
#     ->filelocation("dare.txt");
# $http->add_part($part2);

# my $part3 = Volken::Part->new;
# $part3->name("file_name2")
#     ->filename("drug.jpg")
#     ->filelocation("drug.jpg");
# $http->add_part($part3);

print $https->multipart;
print "\n\n";
print $https->info();
