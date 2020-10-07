#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Util;

sub command_synonym;
sub proc_quit;
sub proc_time;
sub proc_unknown;
sub proc_help;

my $util = Volken::Util->new;
my %command_hash = (
	"QUIT"=>\&proc_quit,
	"TIME"=>\&proc_time,
	"UNKNOWN"=>\&proc_unknown,
	"HELP"=>\&proc_help,
	);

my $start_time = time;
my $continue_flag = 1;
while($continue_flag){
	print ": ";
	my $command = <STDIN>;
	chomp $command;
	my $command_type = command_synonym($command);
	$continue_flag = &{$command_hash{$command_type}};
}
my $end_time = time;
printf "EXITED\n";

sub command_synonym{
	my ($command) = @_;
	my $command_type = "UNKNOWN";
	if("quit" eq $command or
	   "exit" eq $command or
	   "q" eq $command
		){
		$command_type = "QUIT";
	}elsif("time" eq $command or
			"시간" eq $command
		){
		$command_type = "TIME";
	}elsif("help" eq $command){
		$command_type = "HELP";
	}
	return $command_type;
}
sub proc_quit{
	return 0;
}
sub proc_time{
	printf "Now: %s\n", $util->pretty_time;
	return 1;
}
sub proc_unknown{
	return 1;
}
sub proc_help{
	foreach my $one_command (keys %command_hash){
		print $one_command, " ";
	}
	print "\n";
	return 1;
}
