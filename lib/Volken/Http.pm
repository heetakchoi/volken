package Volken::Http;

use strict;
use warnings;

use IO::Socket::INET;

sub unchunk;
sub trim;
sub uriencode;

sub new{
    my ($class) = @_;
    my $self = {};
    $self->{"headers"} = {};
    $self->{"params"} = {};
    $self->{"parts"} = {};
    $self->{"part_index"} = 0;
    bless($self, $class);
    return $self;
}
sub get{
    my ($self) = @_;
    my $host = $self->{"host"};
    my $port = $self->{"port"};
    $port = 80 unless(defined($port));
    my %param_map = %{ $self->{"params"}};
    my $req_uri = $self->{"url"};
    my $first_flag = 1;
    foreach my $param_key (keys %param_map){
	my $param_value = $param_map{$param_key};
	if($first_flag){
	    $req_uri .= "?";
	    $first_flag = 0;
	}else{
	    $req_uri .= "&";
	}
	$req_uri .= sprintf "%s=%s", uriencode($param_key), uriencode($param_value);
    }
    my $request_line = sprintf "GET %s HTTP/1.1\r\n", $req_uri;
    
    my %header_map = %{ $self->{"headers"}};
    unless(defined($header_map{"Host"})){
	if($port eq 80){
	    $header_map{"Host"} = sprintf("%s", $host);
	}else{
	    $header_map{"Host"} = sprintf("%s:%d", $host, $port);
	}
    }
    unless(defined($header_map{"Connection"})){
	$header_map{"Connection"} = "close";
    }
    my $request_head = "";
    foreach my $header_key (keys %header_map){
	my $header_value = $header_map{$header_key};
	$request_head .= sprintf "%s: %s\r\n", $header_key, $header_value;
    }
    my $raw_request = $request_line . $request_head . "\r\n";
    $self->{"raw_request"} = $raw_request;

    my $emulate_flag = $self->{"emulate_flag"};
    if($emulate_flag){
	return "";
    }else{
	my $socket = IO::Socket::INET->new(
	    PeerHost=>$host,
	    PeerPort=>$port,
	    Proto=>"tcp"
	    ) or die "Error in socket creation: $!\n";

	print $socket $raw_request;

	my $raw_response = "";
	while(<$socket>){
	    $raw_response .= $_;
	}
	$self->{"raw_response"} = $raw_response;
	shutdown($socket, 2);
	$socket->close();

	my $neck_index = index($raw_response, "\r\n\r\n");
	my $response_head = substr($raw_response, 0, $neck_index);
	my $response_body = substr($raw_response, $neck_index + 4);
	my @response_headers = split(/\r\n/, $response_head);
	my $chunked_flag = 0;
	foreach my $response_header (@response_headers){
	    if($response_header =~ m/Transfer-Encoding/
	       && $response_header =~ m/chunked/){
		$chunked_flag = 1;
		last;
	    }
	}
	if($chunked_flag){
	    $response_body = unchunk($response_body);
	}
	return $response_body;
    }
}
sub multipart{
    my ($self) = @_;

    my $end_part = Volken::Part->new;
    add_part($self, $end_part);
    
    my $host = $self->{"host"};
    my $port = $self->{"port"};
    $port = 80 unless(defined($port));
    
    my $boundary = sprintf ("----------%s", int(rand(10000_0000)));

    my $req_uri = $self->{"url"};
    my $request_line = sprintf "POST %s HTTP/1.1\r\n", $req_uri;

    my %header_map = %{ $self->{"headers"}};
    unless(defined($header_map{"Host"})){
	if($port eq 80){
	    $header_map{"Host"} = sprintf("%s", $host);
	}else{
	    $header_map{"Host"} = sprintf("%s:%d", $host, $port);
	}
    }
    unless(defined($header_map{"Connection"})){
	$header_map{"Connection"} = "close";
    }
    unless(defined($header_map{"Content-Type"})){
	$header_map{"Content-Type"} = sprintf("multipart/form-data; boundary=%s", $boundary);
    }

    my $request_body = "";
    my $total_size = 0;
    
    foreach my $one_key (sort {$a<=>$b} keys %{$self->{"parts"}}){
	my $one_part = $self->{"parts"}->{$one_key};
	$one_part->build($boundary);
	$total_size += $one_part->get("size");
	$request_body .= $one_part->get("header");
	if("VALUE" eq $one_part->get("type")){
	    $request_body .= $one_part->get("value");
	}elsif("FILE" eq $one_part->get("type")){
	    my $filelocation = $one_part->get("filelocation");
	    open(my $fh, "<", $filelocation);
	    binmode $fh;
	    while(<$fh>){
		$request_body .= $_;
	    }
	    close($fh);
	}elsif("CUSTOM" eq $one_part->get("type")){
	    if($one_part->get("value")){
		$request_body .= $one_part->get("value");
	    }
	    my $filelocation = $one_part->get("filelocation");
	    if($filelocation and -f $filelocation){
		open(my $fh, "<", $filelocation);
		binmode $fh;
		while(<$fh>){
		    $request_body .= $_;
		}
		close($fh);
	    }
	}
    }
    $total_size -= 4;
    $header_map{"Content-Length"} = $total_size;

    my $request_head = "";
    foreach my $header_key (keys %header_map){
	my $header_value = $header_map{$header_key};
	$request_head .= sprintf "%s: %s\r\n", $header_key, $header_value;
    }
    my $raw_request = $request_line . $request_head . $request_body;
    $self->{"raw_request"} = $raw_request;

    my $emulate_flag = $self->{"emulate_flag"};
    if($emulate_flag){
	return "";
    }else{
	my $socket = IO::Socket::INET->new(
	    PeerHost=>$host,
	    PeerPort=>$port,
	    Proto=>"tcp"
	    ) or die "Error in socket creation: $!\n";

	# print $socket $raw_request;
	print $socket $request_line;
	print $socket $request_head;
	foreach my $one_key (sort {$a<=>$b} keys %{$self->{"parts"}}){
	    my $one_part = $self->{"parts"}->{$one_key};
	    print $socket $one_part->get("header");
	    if("VALUE" eq $one_part->get("type")){
		print $socket $one_part->get("value");
	    }elsif("FILE" eq $one_part->get("type")){
		my $filelocation = $one_part->get("filelocation");
		open(my $fh, "<", $filelocation);
		binmode $fh;
		while(<$fh>){
		    print $socket $_;
		}
		close($fh);
	    }elsif("CUSTOM" eq $one_part->get("type")){
		if($one_part->get("value")){
		    print $socket $one_part->get("value");
		}
		my $filelocation = $one_part->get("filelocation");
		if($filelocation and -f $filelocation){
		    open(my $fh, "<", $filelocation);
		    binmode $fh;
		    while(<$fh>){
			print $socket $_;
		    }
		    close($fh);
		}
	    }
	}	

	my $raw_response = "";
	while(<$socket>){
	    $raw_response .= $_;
	}
	$self->{"raw_response"} = $raw_response;
	shutdown($socket, 2);
	$socket->close();

	my $neck_index = index($raw_response, "\r\n\r\n");
	my $response_head = substr($raw_response, 0, $neck_index);
	my $response_body = substr($raw_response, $neck_index + 4);
	my @response_headers = split(/\r\n/, $response_head);
	my $chunked_flag = 0;
	foreach my $response_header (@response_headers){
	    if($response_header =~ m/Transfer-Encoding/
	       && $response_header =~ m/chunked/){
		$chunked_flag = 1;
		last;
	    }
	}
	if($chunked_flag){
	    $response_body = unchunk($response_body);
	}
	return $response_body;
    }
}
sub add_part{
    my ($self, $one_part) = @_;
    my $part_index = $self->{"part_index"};
    $self->{"parts"}->{$part_index} = $one_part;
    $self->{"part_index"} = $part_index +1;
    return $self;
}
sub post{
    my ($self) = @_;
    my $host = $self->{"host"};
    my $port = $self->{"port"};
    $port = 80 unless(defined($port));
    
    my $req_uri = $self->{"url"};
    my $request_line = sprintf "POST %s HTTP/1.1\r\n", $req_uri;
    
    my %header_map = %{ $self->{"headers"}};
    unless(defined($header_map{"Host"})){
	if($port eq 80){
	    $header_map{"Host"} = sprintf("%s", $host);
	}else{
	    $header_map{"Host"} = sprintf("%s:%d", $host, $port);
	}
    }
    unless(defined($header_map{"Connection"})){
	$header_map{"Connection"} = "close";
    }
    unless(defined($header_map{"Content-Type"})){
	$header_map{"Content-Type"} = "application/x-www-form-urlencoded";
    }

    my $request_body = "";
    my %param_map = %{ $self->{"params"}};
    my $first_flag = 1;
    foreach my $param_key (keys %param_map){
	my $param_value = $param_map{$param_key};
	$param_value = "" unless(defined($param_value));
	if($first_flag){
	    $first_flag = 0;
	}else{
	    $request_body .= "&";
	}
	$request_body .= sprintf "%s=%s", uriencode($param_key), uriencode($param_value);
    }
    my $payload = $self->{"payload"};
    if(defined($payload)){
	$request_body = $payload;
    }
    my $request_body_size = length($request_body);
    $header_map{"Content-Length"} = $request_body_size;

    my $request_head = "";
    foreach my $header_key (keys %header_map){
	my $header_value = $header_map{$header_key};
	$request_head .= sprintf "%s: %s\r\n", $header_key, $header_value;
    }
    my $raw_request = $request_line . $request_head . "\r\n" . $request_body;
    $self->{"raw_request"} = $raw_request;

    my $emulate_flag = $self->{"emulate_flag"};
    if($emulate_flag){
	return "";
    }else{
	my $socket = IO::Socket::INET->new(
	    PeerHost=>$host,
	    PeerPort=>$port,
	    Proto=>"tcp"
	    ) or die "Error in socket creation: $!\n";

	print $socket $raw_request;

	my $raw_response = "";
	while(<$socket>){
	    $raw_response .= $_;
	}
	$self->{"raw_response"} = $raw_response;
	shutdown($socket, 2);
	$socket->close();

	my $neck_index = index($raw_response, "\r\n\r\n");
	my $response_head = substr($raw_response, 0, $neck_index);
	my $response_body = substr($raw_response, $neck_index + 4);
	my @response_headers = split(/\r\n/, $response_head);
	my $chunked_flag = 0;
	foreach my $response_header (@response_headers){
	    if($response_header =~ m/Transfer-Encoding/
	       && $response_header =~ m/chunked/){
		$chunked_flag = 1;
		last;
	    }
	}
	if($chunked_flag){
	    $response_body = unchunk($response_body);
	}
	return $response_body;
    }
}
sub unchunk{
    my ($chunked) = @_;
    my $unchunked = "";
    my $num_start_index = 0;

    while(1){
	my $num_end_index = index($chunked, "\r\n", $num_start_index +1);
	my $num_str = substr($chunked, $num_start_index, $num_end_index - $num_start_index);
	my $chunk_size_expected = hex(trim($num_str));
	if($chunk_size_expected == 0){
	    last;
	}
	$unchunked .= substr($chunked, $num_end_index+2, $chunk_size_expected);
	$num_start_index = $num_end_index + 2 + $chunk_size_expected + 2;
    }
    return $unchunked;
}

