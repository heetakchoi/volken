#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Json;

my $access_token = "716258467.0b1a9bf.f11f27ca244045559fd2238ded884b67";
my $count = 19;

my $http = Volken::Http->new;
$http->host("endofhope.com")
    ->url("/php/instagram.php")
	->param("access_token", $access_token)
	->param("count", $count);
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

printf "==\n%s\n==\n", $json_txt;

my $json = Volken::Json->new;
$json->load_text($json_txt);
my $init_node = $json->parse;
print $init_node->info;
