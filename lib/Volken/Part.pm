package Volken::Part;

use strict;
use warnings;

sub new{
    my ($class) = @_;
    my $self = {};
    bless($self, $class);
    return $self;
}
sub name{
    my ($self, $neo) = @_;
    $self->{"name"} = $neo;
    return $self;
}
sub filename{
    my ($self, $neo) = @_;
    $self->{"filename"} = $neo;
    return $self;
}
sub filelocation{
    my ($self, $neo) = @_;
    $self->{"filelocation"} = $neo;
    return $self;
}
sub value{
    my ($self, $neo) = @_;
    $self->{"value"} = $neo;
    return $self;
}
sub get{
    my ($self, $key) = @_;
    return $self->{$key};
}

sub build{
    my ($self, $boundary) = @_;
    my $header;
    my $first_line = sprintf "\r\n--%s", $boundary;
    my $size;
    my $name = $self->{"name"};
    my $filename = $self->{"filename"};
    if(not defined($name) or not $name){
	$self->{"type"} = "LAST";
	$header = sprintf "%s--\r\n", $first_line;
	$size = length($header);
    }elsif(not defined($filename) or not $filename){
	$self->{"type"} = "VALUE";
	$header = sprintf "%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n", $first_line, $self->{"name"};
	$size = length($header) + length($self->{"value"});
    }else{
	$self->{"type"} = "FILE";
	my $filename = $self->{"filename"};
	my $ext = substr($filename, index($filename, ".")+1);
	my $second_line = sprintf "Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"",
	    $self->{"name"}, $self->{"filename"};
	if("jpg" eq $ext or "jpeg" eq $ext or "JPG" eq $ext or "JPEG" eq $ext){
	    $header = sprintf "%s\r\n%s\r\nContent-Type: image/jpeg\r\n\r\n", $first_line, $second_line;
	}elsif("gif" eq $ext or "GIF" eq $ext){
	    $header = sprintf "%s\r\n%s\r\nContent-Type: image/gif\r\n\r\n", $first_line, $second_line;
	}elsif("txt" eq $ext or "TXT" eq $ext){
	    $header = sprintf "%s\r\n%s\r\nContent-Type: text/plain\r\n\r\n", $first_line, $second_line;
	}
	$size = length($header) + (-s $self->{"filelocation"});
    }
    $self->{"header"} = $header;
    $self->{"size"} = $size;
    return $self;
}

return "Part.pm";

