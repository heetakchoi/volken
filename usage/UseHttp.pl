#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;

sub test_Http;

test_Http;

sub test_Http{
	my $http = Volken::Http->new;
	$http->host("endofhope.com")
		->port(80)
		->url("/info.cgi")
		->param("a", "a_value")
		->param("bb", "bvalue");
	# print $http->get;
	print $http->post;
	# print $http->info;
}
