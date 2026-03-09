#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
use Cwd;
use File::Basename;

use lib "../../lib";
use Volken::Prop;
use Volken::Fanel;

unless(-e "info.ini"){
    print "info.ini 파일이 없습니다. 아래와 같이 생성하세요.\n";
    print "port [포트번호]\n";
    print "file_dir [업로드된 파일이 저장될 디렉토리]\n";
    die;
}

my $prop = Volken::Prop->new("info.ini", " ");
my ($port, $file_dir) = $prop->gets("port", "file_dir");
unless(-d $file_dir){
    mkdir $file_dir;
}
my $server_socket = IO::Socket::INET->new(
    LocalPort => $port,
    Proto => "tcp", Listen => 5, Reuse => 1);
print  "Fanel Remote Service start.\n";
printf "Listen port [%d]\n", $port;
printf "Upload directory [%s]\n", $file_dir;
my $fanel = Volken::Fanel->new();
$SIG{CHLD} = 'IGNORE';
while(1){
    my $socket = $server_socket->accept();
    my $pid = fork();
    if($pid == 0){
	my $buffer;
	my $bytes_read = sysread($socket, $buffer, 1+4);
	my ($type, $payload_length) = unpack("A N", $buffer);
	my $payload;
	my $result;
	my $skip_send_flag = 0;
	printf "[%s-STT] type:%s\n", $$, $type;
	
	if($type eq 'A'){
	    $bytes_read = sysread($socket, $buffer, $payload_length);
	    $payload = $buffer;
	    printf "[%s-REQ] %s\n", $$, $payload;
	    $result = `$payload`;
	    if($result){
		chomp($result);
	    }else{
		$result = sprintf "백틱 호출 오류 발생";
	    }

	}elsif($type eq 'B'){
	    my $payload_length_1 = $payload_length;
	    $bytes_read = sysread($socket, $buffer, 4);
	    my ($payload_length_2) = unpack("N", $buffer);

	    $bytes_read = sysread($socket, $buffer, $payload_length_1);
	    my $payload_1 = $buffer;
	    $bytes_read = sysread($socket, $buffer, $payload_length_2);
	    my $payload_2 = $buffer;

	    printf "[%s-REQ] %s %s\n", $$, $payload_1, $payload_2;

	    if("download" eq $payload_1){
		my $file_location = $payload_2;
		if(-f $file_location){
		    my $file_size = -s $file_location;
		    $fanel->send_c_type($socket, "Success", $file_location, $file_size);

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
		    $result = sprintf "다운로드할 파일을 찾을 수 없습니다. [%s]\n", $payload_2;
		    send_c_type($socket, "Failure", $result, -1);
		}
		$skip_send_flag = 1;
	    }
	    
	}elsif($type eq 'C'){
	    my $payload_length_1 = $payload_length;
	    $bytes_read = sysread($socket, $buffer, 4+4);
	    my ($payload_length_2, $payload_length_3) = unpack("N N", $buffer);
	    
	    $bytes_read = sysread($socket, $buffer, $payload_length_1);
	    my $payload_1 = $buffer;
	    $bytes_read = sysread($socket, $buffer, $payload_length_2);
	    my $payload_2 = $buffer;
	    $bytes_read = sysread($socket, $buffer, $payload_length_3);
	    my $payload_3 = $buffer;

	    printf "[%s-REQ] %s %s %s\n", $$, $payload_1, $payload_2, $payload_3;
	    if("upload" eq $payload_1){
		my $file_name = basename($payload_2);
		my $file_location = sprintf "%s/%s", $file_dir, $file_name;
		my $file_size = $payload_3;

		open(my $fh, ">", $file_location);
		binmode($fh);
		$buffer = undef;
		$bytes_read = 0;
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
		$result = sprintf "Upload %s (%d) completed.", $file_name, -s $file_location;
	    }
	}else{
	    printf "[%s-INF] 불완전한 요청\n", $$;
	    $skip_send_flag = 1;
	}
	unless($skip_send_flag){
	    $payload = $result;
	    $payload_length = length($payload);
	    my $packet = pack("A N A*", 'A', $payload_length, $payload);
	    syswrite($socket, $packet, length($packet));
	    printf "[%s-RES] %s\n", $$, $payload;
	}
	close($socket);
	printf "[%s-END]\n", $$;
	exit;
    }
}

