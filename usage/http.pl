#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Https;

sub test_Http;
sub test_Https;

test_Http;

sub test_Https{
# https://play.google.com/store/apps/details?id=com.campmobile.launcher
    my $https = Volken::Https->new;
    $https->host("play.google.com")
	->url("/store/apps/details")
	->param("id", "com.campmobile.launcher");
    # print $http->get;
    # print $http->post;
    print $https->post;
    # print $https->info;

}
sub test_Http{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/php/instagram10.php");
    # print $http->get;
    # print $http->post;
    print $http->get;
    # print $http->info;
}
