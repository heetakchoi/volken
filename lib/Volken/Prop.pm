package Volken::Prop;

use strict;
use warnings;

sub trim;

sub new{
    my ($class, $loc) = @_;
    my $self = {};
    $self->{"data"} = {};
    open(my $fh, "<", $loc);
    while(my $line=<$fh>){
	$line = trim($line);
	if($line =~ m/^#/ or length($line) < 1){
	}else{
	    my @units = split /:/, $line;
	    if(scalar @units > 1){
		$self->{"data"}->{trim($units[0])} = trim($units[1]);
	    }
	}
    }
    close($fh);
    bless($self, $class);
    return $self;
}
sub get{
    my ($self, $name) = @_;
    return $self->{"data"}->{$name};
}
sub keys{
    my ($self) = @_;
    return keys %{$self->{"data"}};
}

sub trim{
    my ($str) = @_;
    $str =~ s/^(\s*)//;
    $str =~ s/(\s*)$//;
    return $str;
}
return "Volken::Prop";
