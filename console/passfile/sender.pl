#!/usr/bin/perl

use strict;
use warnings;

use lib "../../lib";
use Volken::Prop;

use IO::Socket::INET;

unless(-e "info_send.ini"){
    print "File not found. create send_info.ini as\n";
    print "host [server host]\nport [server port]\nfile_location [file_location]\n";
    die;
}
my $prop = Volken::Prop->new("info_send.ini", " ");
my ($host, $port, $file_location_string) = $prop->gets("host", "port", "file_location");

my @file_location_list = split(/,/, $file_location_string);
foreach my $file_location (@file_location_list){
    my $file_size = -s $file_location;
    my $last_index_of_slash = rindex($file_location, "/");
    my $file_name = $file_location;
    if($last_index_of_slash > 0){
	$file_name = substr($file_location, $last_index_of_slash+1);
    }
    printf "Proessing [%s] (%d) start\n", $file_name, $file_size;
    open(my $input_stream, '<:raw', $file_location);
    my $socket = IO::Socket::INET->new(
	PeerAddr => $host,
	PeerPort => $port,
	Proto => "tcp"
	);
    print $socket "$file_name\n$file_size\n";
    my $sending_count = 0;
    while(read($input_stream, my $buffer, 1024)){
	print $socket $buffer;
	$sending_count ++;
	if($sending_count % 100_000 == 0){
	    printf "sending %dM\n", $sending_count/1_000;
	}
    }
    close($socket);
    close($input_stream);
    printf "End %s\n", $file_name;
}



