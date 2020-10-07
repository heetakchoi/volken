package Volken::File;

use strict;
use warnings;

use File::Copy;

sub get_files;

sub new{
    my ($class) = @_;
    my $self = {};
    bless($self, $class);
    return $self;
}

sub unite{
    my ($self, $left, $right, $flag_simulation) = @_;
    # 양쪽 모두 디렉토리라야 한다.
    unless(-d $left and -d $right){
		return -1;
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
		unless(-f $to){
			printf "FROM [%s]\nTO   [%s]\n", $from, $to;
			unless($flag_simulation){
				$self->copy_file($from, $to);
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
    # dest 가 확장자를 가지면 파일로 간주한다.
    # dest 가 디렉토리이면 동일한 이름으로 복사한다.
    my $dest_file = undef;
    my @dest_elements = split m/\//, $dest;
    if($dest_elements[-1] =~ m/\./){
		$dest_file = pop(@dest_elements);
    }else{
		my @src_elements = split m/\//, $src;
		$dest_file = pop(@src_elements);
    }

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
