package Volken::Util;

use strict;
use warnings;

use POSIX "strftime";

sub new{
	my ($class) = @_;
	my $self = {};
	bless($self, $class);
	return $self;
}

sub pretty_time{
    my ($self, $raw_time) = @_;
	$raw_time = time unless(defined($raw_time));
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($raw_time);
    my $apm = "오전";
    if($hour > 12){
		$apm = "오후";
		$hour -= 12; 
    }
    return sprintf "%4d년 %2d월%2d일 %s %2d시 %2d분 %2d초", $year+1900, $mon+1, $mday, $apm, $hour, $min, $sec;
}

return "Util.pm";

