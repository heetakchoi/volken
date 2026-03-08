package Volken::Fanel;

use strict;
use warnings;

sub new{
    my ($class) = @_;
    my $self = {};
    bless($self, $class);
    return $self;
}

sub send_a_type{
    my ($self, $socket, $payload) = @_;
    my $payload_length = length($payload);
    my $packet = pack("A N A*", 'A', $payload_length, $payload);
    return syswrite($socket, $packet, length($packet));
}
sub send_b_type{
    my ($self, $socket, $payload_1, $payload_2) = @_;
    my $packet = pack("A N N A* A*",
		      'B',
		      length($payload_1),length($payload_2),
		      $payload_1, $payload_2);
    return syswrite($socket, $packet, length($packet));
}
sub send_c_type{
    my ($self, $socket, $payload_1, $payload_2, $payload_3) = @_;
    my $packet = pack("A N N N A* A* A*",
		      'C',
		      length($payload_1), length($payload_2), length($payload_3),
		      $payload_1, $payload_2, $payload_3);
    return syswrite($socket, $packet, length($packet));
}
sub receive_a_type{
    my ($self, $socket) = @_;
    my $buffer;
    my $bytes_read = sysread($socket, $buffer, 1+4);
    my ($type, $payload_length) = unpack("A N", $buffer);
    
    my $data_read = sysread($socket, $buffer, $payload_length);
    my $payload = $buffer;
    
    return $payload;
}
sub receive_b_type{
    my ($self, $socket) = @_;
    my $buffer;
    my $bytes_read = sysread($socket, $buffer, 1+4+4);
    my ($type, $payload_length_1, $payload_length_2) = unpack("A N N", $buffer);
    $bytes_read = sysread($socket, $buffer, $payload_length_1);
    my $payload_1 = $buffer;
    $bytes_read = sysread($socket, $buffer, $payload_length_2);
    my $payload_2 = $buffer;
    return ($payload_1, $payload_2);
}
sub receive_c_type{
    my ($self, $socket) = @_;
    my $buffer;
    my $bytes_read = sysread($socket, $buffer, 1+4+4+4);
    my ($type, $payload_length_1, $payload_length_2, $payload_length_3) = unpack("A N N N", $buffer);
    $bytes_read = sysread($socket, $buffer, $payload_length_1);
    my $payload_1 = $buffer;
    $bytes_read = sysread($socket, $buffer, $payload_length_2);
    my $payload_2 = $buffer;
    $bytes_read = sysread($socket, $buffer, $payload_length_3);
    my $payload_3 = $buffer;
    return ($payload_1, $payload_2, $payload_3);
}
return "Volken::Fanel";
