package Volken::ZN;

use strict;
use warnings;

sub new{
	my ($class, $rawdata) = @_;
	my @numbers = ();
	open my $fh, "<", \$rawdata;
	my $first_flag = 1;
	my $sign = "";
	while(defined(my $onechar = getc $fh)){
		if($first_flag){
			$first_flag = 0;
			if($onechar eq "-"){
				$sign = "-";
				next;
			}elsif($onechar eq "+"){
				next;
			}
		}
		push(@numbers, $onechar);
	}
	close $fh;
	my $self = {};
	$self->{"rawdata"} = $rawdata;
	$self->{"numbers"} = \@numbers;
	$self->{"sign"} = $sign;
	bless($self, $class);
	return $self;
}
sub get{
	my ($self, $key) = @_;
	return $self->{$key};
}
sub set{
	my ($self, $key, $value) = @_;
	$self->{$key} = $value;
	return $self->{$key};
}
sub rawdata{
	my ($self) = @_;
	return $self->{"rawdata"};
}
sub value{
	my ($self) = @_;
	my @numbers = @{$self->get("numbers")};
	my $number_string = "";
	foreach (@numbers){
		$number_string .= $_;
	}
	return sprintf "%s%s", $self->get("sign"), $number_string;
}
sub shrink{
	my ($self) = @_;
	my @numbers = @{$self->get("numbers")};
	my @neo_numbers = ();
	my $latch = 0;
	my $numbers_size = scalar @numbers;
	foreach ( (0..($numbers_size-1)) ){
		unless($latch){
			if($numbers[$_] eq "0"){
				next;
			}else{
				$latch = 1;
			}
		}
		push(@neo_numbers, $numbers[$_]);
	}
	$self->set("numbers", \@neo_numbers);
	return @neo_numbers;
}
sub plus{
	my ($self, $right) = @_;
	my $intermediate_value;
	my $left_sign = $self->get("sign");
	my $right_sign = $right->get("sign");
	if($left_sign ne "-" and $right_sign ne "-"){
		$intermediate_value = $self->internal_plus($right);
	}elsif($left_sign eq "-" and $right_sign eq "-"){
		$intermediate_value = $self->internal_plus($right);
		$intermediate_value->set("sign", "-");
	}else{
		my $absolute_compare = internal_absolute_compare($self, $right);
		if($absolute_compare>0){
			$intermediate_value = internal_minus($self, $right);
			if($left_sign eq "-"){
				$intermediate_value->set("sign", "-");
			}
		}else{
			$intermediate_value = internal_minus($right, $self);
			if($right_sign eq "-"){
				$intermediate_value->set("sign", "-");
			}
		}
	}
	$intermediate_value->shrink;
	return $intermediate_value;
}
sub minus{
	my ($self, $right) = @_;
	if($right->get("sign") eq "-"){
		$right->set("sign", "");
	}else{
		$right->set("sign", "-");
	}
	return plus($self, $right);
}
sub multiply{
	my ($self, $right) = @_;
	my $result = internal_multiply($self, $right);
	if($self->get("sign") ne $right->get("sign")){
		$result->set("sign", "-");
	}
	return $result;
}
sub divide{
	my ($self, $right) = @_;
	my $result = internal_divide($self, $right);
	if($self->get("sign") ne $right->get("sign")){
		$result->set("sign", "-");
	}
	return $result;
}
##### INTERNAL FUNCTIONS START #####
sub internal_absolute_compare{
	my ($left, $right) = @_;

	my @left_numbers = @{$left->get("numbers")};
	my $left_size = scalar @left_numbers;

	my @right_numbers = @{$right->get("numbers")};
	my $right_size = scalar @right_numbers;

	if($left_size != $right_size){
		return $left_size - $right_size;
	}else{
		foreach ( (0..($left_size-1)) ){
			if($left_numbers[$_] != $right_numbers[$_]){
				return $left_numbers[$_] - $right_numbers[$_];
			}
		}
		return 0;
	}
}
sub internal_plus{
	my ($left, $right) = @_;

	my @left_numbers = @{$left->get("numbers")};
	my @reversed_left_numbers = reverse @left_numbers;

	my @right_numbers = @{$right->get("numbers")};
	my @reversed_right_numbers = reverse @right_numbers;

	my @smalls = @reversed_left_numbers;
	my @bigs = @reversed_right_numbers;
	if(scalar @reversed_left_numbers > scalar @reversed_right_numbers){
		@smalls = @reversed_right_numbers;
		@bigs = @reversed_left_numbers;
	}

	my @reversed_final_numbers = ();
	my $up_number = 0;
	my $big_size = scalar @bigs;
	my $small_size = scalar @smalls;
	foreach ( (0..($big_size -1)) ){
		my $neo_number = $up_number +  $bigs[$_];
		if($_ < $small_size){
			$neo_number += $smalls[$_];
		}
		if($neo_number >= 10){
			$up_number = 1;
		}else{
			$up_number = 0;
		}
		push(@reversed_final_numbers, $neo_number % 10);
	}
	if($up_number){
		push(@reversed_final_numbers, $up_number);
	}
	my @final_numbers = reverse @reversed_final_numbers;
	my $final_rawdata = "";
	foreach (@final_numbers){
		$final_rawdata .= $_;
	}
	return Volken::ZN->new($final_rawdata);
}
sub internal_minus{
	my ($big, $small) = @_;
	
	my @big_numbers = @{$big->get("numbers")};
	my @reversed_big_numbers = reverse @big_numbers;
	my $big_size = scalar @reversed_big_numbers;
	
	my @small_numbers = @{$small->get("numbers")};
	my @reversed_small_numbers = reverse @small_numbers;
	my $small_size = scalar @reversed_small_numbers;

	my @reversed_final_numbers = ();
	foreach ( (0..($big_size -1)) ){
		my $one_value = $reversed_big_numbers[$_];
		if($_ < $small_size){
			$one_value -= $reversed_small_numbers[$_];
		}
		if($one_value < 0){
			$reversed_big_numbers[$_+1] -= 1;
			$one_value += 10;
		}
		push(@reversed_final_numbers, $one_value);
	}
	my @final_numbers = reverse @reversed_final_numbers;
	my $final_rawdata = "";
	foreach (@final_numbers){
		$final_rawdata .= $_;
	}
	return Volken::ZN->new($final_rawdata);
}
sub internal_multiply{
	my ($left, $right) = @_;

	my @left_numbers = @{$left->get("numbers")};
	my @reversed_left_numbers = reverse @left_numbers;
	my $left_size = scalar @left_numbers;

	my @right_numbers = @{$right->get("numbers")};
	my @reversed_right_numbers = reverse @right_numbers;
	my $right_size = scalar @right_numbers;

	my $rn_result = Volken::ZN->new("0");
	foreach my $left_index ( (0..($left_size-1)) ){
		foreach my $right_index ( (0..($right_size-1)) ){
			my $one_value = $reversed_left_numbers[$left_index] * $reversed_right_numbers[$right_index];
			my $size = "0"x($left_index+$right_index);
			my $one_rn = Volken::ZN->new($one_value.$size);
			$rn_result = $rn_result->plus($one_rn);
		}
	}
	return $rn_result;
}
sub internal_divide{
	my ($left, $right) = @_;
	
}
##### INTERNAL FUNCTIONS END #####

return "ZN.pm";