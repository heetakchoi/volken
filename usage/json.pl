#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Json;

my $http = Volken::Http->new;
$http->host("endofhope.com")
    ->url("/php/instagram10.php");
my $rawdata = $http->get;
my @lines = split( /\r\n/, $rawdata);

my $data = "";
my $flag = 1;
foreach my $line (@lines){
    if($flag){
	if(length($line) < 1){
	    $flag = 0;
	}
    }else{
	$data .= sprintf "%s\n", $line;
    }
}
my $json_txt = $data;
my @pictures = ();
my @captions = ();
my @ymds = ();

my $json = Volken::Json->new;
$json->load_text($json_txt);
my $init_node = $json->parse;
my $next_url = $init_node->get("pagination")->get("next_url");
my @data = $init_node->get("data")->array_gets();
foreach (@data){
    printf "%s\n", $_->get("images")->get("standard_resolution")->get("url")->value;
}
