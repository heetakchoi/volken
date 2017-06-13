#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use lib "../lib";
use Volken::Http;
use Volken::Https;

binmode(STDIN,  ":encoding(cp949)");
binmode(STDOUT, ":encoding(cp949)");

sub test_Http;
sub test_Https;

my $result = test_Http;
# my $result = test_Https;

print decode("utf-8", $result);

sub test_Https{
    my $https = Volken::Https->new;
    $https->host("play.google.com")
		->url("/store/apps/details")
		->param("id", "com.campmobile.launcher");
    return $https->post;
}
sub test_Http{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    return $http->post;
}
