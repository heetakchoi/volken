#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Mark;

foreach my $datafile ( glob "markup.html" ){

    my $mark = Volken::Mark->new->load_file($datafile);
    my $content = $mark->get_html();
    printf "%s========\n", $content;
}
