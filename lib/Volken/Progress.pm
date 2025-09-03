package Volken::Progress;

use strict;
use warnings;

sub new{
    my ($class, $file_location, $granularity_min_size, $granularity_count) = @_;
    die "존재하지 않는 파일" unless(-e $file_location);

    my $total = `wc -l < $file_location`;
    chomp($total);
    $granularity_min_size = 1_000_000 unless(defined($granularity_min_size));
    $granularity_count = 30 unless(defined($granularity_count));

    my $self = {};
    $self->{"util"} = Volken::Util->new();
    $self->{"total"} = $total;
    $self->{"granularity_min_size"} = $granularity_min_size;
    $self->{"granularity_count"} = $granularity_count;
    my $check_size = $total / $granularity_count;
    $check_size = $granularity_min_size if($check_size > $granularity_min_size);
    $self->{"check_size"} = $check_size;
    my $display_flag = 1;
    $display_flag = 0 if($total<$granularity_min_size);
    $self->{"display_flag"} = $display_flag;
    $self->{"line_number"} = 0;
    
    bless($self, $class);
    return $self;
}
sub get{
    my ($self, $name) = @_;
    return $self->{$name};
}
sub proceed{
    my ($self) = @_;
    $self->{"line_number"} += 1;
    return $self->{"line_number"};
}
sub checked{
    my ($self) = @_;
    if($self->{"display_flag"}){
	return ($self->{"line_number"} % $self->{"check_size"} == 0);
    }else{
	return 0;
    }
}
sub show{
    my ($self, $same_location) = @_;
    my $util = $self->{"util"};
    my $line_number = $self->{"line_number"};
    my $total = $self->{"total"};
    my $result = sprintf "%.1f%% processed. (%s/%s)\n",
            100 * $line_number / $total,
	    $util->commify($line_number), $util->commify($total);
    if($same_location){
	$result = "\e[1A\e[2K\r".$result;
    }
    return $result;
}
sub end{
    my ($self) = @_;
    my $util = $self->{"util"};
    return sprintf "\e[1A\e[2K\rProcess established. (%s/%s)\n",
	$util->commify($self->{"line_number"}),
	$util->commify($self->{"total"});
}

return "Progress.pm";

