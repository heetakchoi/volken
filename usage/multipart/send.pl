#!/usr/bin/perl

use strict;
use warnings;

use lib "../../lib";
use Volken::Https;
use Volken::Part;

my $https = Volken::Https->new;
$https->host("HOST")->url("URL");

my $part1 = Volken::Part->new;
$part1->name("upload")->filename("drug.jpg")->filelocation("drug.jpg");
$https->add_part($part1);

# my $part2 = Volken::Part->new;
# $part2->name("somebody")->value("someone");
# $https->add_part($part2);

# my $part3 = Volken::Part->new;
# $part3->name("submit")->value("upload");
# $https->add_part($part3);

# $https->emulate_flag(1);
print $https->multipart;
print "\n\n";
print $https->info();
