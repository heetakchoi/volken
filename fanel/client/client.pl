#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
use File::Basename;

use lib "../../lib";
use Volken::Prop;
use Volken::Fanel;

unless(-e "info.ini"){
    print "info.ini 파일이 없습니다. 아래와 같이 생성하세요.\n";
    print "host [리모트 서버 주소]\n";
    print "port [포트번호]\n";
    print "file_dir [다운로드한 파일이 저장될 디렉토리]\n";
    die;
}

my $prop = Volken::Prop->new("info.ini", " ");
my ($host, $port, $file_dir) = $prop->gets("host", "port", "file_dir");

unless(-d $file_dir){
    mkdir $file_dir;
}

my %command_hash = (
    "quit"=>"종료",
    "help"=>"사용할 수 있는 커맨드 종류 및 안내",
    "upload"=>"upload [로컬 파일 위치], 리모트 서버로 파일을 전송",
    "download"=>"download [리모트 파일 위치], 리모트 서버의 파일을 로컬로 전송"
    );

printf "Terminal version %s\n", "0.1";
printf "[quit] for exit\n";
printf "[help] for command list\n";
printf "Connecting to %s : %d\n", $host, $port;
printf "Download directory [%s]\n", $file_dir;

my $fanel = Volken::Fanel->new();
while(1){
    print ">> ";
    my $skip_receive_flag = 0;
    my $command_line = <STDIN>;
    $command_line =~ s/^\s+|\s+$//g;
    my ($command, @args) = split(/\s/, $command_line);
    unless($command){
	next;
    }
    
    last if("quit" eq $command);
    if("help" eq $command){
	foreach my $one_key (keys %command_hash){
	    printf "  <%s> %s\n", $one_key, $command_hash{$one_key};
	}
	next;
    }

    my $socket = IO::Socket::INET->new(
	PeerAddr => $host, PeerPort => $port, Proto => "tcp");

    if("upload" eq $command){
	my $file_location = substr($command_line, length($command) +1);
	if(-f $file_location){
	    my $file_size = -s $file_location;
	    $fanel->send_c_type($socket, $command, $file_location, $file_size);

	    open(my $fh, "<", $file_location);
	    binmode($fh);
	    my $buffer;
	    while((my $bytes_read = sysread($fh, $buffer, 8192))>0){
		my $offset = 0;
		while($bytes_read > 0){
		    my $written_count = syswrite($socket, $buffer, $bytes_read, $offset);
		    $bytes_read -= $written_count;
		    $offset += $written_count;
		}
	    }
	    close($fh);
	}else{
	    printf "업로드할 파일을 찾을 수 없습니다. [%s]\n", $file_location;
	    $skip_receive_flag = 1;
	}
    }elsif("download" eq $command){
	my $file_location = substr($command_line, length($command) +1);
	$fanel->send_b_type($socket, $command, $file_location);

	my ($payload_1, $payload_2, $payload_3) = $fanel->receive_c_type($socket);

	if("Success" eq $payload_1){
	    my $file_name = basename($payload_2);
	    my $file_size = $payload_3;
	    my $file_location = sprintf "%s/%s", $file_dir, $file_name;

	    open(my $fh, ">", $file_location);
	    binmode($fh);
	    my $buffer;
	    my $bytes_read = 0;
	    my $bytes_read_sum = 0;
	    while(($bytes_read = sysread($socket, $buffer, 8192))>0){
		$bytes_read_sum += $bytes_read;
		my $offset = 0;
		while($bytes_read > 0){
		    my $written_count = syswrite($fh, $buffer, $bytes_read, $offset);
		    $bytes_read -= $written_count;
		    $offset += $written_count;
		}
		last if($bytes_read_sum >= $file_size);
	    }
	    close($fh);
	    my $result = sprintf "Download %s (%d) completed.", $file_name, -s $file_location;
	    printf "%s\n", $result;
	}else{
	    printf "Download failure: %s\n", $payload_2;
	}
	$skip_receive_flag = 1;
    }else{
	$fanel->send_a_type($socket, $command_line);
    }

    unless($skip_receive_flag){
	printf "[%s:%d] %s\n", $host, $port, $fanel->receive_a_type($socket);
    }
    close($socket);
}
