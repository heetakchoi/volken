#!/usr/bin/perl

use strict;
use warnings;

use MP3::Splitter;
use MP3::Tag;
use File::Copy qw(move);
use utf8;

sub opt;
sub trim;

my $mp3file;
my $album;

my $title;
my $artist;
my $time;
my @time_list = ();
my @infos = ();
my $separator = " - ";
my $title_artist_flag = 0;
my $represent_artist;

my $filename = shift;
$filename = "mp3info.txt" unless(defined($filename));

my $line_number = 0;
open(my $fh, "<", "mp3info.txt");
while(my $line = <$fh>){
    $line_number ++;
    chomp $line;
    $line =~ s/^\d+ //;
    if($line =~ m/^#/){
	next;
    }elsif($line =~ m/^Separator "([^"]+)"$/){
	$separator = $1;
    }elsif($line =~ m/^TitleFirstFlag (\d)$/){
	$title_artist_flag = $1;
    }elsif($line =~ m/^File (.+)$/){
	$mp3file = $1;
    }elsif($line =~ m/^Album (.+)$/){
	$album = $1;
    }elsif($line =~ m/^(\d+):(\d+)/){
	my $minute = $1;
	my $second = $2;
	my $hour = 0;
	if($line =~ m/^(\d+):(\d+):(\d+)/){
	    $hour = $1;
	    $minute = $2;
	    $second = $3;
	}
	my $current_time = 3600*$hour + 60*$minute + $second;
	my $separator_index = index($line, $separator);
	if($separator_index > 0){
	    my $left_start_index = index($line, " ");
	    my $current_artist = trim(substr($line, $left_start_index+1, $separator_index - $left_start_index -1));
	    my $current_title = trim(substr($line, $separator_index + length($separator)));
	    if($title_artist_flag){
		my $tmp = $current_title;
		$current_title = $current_artist;
		$current_artist = $tmp;
	    }
	    unless(defined($time)){
		$time = $current_time;
		$artist = $current_artist;
		$title = $current_title;
		next;
	    }
	    my $track = $#time_list +2;
	    my $filename = sprintf "%s. %s.mp3", $track, $title;
	    my $one_opt = opt(0, $filename);
	    my @one_pair = ($time, $current_time-$time, $one_opt);
	    push(@time_list, \@one_pair);

	    my $one_info = Info->new();
	    $one_info->set("title", $title);
	    $one_info->set("artist", $artist);
	    $one_info->set("filename", $filename);
	    $one_info->set("track", $track);
	    push(@infos, $one_info);
	    
	    $time = $current_time;
	    $artist = $current_artist;
	    $title = $current_title;
	}else{
	    my $track = $#time_list +2;
	    my $filename = sprintf "%s. %s.mp3", $track, $title;
	    my $one_opt = opt(1, $filename);
	    my @one_pair = ($time, $current_time - $time, $one_opt);
	    push(@time_list, \@one_pair);

	    my $one_info = Info->new();
	    $one_info->set("title", $title);
	    $one_info->set("artist", $artist);
	    $one_info->set("filename", $filename);
	    $one_info->set("track", $track);
	    push(@infos, $one_info);
	}
    }else{
	if(trim($line)){
	    printf "[ERR] %s\n", $line;
	}
    }
}
close($fh);

mp3split($mp3file, {verbose => 1}, @time_list );

foreach my $one_info (@infos){
    my $one_title = $one_info->get("title");
    my $one_artist = $one_info->get("artist");
    my $one_filename = $one_info->get("filename");
    my $one_track = $one_info->get("track");

    my $mp3 = MP3::Tag->new($one_filename);
    $mp3->get_tags();

    $mp3->new_tag("ID3v2");
    $mp3->title_set($one_title, 1);
    $mp3->artist_set($one_artist, 1);
    $mp3->album_set($album, 1);
    $mp3->track_set($one_track, 1);
    $mp3->{ID3v2}->write_tag;
    
    # my $id3v1 = $mp3->{ID3v1};
    # if(defined($id3v1)){
	
    # }else{
    # 	$id3v1 = $mp3->new_tag("ID3v1");
    # 	$mp3->{ID3v1} = $id3v1;
    # }
    # $id3v1->title($one_title);
    # $id3v1->artist($one_artist);
    # $id3v1->album($album);
    # $id3v1->track($one_track);
    # $id3v1->write_tag();
    
    $mp3->close();
}

sub opt{
    my ($last_flag, $mp3name) = @_;
    if($last_flag){
	return sub{ (lax=>10, mp3name=>$mp3name) };
    }else{
	return sub{ (mp3name=>$mp3name) };
    }
    
}
sub trim{
    my $value = shift;
    $value =~ s/^\s+|\s+$//;
    return $value;
}

{
    package Info;
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
	my ($self, $key, $neo_value) = @_;
	$self->{$key} = $neo_value;
    }
}
