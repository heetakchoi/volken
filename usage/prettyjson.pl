#!/usr/bin/perl
use strict;
use warnings;

sub indent;
my $indent_unit = " "x2;
my $count = 0;

my $result = "";
open(my $fh, "<", "first.json");
my $flag = 0;
while(1){
    my $one_char = getc($fh);
    if($one_char eq "\n"){
	$flag = 1;
    }elsif($flag){
	if($one_char eq "\t" or $one_char eq " " or $one_char eq "\n"){
	    
	}else{
	    $flag = 0;
	}
    }
    if($flag){
    }else{
	if($one_char eq "{" or $one_char eq "["){
	    $result .= "\n";
	    $result .= indent();
	    $result .= $one_char;
	    $result .= "\n";
	    $count ++;
	    $result .= indent();

	}elsif($one_char eq "}" or $one_char eq "]"){
	    $result .= "\n";
	    $count --;
	    $result .= indent();
	    $result .= $one_char;

	}elsif($one_char eq ","){
	    $result .= $one_char;
	    $result .= "\n";
	    $result .= indent();

	}else{
	    $result .= $one_char;
	}
    }
    if(eof($fh)){
	last;
    }
}
close($fh);

print $result, "\n";

sub indent{
    return $indent_unit x $count;
}
