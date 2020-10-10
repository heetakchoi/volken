package Volken::QN;

use strict;
use warnings;

sub new{
	my ($class) = @_;
	my $self = {};
	bless($self, $class);
	return $self;
}
sub get{
	my ($self, $key) = @_;
	return $self->{$key};
}
sub set{
	my ($self, $key, $value) = @_;
	$self->{$key} = $value;
	return $self->{$key};
}

return "QN.pm";

