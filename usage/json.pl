#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Json;

sub pretty;

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

my $json = Volken::Json->new;
$json->load_text($json_txt);
my $init_node = $json->parse;
pretty($init_node, "  ");

# my $next_url = $init_node->get("pagination")->get("next_url");
# my @data = $init_node->get("data")->array_gets();
# foreach (@data){
#     printf "%s\n", $_->get("images")->get("standard_resolution")->get("url")->value;
# }

sub pretty{
    my ($node, $unit_indent) = @_;
    printf "%sType: %s", $unit_indent x $node->indent, $node->type;
    if($node->type eq "object"){
    	foreach ($node->object_keys){
    	    print "\n";
	    printf "%sobj_key: %s\n", $unit_indent x $node->indent, $_;
    	    pretty($node->object_get($_), $unit_indent);
    	}
    }elsif($node->type eq "array"){
    	foreach ($node->array_gets){
    	    print "\n";
    	    pretty($_, $unit_indent);
    	}
    }elsif($node->type eq "normal"){
    	print "\n";
    	printf "%scontent: %s\n", $unit_indent x $node->indent, $node->value;
    }
}
