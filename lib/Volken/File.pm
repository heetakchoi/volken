package Volken::File;

use strict;
use warnings;

use File::Copy;

sub get_files;

sub new{
    my ($class) = @_;
    my $self = {};
    $self->{"check_count"} = 0;
    $self->{"copy_count"} = 0;
    bless($self, $class);
    return $self;
}
sub get_check_count{
    my ($self) = @_;
    return $self->{"check_count"};
}
sub get_copy_count{
    my ($self) = @_;
    return $self->{"copy_count"};
}
sub check{
	my ($self, $left, $right) = @_;
	$self->internal_sync($left, $right, "SIMULATION", "VERBOSE");
	return $self;
}
sub sync{
	my ($self, $left, $right) = @_;
	$self->internal_sync($left, $right, 0, 1);
}
sub sync_silent{
	my ($self, $left, $right) = @_;
	$self->internal_sync($left, $right, 0, 0);
}

sub internal_sync{
    my ($self, $left, $right, $flag_simulation, $flag_verbose) = @_;
	printf "left:  %s\nright: %s\n", $left, $right if($flag_verbose);
    # left 는 디렉토리라야 한다.
    unless(-d $left){
		print "[ERROR] sync failed. left must be a directory\n";
		return -1;
    }

	# right 가 없으면 만든다.
	unless(-e $right){
		mkdir $right;
	}
	# right 가 있으나 파일이면 종료한다.
	if(-f $right){
		print "[ERROR] sync failed. right must be a directory\n";
	}
	
    # left 가 가지고 있는 파일들을 순회하면서 right 가 동일 위치에 같은 이름이 있는지 확인한다.
    my @left_files = ();
    get_files(\@left_files, $left);

    my @right_files = ();
    get_files(\@right_files, $right);

    my %left_hash = map{$_=>1} @left_files;
    my %right_hash = map{$_=>1} @right_files;

    my $left_prefix_size = length($left);
    foreach my $from (keys %left_hash){
		my $to = sprintf "%s%s", $right, substr($from, $left_prefix_size);
		$self->{"check_count"} = $self->{"check_count"} +1;
		printf "[CHECK]              %s\n", $from if($flag_verbose);
		unless(-f $to){
			if($flag_simulation){
				printf "[FOUND-DISPLAY] FROM %s\n                TO   %s\n", $from, $to;
			}else{
				printf "[FOUND-COPY]    FROM %s\nTO               TO  %s\n", $from, $to;
				$self->copy_file($from, $to);
				$self->{"copy_count"} = $self->{"copy_count"} +1;
			}
		}
    }
    return $self;
}
sub get_files{
    my ($ref_files, $directory_name) = @_;
    $directory_name =~ s/ /\\ /g;
    my @candidates = glob sprintf "%s/*", $directory_name;
    foreach my $candidate (@candidates){
		if(-f $candidate){
			push(@{$ref_files}, $candidate);
		}elsif(-d $candidate){
			get_files($ref_files, $candidate);
		}
    }
}
sub copy_file{
    my ($self, $src, $dest) = @_;
    # src 가 파일인 경우만 지원한다.
    unless(-f $src){
		return -1;
    }
    my $dest_file = undef;
    my @dest_elements = split m/\//, $dest;

	$dest_file = pop(@dest_elements);

    # dest 의 위치를 상위에서부터 찾아 없으면 만든다.
    my $dest_location = "";
    foreach (@dest_elements){
		my $current_location = sprintf "%s/%s", $dest_location, $_;
		unless(-e $current_location){
			mkdir $current_location;
		}
		$dest_location = $current_location;
    }
    # 복사한다.
    return copy($src, sprintf "%s/%s", $dest_location, $dest_file);
}

return "Volken::File";
