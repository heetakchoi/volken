#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Util;
use Volken::Https;
use Volken::Http;

sub command_synonym;
sub ddanzi_hot;
sub redtea_board;

sub proc_quit;
sub proc_time;
sub proc_unknown;
sub proc_help;
sub proc_news;
sub proc_fun;
sub proc_anzi;
sub proc_info;

my $util = Volken::Util->new;
my %command_hash = (
	"QUIT"=>\&proc_quit,
	"TIME"=>\&proc_time,
	"UNKNOWN"=>\&proc_unknown,
	"HELP"=>\&proc_help,
	"NEWS"=>\&proc_news,
	"FUN"=>\&proc_fun,
	"ANZI"=>\&proc_anzi,
	"INFO"=>\&proc_info,
	);

my $start_time = time;
my $continue_flag = 1;
my @command_history = ();
while($continue_flag){
	print ": ";
	my $command = <STDIN>;
	chomp $command;
	my @commands = split / /, $command;
	my $command_type = command_synonym($commands[0]);
	$continue_flag = &{$command_hash{$command_type}}($commands[1]);
	push(@command_history, $command_type);
	shift @command_history if(scalar @command_history > 5);
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
	}elsif("news" eq $command or
		   "뉴스" eq $command){
		$command_type = "NEWS";
	}elsif("fun" eq $command or
		   "펀" eq $command or
		   "humor" eq $command or
		   "유머" eq $command
		){
		$command_type = "FUN";
	}elsif("anzi" eq $command or
		   "danzi" eq $command or
		   "ddanzi" eq $command
		){
		$command_type = "ANZI";
	}elsif("info" eq $command){
		$command_type = "INFO";
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
	print  "UNKNOWN command\n";
	return 1;
}
sub proc_help{
	foreach my $one_command (sort keys %command_hash){
		print $one_command, " ";
	}
	print "\n";
	return 1;
}
sub proc_news{
	redtea_board("news");
	return 1;
}
sub proc_fun{
	redtea_board("fun");
	return 1;
}
sub redtea_board{
	my ($board_name) = @_;
	my $result = "";
	my $https = Volken::Https->new;
	$https->host("redtea.kr")
		->url("/pb/pb.php")
		->param("id", $board_name);
	my $html = $https->get;
	open my $fh, "<", \$html;
	while(my $line = <$fh>){
		chomp $line;
		if($line =~ m/^\s+<td/){
			if($line =~ m/<a href="(pb.php\?id=[^&]+&no=\d+)"/){
				my $location = $1;
				my $title = "";
				if($board_name eq "news"){
					$line =~ m/<span class="subj">([^<]+)<\/a>/;
					$title = $1;
				}elsif($board_name eq "fun"){
					$line =~ m/"  >([^<]+)<\/a>/;
					$title = $1;
				}
				printf "https://redtea.kr/pb/%s %s\n", $location, $title;
			}
		}
	}
	close $fh;
	return undef;
}
sub proc_anzi{
	my ($page_no) = @_;
	ddanzi_hot($page_no);
	return 1;
}
sub ddanzi_hot{
	my ($page_no) = @_;
	my $url = "/hot_all";
	if(defined($page_no)){
		$url = sprintf "/index.php?mid=hot_all&page=%d", $page_no;
	}
	printf "URL: %s\n", $url;
	my $http = Volken::Http->new;
	$http->host("www.ddanzi.com")
		->url($url)
		;
	my $html = $http->get;
	open my $fh , "<", \$html;
	while(my $line = <$fh>){
		chomp $line;
		if($line =~ m/<a href="([^"]+)">/){
			my $location = $1;
			$location =~ s/&amp;/&/g;
			$location =~ s/%2C/,/g;
			my $index = index($location, "&statusList=");
			if($index > 0){
				$location = substr($location, 0, $index);
			}
			$line = <$fh>;
			$line =~ m/<\/span>([^<]+)<\/a>/;
			my $title = $1;
			if(defined($title)){
				chomp $title;
				$title =~ s/&lt;/</g;
				$title =~ s/&gt;/>/g;
				$title =~ s/&quot;/"/g;
				$title =~ s/^\s+|\s+$//g;
				printf "%s %s\n", $location, $title;
			}
			<$fh>;
		}
	}
	close $fh;
}
sub proc_info{
	my $during = time - $start_time;
	my $hour = 0;
	if($during > 3600){
		$hour = int $during / 3600;
		$during -= $hour * 3600;
	}
	my $minute = 0;
	if($during > 60){
		$minute = int $during / 60;
		$during -= $minute * 60;
	}
	print "시작한 지";
	printf " %2d시간", $hour if($hour);
	printf " %2d분", $minute if($minute);
	printf " %2d초 지났습니다.\n", $during;

	print "최근 사용한 command 는 @command_history 입니다.\n";

	return 1;
}