sub host{
    my ($self, $host) = @_;
    $self->{"host"} = $host;
    return $self;
}
sub port{
    my ($self, $port) = @_;
    $self->{"port"} = $port;
    return $self;
}
sub url{
    my ($self, $url) = @_;
    $self->{"url"} = $url;
    return $self;
}
sub header{
    my ($self, $key, $value) = @_;
    $self->{"headers"}->{$key} = $value;
    return $self;
}
sub param{
    my ($self, $key, $value) = @_;
    $self->{"params"}->{$key} = $value;
    return $self;
}
sub payload{
    my ($self, $payload) = @_;
    $self->{"payload"} = $payload;
    return $self;
}
sub info{
    my ($self) = @_;
    return sprintf "===== REQ =====\n%s\n===== RES =====\n%s\n", $self->{"raw_request"}, $self->{"raw_response"};
}
sub emulate_flag{
    my ($self, $emulate_flag) = @_;
    $self->{"emulate_flag"} = $emulate_flag;
    return $self;
}
sub raw_request{
    my ($self) = @_;
    return $self->{"raw_request"};
}
sub uriencode{
    my ($data) = @_;
    $data =~ s!([^/?#=a-zA-Z0-9_.-])!uc sprintf "%%%02x", ord($1)!eg;
    return $data;
}
sub trim{
    my ($str) = @_;
    $str =~ s/^(\s*)//;
    $str =~ s/(\s*)$//;
    return $str;
}
return "Volken::Http";
