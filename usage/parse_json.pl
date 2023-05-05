#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Json;

my $json = Volken::Json->new;
$json->load_file("data.json");
my $init_node = $json->parse;
my @data = $init_node
    ->get("data")
    ->gets();
foreach (@data){
    printf "%s\n", $_->get("images")
	->get("standard_resolution")
	->get("url")
	->value;
}
