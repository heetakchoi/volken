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

sub pretty_kr_datetime{
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

sub sec_to_hms{
    my ($self, $seconds) = @_;

    my $hours = 0;
    if($seconds >= 60 * 60){
        $hours = int($seconds / (60 * 60));
        $seconds = $seconds - $hours * (60 * 60);
    }
    my $minutes = 0;
    if($seconds >= 60){
        $minutes = int($seconds / 60);
        $seconds = $seconds - $minutes * 60;
    }
    return ($hours, $minutes, $seconds);
}

sub percent_decode{
    my ($self, $from) = @_;
    my %hash = (
	"%20"=>" " , "%21"=>"!" , "%22"=>"\"", "%23"=>"#" , "%24"=>"\$",
	"%25"=>"%" , "%26"=>"&" , "%27"=>"'" , "%28"=>"(" , "%29"=>")" ,
	"%2A"=>"*" , "%2B"=>"+" , "%2C"=>"," , "%2D"=>"-" , "%2E"=>"." , "%2F"=>"/" , 
	"%3A"=>":" , "%3B"=>";" , "%3C"=>"<" , "%3D"=>"=" , "%3E"=>">" , "%3F"=>"?" , 
	"%40"=>"@" , 
	"%5B"=>"[" , "%5C"=>"\\", "%5D"=>"]" , "%5E"=>"^" , "%5F"=>"_" ,
	"%60"=>"`" ,
	"%7B"=>"{" , "%7C"=>"|" , "%7D"=>"}" , "%7E"=>"~" ,
	);
    return $hash{$from};
}

sub trim{
    my ($self, $data) = @_;
    $data =~ s/^\s+|\s+$//g;
    return $data;
}

return "Util.pm";

