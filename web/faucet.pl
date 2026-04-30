#!/usr/bin/perl

use strict;
use warnings;

use CGI;

my $q = CGI->new;
my $upload_dir = "reservoir";
my $file_name = $q->param("upload");
my $delete_file = $q->param("delete");

my $upload_flag = 0;
my $delete_flag = 0;
my $delete_name = "";

if($delete_file){
    $delete_file =~ s/[\/\\]//g;
    my $delete_path = sprintf "%s/%s", $upload_dir, $delete_file;
    if(-f $delete_path){
        unlink($delete_path);
        $delete_name = $delete_file;
        $delete_flag = 1;
    }
}

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
if($delete_flag){
    printf "<script> alert(\"Deleted [%s]\"); </script>\n", $delete_name;
}
print  "<form name=\"formname\" enctype=\"multipart/form-data\" method=\"post\" action=\"faucet.pl\">\n";
print  "  <input type=\"file\" name=\"upload\" />\n";
print  "  <input type=\"submit\" name=\"submit\" value=\"upload\" />\n";
print  "</form>\n";
print  "<table>\n";
print  "  <th><th>file</th><th></th></th>\n";
foreach my $one_file (@files){
    my $base_name = $one_file;
    $base_name =~ s/^.*[\/\\]//;
    printf "  <tr>\n";
    printf "    <td><a href=\"%s\">%s</a></td>\n", $one_file, $one_file;
    printf "    <td><form method=\"post\" action=\"faucet.pl\" style=\"display:inline\" onsubmit=\"return confirm('Delete %s?')\">\n", $base_name;
    printf "      <input type=\"hidden\" name=\"delete\" value=\"%s\" />\n", $base_name;
    printf "      <input type=\"submit\" value=\"delete\" />\n";
    printf "    </form></td>\n";
    printf "  </tr>\n";
}
print  "</table>\n";
print $q->end_html;
