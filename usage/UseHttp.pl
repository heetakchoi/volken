#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Https;

sub test_Http;
sub test_Https;

test_Https;

sub test_Https{
    my $https = Volken::Https->new;
    $https->host("github.com")
	->url("/heetakchoi");
    # print $http->get;
    # print $http->post;
    print $https->get;
    # print $https->info;
}
sub test_Http{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->port(80)
	->url("/info.cgi")
	->param("a", "a_value")
	->param("bb", "bvalue");
    # print $http->get;
    # print $http->post;
    $http->get;
    print $http->info;
}
