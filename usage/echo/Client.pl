#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;

use lib "../../lib";
use Volken::Prop;

$| = 1;

my $p = Volken::Prop->new("../../usage/echo/info.ini");
my ($peer_host, $peer_port) = ($p->get("peer_host"), $p->get("peer_port"));

# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => $peer_host,
    PeerPort => $peer_port,
    Proto => "tcp"
    );
die "[FATAL] Connection failed $!\n" unless($socket);
printf "[INFO] Connect on %s:%d\n", $peer_host, $peer_port;
print "Write something to Echo server\n";
my $line = readline();
chomp($line);
my $size = $socket->send($line);
shutdown($socket, 1);

my $response = "";
$socket->recv($response, 1024);
printf "received: %s\n", $response;

shutdown($socket, 2);
$socket->close();
