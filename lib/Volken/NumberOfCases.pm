package Volken::NumberOfCases;

use strict;
use warnings;

sub new{
    my ($class, @n_list) = @_;
    my $self = {};
    $self->{"n"} = \@n_list;
    bless($self, $class);
    return $self;
}
sub nCr{
    my ($self, $r_count, @neo_list) = @_;
    my @result_list = ();
    if(@neo_list){
	combination(\@result_list, $r_count, [], @neo_list);
    }else{
	combination(\@result_list, $r_count, [], @{$self->{"n"}});
    }
    return @result_list;
}
sub combination{
    my ($ref_combination_list, $budget_count, $ref_current_list, @candidate_list) = @_;
    if($budget_count < 0){
	return;
    }
    my $candidate_list_size = scalar(@candidate_list);
    if($budget_count == $candidate_list_size){
	my @current_list = @$ref_current_list;
	push(@current_list, @candidate_list);
	push(@$ref_combination_list, \@current_list);
	return;
    }else{
	my $current = shift(@candidate_list);
	# 선택하거나
	my @one_current_list = @$ref_current_list;
	push(@one_current_list, $current);
	combination($ref_combination_list, $budget_count -1, \@one_current_list, @candidate_list);
	
	# 선택하지 않거나
	my @two_current_list = @$ref_current_list;
	combination($ref_combination_list, $budget_count, \@two_current_list, @candidate_list);
	return;
    }
}
return "Volken::NumberOfCases";
