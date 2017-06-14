#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use lib "../lib";
use Volken::Http;
use Volken::Https;

sub test_Https_emulated_post;
sub test_Https_post;
sub test_Https_emulated_get;
sub test_Https_get;
sub test_Http_emulated_post;
sub test_Http_post;
sub test_Http_emulated_get;
sub test_Http_get;

binmode(STDIN,  ":encoding(cp949)");
binmode(STDOUT, ":encoding(cp949)");

my $result = "";
$result = test_Https_emulated_post;
# $result = test_Https_post;
# $result = test_Https_emulated_get;
# $result = test_Https_get;
# $result = test_Http_emulated_post;
# $result = test_Http_post;
# $result = test_Http_emulated_get;
# $result = test_Http_get;
print decode("utf-8", $result);

sub test_Https_emulated_post{
    my $https = Volken::Https->new;
    $https->host("developers.band.us")
	->url("/develop/guide/api/get_user_information")
	->param("lang", "ko");
    $https->emulate_flag(1);
    $https->post;
    return $https->raw_request;
}
sub test_Https_post{
    my $https = Volken::Https->new;
    $https->host("developers.band.us")
	->url("/develop/guide/api/get_user_information")
	->param("lang", "ko");
    return $https->post;
}
sub test_Https_emulated_get{
    my $https = Volken::Https->new;
    $https->host("developers.band.us")
	->url("/develop/guide/api/get_user_information")
	->param("lang", "ko");
    $https->emulate_flag(1);
    $https->get;
    return $https->raw_request;
}
sub test_Https_get{
    my $https = Volken::Https->new;
    $https->host("developers.band.us")
	->url("/develop/guide/api/get_user_information")
	->param("lang", "ko");
    return $https->get;
}

sub test_Http_emulated_post{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    $http->emulate_flag(1);
    $http->post;
    return $http->raw_request;
}
sub test_Http_post{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    return $http->post;
}
sub test_Http_emulated_get{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    $http->emulate_flag(1);
    $http->get;
    return $http->raw_request;
}
sub test_Http_get{
    my $http = Volken::Http->new;
    $http->host("endofhope.com")
	->url("/info.cgi")
	->param("a a", "A A")
	->param("한 글", "한한 글글");
    return $http->get;
}
