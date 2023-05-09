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
sub nPr{
    my ($self, $r_count, @neo_list) = @_;
    my @result_list = ();
    if(@neo_list){
	permutation(\@result_list, $r_count, [], @neo_list);
    }else{
	permutation(\@result_list, $r_count, [], @{$self->{"n"}});
    }
    return @result_list;
}
sub permutation{
    my ($ref_permutation_list, $budget_count, $ref_selected_list, @candidate_list) = @_;
    if($budget_count < 0){
	return;
    }elsif($budget_count == 0){
	push(@$ref_permutation_list, $ref_selected_list);
	return;
    }else{
	my $index = 0;
	foreach (@candidate_list){
	    my @next_candidate_list = @candidate_list;
	    my $selected = splice(@next_candidate_list, $index, 1);
	    my @selected_list = @$ref_selected_list;
	    push(@selected_list, $selected);
	    permutation($ref_permutation_list, $budget_count -1, \@selected_list, @next_candidate_list);
	    $index ++;
	}
    }
}
sub combination{
    my ($ref_combination_list, $budget_count, $ref_selected_list, @candidate_list) = @_;
    if($budget_count < 0){
	return;
    }
    my $candidate_list_size = scalar(@candidate_list);
    if($budget_count == $candidate_list_size){
	my @selected_list = @$ref_selected_list;
	push(@selected_list, @candidate_list);
	push(@$ref_combination_list, \@selected_list);
	return;
    }else{
	my $selected = shift(@candidate_list);
	# 선택하거나
	my @one_selected_list = @$ref_selected_list;
	push(@one_selected_list, $selected);
	combination($ref_combination_list, $budget_count -1, \@one_selected_list, @candidate_list);
	
	# 선택하지 않거나
	my @two_selected_list = @$ref_selected_list;
	combination($ref_combination_list, $budget_count, \@two_selected_list, @candidate_list);
	return;
    }
}
return "Volken::NumberOfCases";
