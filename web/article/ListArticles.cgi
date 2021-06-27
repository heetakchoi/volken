#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use CGI;

use lib "../../repos/volken/lib";
use Volken::Prop;

my $q = CGI->new;
print $q->header( 
    -type=>"application/json; charset=UTF-8"
    );

my $upper = $q->param("upper");
$upper = 0 unless(defined($upper));
my $size = $q->param("size");
$size = 20 unless(defined($size));

my $prop = Volken::Prop->new("../article.ini", " ");
my $dbh= DBI->connect($prop->gets("db_info", "db_user", "db_pw")) or die $DBI::errstr;
my $sql;
my $sth;
if($upper>0){
    $sql = " SELECT * FROM articles WHERE srno < ? ORDER BY srno DESC LIMIT ? ";
    $sth = $dbh->prepare($sql);
    $sth->execute($upper, $size);
}else{
    $sql = " SELECT * FROM articles ORDER BY srno DESC LIMIT ? ";
    $sth = $dbh->prepare($sql);
    $sth->execute($size);
}
print  "[\n";
my $first_flag = 1;
while(my @rows = $sth->fetchrow_array()){
    if($first_flag){
	$first_flag = 0;
    }else{
	print ",";
    }
    my $title = $rows[4];
    $title =~ s/\\/\\\\/g;
    $title =~ s/\"/\\"/g;
    print  "{\n";
    printf "  \"srno\": %s", $rows[0];
    print  ",\n";
    printf "  \"title\": \"%s\"", $title;
    print  ",\n";
    printf "  \"created\": \"%s\"", $rows[1];
    print  "\n";
    print  "}\n";
}
print  "]";
$sth->finish();
$dbh->disconnect();


