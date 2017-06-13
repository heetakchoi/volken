#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
# use Volken::Https;

sub test_Http;
# sub test_Https;

test_Http;

sub test_Https{
    my $https = Volken::Https->new;
    $https->host("play.google.com")
	->url("/store/apps/details")
	->param("id", "com.campmobile.launcher");
    print $https->post;
}
sub test_Http{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    print $http->post;
}
