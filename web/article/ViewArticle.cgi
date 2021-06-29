#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use CGI;

use lib ( "../../repos/volken/lib");
use Volken::Prop;

my $q = CGI->new;
print $q->header( 
    -type=>"application/json; charset=UTF-8"
    );
my $srno = $q->param("srno");

my $prop = Volken::Prop->new("../article.ini", " ");
my $dbh= DBI->connect($prop->gets("db_info", "db_user", "db_pw")) or die $DBI::errstr;
my $sql = "SELECT * FROM articles WHERE srno = ?";
my $sth = $dbh->prepare($sql);
$sth->execute($srno);
while(my @rows = $sth->fetchrow_array()){
    my $title = $rows[4];
    my $content = $rows[5];
    print  "{\n";
    printf "  \"srno\": %s", $rows[0];
    print  ",\n";
    $title =~ s/\\/\\\\/g;
    $title =~ s/\"/\\"/g;
    printf "  \"title\": \"%s\"", $title;
    print  ",\n";
    printf "  \"created\": \"%s\"", $rows[1];
    print  ",\n";

    $content =~ s/\r\n/<br \/>/g;
    $content =~ s/\\/\\\\/g;
    $content =~ s/\"/\\"/g;
    # $content =~ s/\//\\\//g;

    printf "  \"content\": \"%s\"", $content;
    print  "\n";
    print  "}\n";
}
$sth->finish();
$dbh->disconnect();
