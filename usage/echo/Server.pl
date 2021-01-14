#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
use threads;
use threads::shared;

use lib "../../lib";
use Volken::Prop;

sub echo;

$| = 1;

my $p = Volken::Prop->new("../../usage/echo/info.ini");
my ($local_port, $thread_limit, $delay) = ($p->get("local_port"), $p->get("thread_limit"), $p->get("delay"));
if($delay < 1){
    $delay = 0;
}

my $server_socket = new IO::Socket::INET (
    LocalHost => "0.0.0.0",
    LocalPort => $local_port,
    Proto => "tcp",
    Listen => 5,
    Reuse => 1
    );
die "[FATAL] Creation server socket failed $!\n" unless($server_socket);
printf "[INFO] Server socket waiting connection on %d\n", $local_port;

my $thread_size :shared = 0;

while(1){
    if($thread_size < $thread_limit){
		{
			lock($thread_size);
			$thread_size ++;
		}
		my $client_socket = $server_socket->accept();
		my $client_thread = threads->create(\&echo, $client_socket, $delay);
    }else{
		printf "[INFO] Thread size %d reaches Thread limit %d\n", $thread_size, $thread_limit;
		sleep(1);
    }
}

sub echo{
    my ($client_socket, $delay) = @_;
    my $data;
    while(1){
		$client_socket->recv($data, 1024);
		last if(length($data)<1);
		print "[INFO] Processing ...\n";
		if($delay > 0){
			sleep($delay);
		}
		printf "[INFO] Recv: %s\n", $data;
		$client_socket->send($data);
    }
    shutdown($client_socket, 2);
    $client_socket->close();
    
    threads->detach();
    {
		lock($thread_size);
		$thread_size --;
    }
}


