#!/usr/bin/perl

use strict;
use warnings;

my $number = shift;
$number = 10000 unless(defined($number));

my %black_hash = ();

my ($x, $y, $ori_pre, $color_pre, $ori_post, $color_post) = (0, 0, "N", "W");
my ($num, $max_x, $max_y, $min_x, $min_y) = (0, 0, 0, 0, 0);

while($num < $number){
    $num ++;
    if($color_pre eq "W"){
	$color_post = "B";
	if($ori_pre eq "N"){
	    $ori_post = "W";
	}elsif($ori_pre eq "E"){
	    $ori_post = "N";
	}elsif($ori_pre eq "S"){
	    $ori_post = "E";
	}elsif($ori_pre eq "W"){
	    $ori_post = "S";
	}else{
	    die "Invalid ori_pre\n";
	}
    }elsif($color_pre eq "B"){
	$color_post = "W";
	if($ori_pre eq "N"){
	    $ori_post = "E";
	}elsif($ori_pre eq "E"){
	    $ori_post = "S";
	}elsif($ori_pre eq "S"){
	    $ori_post = "W";
	}elsif($ori_pre eq "W"){
	    $ori_post = "N";
	}else{
	    die "Invalid ori_pre\n";
	}
    }else{
	die "Invalid color_pre\n";
    }
    my $position = sprintf "%d,%d", $x, $y;
    if($color_post eq "W"){
	delete $black_hash{$position};
    }elsif($color_post eq "B"){
	$black_hash{$position} = 1;
    }

    if($ori_post eq "N"){
	$y += 1;
    }elsif($ori_post eq "E"){
	$x += 1;
    }elsif($ori_post eq "S"){
	$y -= 1;
    }elsif($ori_post eq "W"){
	$x -= 1;
    }else{
	die "Invalid ori_post\n";
    }
    $ori_pre = $ori_post;
    $position = sprintf "%d,%d", $x, $y;
    if(defined($black_hash{$position})){
	$color_pre = "B";
    }else{
	$color_pre = "W";
    }
    $max_x = $x if($x > $max_x);
    $max_y = $y if($y > $max_y);
    $min_x = $x if($x < $min_x);
    $min_y = $y if($y < $min_y);
}

open(my $fh_w, ">", "result.html");

print $fh_w "<html>\n";
print $fh_w "  <head>\n";
print $fh_w "    <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>\n";
print $fh_w "    <script type=\"text/javascript\">\n";
print $fh_w "      google.charts.load('current', {'packages':['corechart']});\n";
print $fh_w "      google.charts.setOnLoadCallback(drawChart);\n";
print $fh_w "      function drawChart() {\n";
print $fh_w "        var data = google.visualization.arrayToDataTable([\n";
print $fh_w "	       ['X', 'Ant position'],\n";
foreach (keys %black_hash){
    my ($x, $y) = split /,/, $_;
    printf $fh_w "	       [%d,%d],\n", $x, $y;
}
print $fh_w "	     ]);\n";

print $fh_w "	     var options = {\n";
print $fh_w "          title: 'Ant',\n";
printf $fh_w "         hAxis: {title: 'West/East', minValue: %d, maxValue: %d},\n", $min_x, $max_x;
printf $fh_w "         vAxis: {title: 'South/North', minValue: %d, maxValue: %d},\n", $min_y, $max_y;
print $fh_w "          legend: 'none'\n";
print $fh_w "        };\n";
print $fh_w "        var chart = new google.visualization.ScatterChart(document.getElementById('chart_div'));\n";
print $fh_w "        chart.draw(data, options);\n";
print $fh_w "      }\n";
print $fh_w "    </script>\n";
print $fh_w "  </head>\n";
print $fh_w "  <body>\n";
print $fh_w "    <div id=\"chart_div\" style=\"width: 900px; height: 500px;\"></div>\n";
print $fh_w "  </body>\n";
print $fh_w "</html>\n";
close $fh_w;
