package Volken::Mark;

use strict;
use warnings;

# 문법
# '| ' 로 시작하면 blockquote
# '- ' 로 시작하면 ul li
# 빈 문자열은 div 로 구분
# '<pre>', '</pre>' 로 시작하면 verbatim 모드 시작/종료

# 'h숫자. ' 로 시작하면 해당 라인을 숫자에 해당하는 h태그로 전환
sub proc_heading{
    my ($line) = @_;
    if($line =~ /^h(\d). /i){
	my $heading = sprintf "h%d", $1;
	$line = substr($line, 4);
	$line =~ s/^\s+|\s+$//;
	return sprintf "  <%s>%s</%s>", $heading, $line, $heading;
    }else{
	return $line;
    }
}

sub new{
    my ($class) = @_;
    my $self = {};
    bless($self, $class);
    return $self;
}

sub load_file{
    my ($self, $file) = @_;
    my $text = "";
    open(my $fh, "<", $file);
    while(<$fh>){
	$text .= $_;
    }
    close($fh);
    $self->{"data"} = $text;
    return $self;
}
sub load_text{
    my ($self, $text) = @_;
    $self->{"data"} = $text;
    return $self;
}
sub get_html{
    my ($self) = @_;
    my $text = $self->{"data"};

    open(my $fh, "<", \$text);
    my $content = "";
    my $before_line = undef;
    my $before_status = "INIT";

    my $pre_flag = 0;

    while(my $line = <$fh>){
	if($line =~ /^<pre>/i){
	    $content .= "<pre>\n";
	    $pre_flag = 1;
	    next;
	}
	if($pre_flag){
	    if($line =~ /^<\/pre>/i){
		$content .= "</pre>\n";
		$pre_flag = 0;
		next;
	    }else{
		$content .= $line;
	    }
	    next;
	}

	if($line =~ /^\s*$/){
	    # 공백문자열로 이루어진 라인을 만났는데
	    
	    if($before_status eq "INIT"){
		# 초기 상태라면 첫 줄부터 공백이다. 이 경우 이전 줄에 대한 처리는 필요없다.

	    }elsif($before_status eq "blank"){
		# 이전 줄이 공백이었으면 br
		$content .= "<br />\n";
		
	    }elsif($before_status eq "normal"){
		# 이전 줄이 일반 문장이면 문단이 끝났다고 보고 div를 닫는다.
		$before_line =~ s/\s+$//;
		$content .= proc_heading($before_line);
		$content .= "\n";
		$content .= "</div>\n";
		
	    }elsif($before_status eq "quote"){
		# 이전 줄이 인용이었으면 인용으로 문단이 끝났다고 보고 quote와 div 를 차례로 닫는다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    %s\n", substr($before_line, 2);
		$content .= "  </blockquote>\n";
		$content .= "</div>\n";
	    }elsif($before_status eq "ulist"){
		# 이전 줄이 u리스트였으면 리스트로 문단이 끝났다고 보고 ul 과 div 를 차례로 닫는다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    <li>%s</li>\n", substr($before_line, 2);
		$content .= "  </ul>\n";
		$content .= "</div>\n";
	    }else{
		# 고려하지 않은 경우.
		$content .= "[unknown 1]<br />\n";
	    }
	    # 현 공백 상태를 이전 라인 상태로지정한다.
	    $before_line = "<br />\n";
	    $before_status = "blank";

	}elsif($line =~ /^\| /){
	    # 인용 문자열을 만났는데
	    if($before_status eq "INIT"){
		# 이전 문자열이 없고 첫 상황이다.
		# 문단이 인용으로 시작되었다고 보고 div, quote 를 연다.
		$content .= "<div>\n";
		$content .= "  <blockquote>\n";
		
	    }elsif($before_status eq "blank"){
		# 이전 문자열이 공백이었다면,
		# 문단이 인용으로 시작되었다고 보고 div, quote 를 연다.
		$content .= "<div>\n";
		$content .= "  <blockquote>\n";

	    }elsif($before_status eq "normal"){
		# 이전 문자열이 일반이었으면 기존 문단에 인용이 추가되었다고 가정한다.
		# 이전 문자열은 그냥 추가하고 아래에 붙여서 인용을 시작할 준비를 한다.
		$before_line =~ s/\s+$//;
		$content .= proc_heading($before_line);
		$content .= "\n";
		$content .= "  <blockquote>\n";
		
	    }elsif($before_status eq "quote"){
		# 이전 문자열이 인용이라면 인용 라인을 추가한다.
		$before_line =~ s/\s+$/<br \/>\n/;
		$content .= sprintf "    %s", substr($before_line, 2);

	    }elsif($before_status eq "ulist"){
		# 이전 문자열이 u리스트였다면 ul 을 끝내고 인용 라인을 시작할 준비를 한다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    <li>%s</li>\n", substr($before_line, 2);
		$content .= "  </ul>\n";
		$content .= "  <blockquote>\n";

	    }else{
		# 고려하지 않은 경우
		$content .= "[unknown 2]<br />\n";		
	    }
	    # 현 인용 상태를 이전 라인 상태로지정한다.
	    $before_line = $line;
	    $before_status = "quote";

	}elsif($line =~ /^- /){
	    # u리스트 문자열을 만났는데
	    if($before_status eq "INIT"){
		# 이전 문자열이 없고 첫 상황이면
		# 문단이 u리스트로 시작되었다고 보고 div, ul을 연다.
		$content .= "<div>\n";
		$content .= "  <ul>\n";

	    }elsif($before_status eq "blank"){
		# 이전 문자열이 공백이었다면
		# 문단이 u리스트로 시작되었다고 보고 iv, ul을 연다
		$content .= "<div>\n";
		$content .= "  <ul>\n";

	    }elsif($before_status eq "normal"){
		# 이전 문자열이 일반이었으면 기존 문단에 u리스트가 추가되었다고 가정한다.
		# 이전 문자열은 그냥 추가하고 아래에 붙여서 u리스트를 시작할 준비를 한다.
		$before_line =~ s/\s+$//;
		$content .= proc_heading($before_line);
		$content .= "\n";
		$content .= "  <ul>\n";
		
	    }elsif($before_status eq "quote"){
		# 이전 문자열이 인용이라면 quote를 끝내고 u리스트를 시작할 준비를 한다.
		$before_line =~ s/\s+$/\n/;
		$content .= sprintf "    %s", substr($before_line, 2);
		$content .= "  </blockquote>\n";
		$content .= "  <ul>\n";
		
	    }elsif($before_status eq "ulist"){
		# 이전 문자열이 u리스트이면 li 를 추가한다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    <li>%s</li>\n", substr($before_line, 2);

	    }else{
		# 고려하지 않은 경우
		$content .= "[unknown 3]<br />\n";
	    }
	    # 현 u리스트 상태를 이전 라인 상태로 저장한다.
	    $before_line = $line;
	    $before_status = "ulist";
	    
	}else{
	    # 특수 상태 - 인용, u리스트, 공백 이 아닌 경우는 일반 문장이라고 가정한다.
	    if($before_status eq "INIT"){
		# 일반 문장으로 시작하는 경우이다.
		# 문단을 시작한다.
		$content .= "<div>\n";
	    }elsif($before_status eq "blank"){
		# 공백 문자열 이후 일반 문장이 새로 문단을 만드는 경우이다.
		# 문단을 시작한다.
		$content .= "<div>\n";
	    }elsif($before_status eq "normal"){
		# 일반 문장이 계속되는 경우는 라인을 br 로 분리하여 붙인다.
		# 단 앞선 문장이 heading 인 경우 br 은 붙이지 않고 줄바꿈만 한다.
		$before_line =~ s/\s+$//;
		if($before_line =~ /^h\d. /i){
		    $content .= proc_heading($before_line);
		    $content .= "\n";
		}else{
		    $content .= proc_heading($before_line);
		    $content .= "<br />\n";
		}

	    }elsif($before_status eq "quote"){
		# 인용구가 끝나고 일반 문장이 왔다고 보고 문단을 유지한 채로 인용구만 닫는다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    %s\n", substr($before_line, 2);
		$content .= "  </blockquote>\n";

	    }elsif($before_status eq "ulist"){
		# u리스트가 끝나고 일반 문장이 왔다고 보고 문단을 유지한 채로 ul을 종료한다.
		$before_line =~ s/\s+$//;
		$content .= sprintf "    <li>%s</li>\n", substr($before_line, 2);
		$content .= "  </ul>\n";

	    }else{
		$content .= "[unknown 4]<br />\n";
	    }
	    $before_line = $line;
	    $before_status = "normal";
	}
    }
    # 처리하지 않은 마지막 문자열이 before_line 에 들어있다.
    if($before_status eq "INIT"){
	# 내용이 없는 경우이므로 오류를 낸다.
	die "내용이 없다\n";
	
    }elsif($before_status eq "blank"){
	# 마지막에 오는 공백 문자열은 의미 없으므로 무시한다.
	
    }elsif($before_status eq "normal"){
	# 일반 문자열로 끝났으므로 문단을 종료한다.
	$before_line =~ s/\s+$//;
	$before_line .= "\n</div>\n";
	$content .= proc_heading($before_line);
	
    }elsif($before_status eq "quote"){
	# 인용으로 끝나면 인용과 문단 모두 닫는다.
	$before_line =~ s/\s+$//;
	$content .= sprintf "    %s\n", substr($before_line, 2);
	$content .= "  </blockquote>\n";
	$content .= "</div>\n";
	
    }elsif($before_status eq "ulist"){
	# u리스트로 끝나면 ul 과 문단을 닫는다.
	$before_line =~ s/\s+$//;
	$content .= sprintf "    <li>%s</li>\n", substr($before_line, 2);
	$content .= "  </ul>\n";
	$content .= "</div>\n";
	
    }else{
	# 이 경우는 예상하지 않은 경우이므로 오류를 낸다.
	die "이런 경우는 없어야 한다.";
    }
    close($fh);

    return $content;
}

return "Volken::Mark";
