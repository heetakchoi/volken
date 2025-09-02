#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Util;
use Volken::Prop;

my $csv_filename = $ARGV[0];
my $exemption_filename = $ARGV[1];

unless($csv_filename){
    print  "Usage: perl csvanalyzer.pl [csv file] [exemption file]?\n";
    die "csv file required.\n";
}

my $start_time = time();
my $util = Volken::Util->new;
printf "Start analysis\n";

my %exemption_hash = ();
if($exemption_filename and -e $exemption_filename){
    open(my $fh, "<", $exemption_filename);
    while(my $line=<$fh>){
	chomp($line);
	my @pair = split /,/, $line;
	$exemption_hash{$pair[1]} = $pair[0];
    }
    close($fh);
}

open(my $fh, "<", $csv_filename);
my $line = <$fh>;
chomp($line);
my @column_names = split /,/, $line;
my $column_names_size = scalar @column_names;

my %hash = ();
my $column_index = 0;
foreach my $one_column (@column_names){
    $hash{$column_index} = [];
    $column_index ++;
}

my $row_number = 0;
while($line=<$fh>){
    chomp($line);
    my @items = split /,/, $line;
    if(scalar @items < $column_names_size){
	push(@items, "");
    }
    my $item_index = 0;
    foreach my $one_item (@items){
	$hash{$item_index}->[$row_number] = $one_item;
	$item_index ++;
    }
    $row_number ++;
}
close($fh);

my %info_hash = ();
my @info_names = (
    "값이 존재하는 비율", "평균 (숫자형인 값만)", "표준편차 (숫자형인 값만)",
    "중복 제거한 항목 수", "최빈값 비율/갯수/항목명" );
foreach my $one_column_index (sort {$a<=>$b} keys %hash){
    my $one_column_name = $column_names[$one_column_index];
    my @column_values = @{$hash{$one_column_index}};

    my $fill_count = 0;
    my $number_count = 0;
    my $sum = 0;
    my $square_sum = 0;
    my $mean = "";    
    my %unique_hash = ();
    foreach my $one_value (@column_values){
	unless("" eq $one_value){
	    $fill_count ++;

	    if($one_value =~ /^-?\d+(\.\d+)?$/){
		$number_count ++;
		$sum += $one_value;
		$square_sum += $one_value**2;
	    }
	    
	    unless(defined($exemption_hash{$one_value}) and $exemption_hash{$one_value} eq $one_column_name){
		if(defined($unique_hash{$one_value})){
		    $unique_hash{$one_value} += 1;
		}else{
		    $unique_hash{$one_value} = 1;
		}
	    }
	}
    }
    print  "-"x20, "\n";
    printf "[%s] (%dth of %d)\n", $column_names[$one_column_index], $one_column_index+1, scalar @column_names;
    printf "    %s: %.1f%% %d/%d\n", $info_names[0], 100 * $fill_count/$row_number, $fill_count, $row_number;
    if($number_count){
	$mean = sprintf "%.1f", $sum / $number_count;
	printf "    %s: %s\n", $info_names[1], $mean;
	my $variance = $square_sum/$number_count - $mean**2;
	printf "    %s: %.1f\n", $info_names[2], sqrt($variance);
    }

    printf "    %s: %d\n",   $info_names[3], scalar keys %unique_hash;
    printf "    %s:\n",      $info_names[4];
    my $latch_count = 5;
    foreach my $one_key ( sort{ $unique_hash{$b} <=> $unique_hash{$a} } keys %unique_hash){
	$latch_count --;
	last if($latch_count <= 0);

	my $description = sprintf "%d-th", 5-$latch_count;
	printf "        %s:[%.1f%%] [%d] [%s]\n", $description, 100 * $unique_hash{$one_key} / $fill_count,
	    $unique_hash{$one_key}, $one_key;
    }
}
my $end_time = time();
my $elapsed_time = $end_time - $start_time;
printf "\nEnd analysis.\n Time elapsed %d second. %d시간%d분%d초\n", $elapsed_time, $util->sec_to_hms($elapsed_time);


