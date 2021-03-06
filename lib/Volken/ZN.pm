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
sub clone{
	my ($self) = @_;
	my $rawdata = $self->get("rawdata");
	return Volken::ZN->new($rawdata);
}
sub shrink{
	my ($self) = @_;
	my @numbers = @{$self->get("numbers")};
	my @neo_numbers = ();
	my $latch = 0;
	my $numbers_size = scalar @numbers;
	my $neo_rawdata = "";
	$neo_rawdata = "-" if($self->get("sign") eq "-");
	foreach ( (0..($numbers_size-1)) ){
		unless($latch){
			if($numbers[$_] eq "0"){
				next;
			}else{
				$latch = 1;
			}
		}
		push(@neo_numbers, $numbers[$_]);
		$neo_rawdata .= $numbers[$_];
	}
	push(@neo_numbers, "0") if(scalar @neo_numbers == 0);
	$self->set("numbers", \@neo_numbers);
	$self->set("rawdata", $neo_rawdata);
	return $self;
}
sub get{
	my ($self, $key) = @_;
	return $self->{$key};
}
sub set{
	my ($self, $key, $value) = @_;
	$self->{$key} = $value;
	return $self;
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

sub compare{
	my ($self, $right) = @_;
	my $left_sign = $self->get("sign");
	my $right_sign = $right->get("sign");
	if($left_sign ne "-" and $right_sign ne "-"){
		return internal_absolute_compare($self, $right);
	}elsif($left_sign eq "-" and $right_sign eq "-"){
		return internal_absolute_compare($right, $self);
	}elsif($left_sign eq "-"){
		return -1;
	}else{
		return 1;
	}
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
		if($absolute_compare == 0){
			$intermediate_value = Volken::ZN->new("0");
		}elsif($absolute_compare>0){
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
	return $intermediate_value->shrink;
}
sub minus{
	my ($self, $right) = @_;
	my $clone = $right->clone;
	if($clone->get("sign") eq "-"){
		$clone->set("sign", "");
	}else{
		$clone->set("sign", "-");
	}
	return plus($self, $clone);
}
sub multiply{
	my ($self, $right) = @_;
	my $result = internal_multiply($self, $right);
	if($self->get("sign") ne $right->get("sign")){
		$result->set("sign", "-");
	}
	return $result;
}
sub quotient_and_remainder{
	my ($self, $right) = @_;
	my $left_clone = $self->clone->set("sign", "");
	my $right_clone = $right->clone->set("sign", "");
	my ($quotient, $remainder) = internal_quotient_and_remainder($left_clone, $right_clone);
	
	if($self->get("sign") ne "-" and $right->get("sign") ne "-"){
		# 둘 다 양수이면 internal q&r 의 값을 반환한다.
		return ($quotient, $remainder);
	}elsif($self->get("sign") eq "-" and $right->get("sign") eq "-"){
		# 둘 다 음수이면 몫을 크게하여 더 작게한 다음 그만큼 나머지를 작게 한다
		return (($quotient->plus(Volken::ZN->new("1"))), $right_clone->minus($remainder));
	}elsif($self->get("sign") ne "-" and $right->get("sign") eq "-"){
		return ($quotient->multiply(Volken::ZN->new("-1")), $remainder);
	}else{
		return (($quotient->plus(Volken::ZN->new("1"))->multiply(Volken::ZN->new("-1"))), $right_clone->minus($remainder));
	}
}
sub half{
	my ($self) = @_;
	my @numbers = @{$self->get("numbers")};
	my $size = scalar @numbers;
	my $half_rawdata = $self->get("sign");
	my $remain = "";
	foreach ( (0..($size-1)) ){
		my $current = int ($remain . $numbers[$_]);
		$half_rawdata .= int ($current / 2);
		if($current %2 != 0){
			$remain = "1";
		}else{
			$remain = "";
		}
	}
	return Volken::ZN->new($half_rawdata)->shrink;
}

##### INTERNAL FUNCTIONS START #####
sub internal_absolute_compare{
	my ($left, $right) = @_;

	my @left_numbers = @{$left->get("numbers")};
	my $left_size = scalar @left_numbers;

	my @right_numbers = @{$right->get("numbers")};
	my $right_size = scalar @right_numbers;

	if($left_size != $right_size){
		my $result = $left_size - $right_size;
		return ($result >0)?1:-1;
	}else{
		foreach ( (0..($left_size-1)) ){
			if($left_numbers[$_] != $right_numbers[$_]){
				my $result = $left_numbers[$_] - $right_numbers[$_];
				return ($result >0)?1:-1;
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
	my $latch = 0;
	my $final_number_size = scalar @final_numbers;
	foreach ( (0..($final_number_size-1)) ){
		unless($latch){
			if($final_numbers[$_] eq "0"){
				next;
			}else{
				$latch = 1;
			}
		}
		$final_rawdata .= $final_numbers[$_];
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
sub internal_quotient_and_remainder{
	my ($left, $right) = @_;
	my $quotient = Volken::ZN->new("0");
	my $remainder = Volken::ZN->new("0");
	my $compare_value = $left->compare($right);
	if($compare_value < 0){
		$remainder = $left->clone;
	}elsif($compare_value == 0){
		$quotient = Volken::ZN->new("1");
	}else{
		my @dividends = @{$left->get("numbers")};
		my $dividends_size = scalar @dividends;
		my @divisors = @{$right->get("numbers")};
		my $divisors_size = scalar @divisors;
		my $divisor_string = "";
		map { $divisor_string .= $_ } @divisors;
		my $divisor = Volken::ZN->new($divisor_string);
		my @divisor_multiples = ();
		foreach ( (0..9) ){
			$divisor_multiples[$_] = $divisor->multiply(Volken::ZN->new($_));
		}
		my $dividend_string = "";
		map { $dividend_string .= $_ } @dividends;
		
		my $remains_string = substr($dividend_string, 0, $divisors_size-1);;
		my $quotient_string = "";

		foreach my $quotient_index ( (0..($dividends_size-$divisors_size)) ){
			my $current_string = $remains_string . substr($dividend_string, $quotient_index + $divisors_size -1, 1);
			my $current = Volken::ZN->new($current_string)->shrink;
			my $compare = $current->compare($divisor);
			if($compare == 0){
				$quotient_string .= "1";
				$remains_string = "";
			}elsif($compare > 0){
				foreach ( (0..9) ){
					my $multiple = $divisor_multiples[9-$_];
					if($current->compare($multiple)>=0){
						$quotient_string .= (9-$_);
						$remains_string = $current->minus($multiple)->value;
						last;
					}
				}
			}else{
				$quotient_string .= "0";
				$remains_string = $current_string;
			}
		}
		$quotient = Volken::ZN->new($quotient_string)->shrink;
		$remainder = Volken::ZN->new($remains_string)->shrink;
	}
	return ($quotient, $remainder);
}
##### INTERNAL FUNCTIONS END #####

return "ZN.pm";
