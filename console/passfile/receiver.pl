#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;

use lib "../../lib";
use Volken::Prop;

unless(-e "receive_info.ini"){
    print "File not found. create receive_info.ini as\n";
    print "port [listening port]\nlocation [file saved directory]\n";
    die;
}
my $prop = Volken::Prop->new("receive_info.ini", " ");
my ($port, $location) = $prop->gets("port", "location");

my $server_socket = IO::Socket::INET->new(
    LocalPort => $port,
    Type => SOCK_STREAM,
    Listen => 5,
    Reuse => 1
    );

while(1){
    my $client_socket = $server_socket->accept();
    
    my $pid = fork();
    if($pid == 0){
	
	my $file_name = <$client_socket>;
	chomp($file_name);
	my $file_location = sprintf "%s/%s", $location, $file_name;
	my $file_size = <$client_socket>;
	chomp($file_size);
	printf "Processing [%s] (%d)\n", $file_name, $file_size;

	open(my $output_stream, ">:raw", $file_location);
	my $received_size = 0;
	my $receiving_count = 0;
	while($received_size < $file_size){
	    my $bytes_to_read = ($file_size - $received_size)>1024 ? 1024 : ($file_size - $received_size);
	    my $bytes_read = read($client_socket, my $buffer, $bytes_to_read);
	    last unless $bytes_read;
	    print $output_stream $buffer;
	    $received_size += $bytes_read;

	    $receiving_count ++;
	    if($receiving_count % 10_000 == 0){
		printf "receiving %dM\n", $received_size/1_024_000;
	    }
	}
	close($output_stream);
	close($client_socket);
	printf "End %s\n", $file_name;
    }
}
