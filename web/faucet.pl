#!/usr/bin/perl

use strict;
use warnings;

use CGI;

my $q = CGI->new;
my $upload_dir = "reservoir";
my $file_name = $q->param("upload");

my $upload_flag = 0;
if($file_name){
    if ($file_name =~ /([^\\\/]+)$/) {
        $file_name = $1;
    }
    my $upload_fh= $q->upload("upload");
    my $file_location = sprintf "%s/%s", $upload_dir, $file_name;

    open(my $file, ">", $file_location) or die "Cannot open $file_location: $!";
    binmode $file;
    binmode $upload_fh;
    while(my $bytes_read = read($upload_fh, my $buffer, 8192)){
        print $file $buffer;
    }
    close($file);
    $upload_flag = 1;
}
my @files = glob(sprintf "%s/*", $upload_dir);
print $q->header(
    -charset=>"utf-8"
    );
print $q->start_html(
    -title=>"File Upload",
    -style=>{src=>".style.css"},
    -script=>{type =>"text/javascript", src=>"script.js"}
    );
if($upload_flag){
    printf "<script> alert(\"Upload success [%s]\"); </script>\n", $file_name;
}
print  "<form name=\"formname\" enctype=\"multipart/form-data\" method=\"post\" action=\"faucet.pl\">\n";
print  "  <input type=\"file\" name=\"upload\" />\n";
print  "  <input type=\"submit\" name=\"submit\" value=\"upload\" />\n";
print  "</form>\n";
print  "<table>\n";
print  "  <th><th>file</th></th>\n";
foreach my $one_file (@files){
    printf "  <tr><td><a href=\"%s\">%s</a></td></tr>\n", $one_file, $one_file;
}
print  "</table>\n";
print $q->end_html;
