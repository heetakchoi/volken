#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use lib "../lib";
use Volken::Prop;

sub trim;

my $break_flag = 0;
unless(-e "db-info.ini"){
    print "File not found. create db-info.ini as\n";
    print "database [DATABASENAME]\nusername [USER NAME]\npassword [PASSWORD]\n";
    die;
}
my $prop = Volken::Prop->new("db-info.ini", " ");

print "#"x80, "\n";
print  "# Usage: perl db-query.pl [database name]\n";

my $database = shift;
$database = $prop->get("database") unless(defined($database));
while(1){
    printf "# Select database.\n";
    printf "# [%s] would be used.\n", $database;
    print  "  - [Enter] to continue.\n";
    print  "    or type other [database name] to connect.\n";
    print  "    or type [q] to quit.\n";
    my $candidate = <STDIN>;
    chomp($candidate);
    if("" eq $candidate){
	last;
    }elsif("q" eq $candidate){
	$break_flag = 1;
	last;
    }else{
	$database = $candidate;
    }
}
my ($username, $password) = $prop->gets("username", "password");
my $dbn = sprintf "DBI:mysql:database=%s", $database;

printf "- Now we try to connect Database: %s Username: %s\n", $database, $username unless($break_flag);

my $dbh = DBI->connect($dbn, $username, $password) or die $DBI::errstr;
while(!$break_flag){
    my $input = "";
    my $line_number = 0;
    while(my $line=<STDIN>){
	$line_number ++;
	chomp($line);
	if("q" eq $line){
	    $break_flag = 1;
	    last;
	}
	my $end_index = index($line, ";");
	if($end_index>0){
	    $line = substr($line, 0, $end_index);
	}
	$input .= " ";
	$input .= $line;
	last if($end_index >0);
    }
    last if($break_flag);
    $input = trim($input);
    printf "INPUT: %s\n", $input;
    my $sql = $input;
    my $sth;
    if($sql =~ m/^select/i
       or $sql =~ m/^show/i
       or $sql =~ m/^desc/i ){
	$sth = $dbh->prepare($sql);
	$sth->execute();
	print "-"x80, "\n";
	while(my @row = $sth->fetchrow_array()){
	    foreach my $item (@row){
		$item = "" unless(defined($item));
		printf "| %s ", $item;
	    }
	    print "|\n";
	}
	$sth->finish();
    }else{
	$sth = $dbh->prepare($sql);
	printf "%s\n", $sth->execute();
	$sth->finish();
    }
    print "#"x80, "\n";
    print "Type q to quit.\n";
}
$dbh->disconnect();

sub trim{
    my $arg = $_[0];
    $arg=~s/^\s+//;
    $arg=~s/\s+$//;
    return $arg;
}
