package Volken::PF;

use strict;
use warnings;

sub new{
	my ($class, $zn) = @_;
	$zn = Volken::ZN->new("1") unless(defined($zn));
	my $self = {};
	$self->{"zn"} = $zn;
	my $zn_clone = $zn->clone;
	internal_prime_factorization($self, $zn_clone);
	bless($self, $class);
	return $self;
}
sub shrink{
	my ($self) = @_;
	my %pfhash = %{$self->get("pfhash")};
	my $expr = Volken::ZN->new("1");
	foreach my $key (keys %pfhash){
		if($pfhash{$key} == 0){
			delete $pfhash{$key};
		}else{
			my $index = $pfhash{$key};
			foreach ( (0..($index-1)) ){
				$expr = $expr->multiply(Volken::ZN->new($key));
			}
		}
	}
	$self->set("zn", $expr);
	return $self;
}
sub try_to_divide{
	my ($left, $right) = @_;
	# return try_to_divide_use_bisection($left, $right);
	return try_to_divide_use_quotient_and_remainder($left, $right);
}
sub try_to_divide_use_quotient_and_remainder{
	my ($dividend, $divisor) = @_;
	my ($quotient, $remainder) = $dividend->quotient_and_remainder($divisor);
	if($remainder->value eq "0"){
		$quotient;
	}else{
		return undef;
	}
}
sub try_to_divide_use_bisection{
	my ($zn, $dc) = @_;
	my @zn_numbers = @{$zn->get("numbers")};
	my @dc_numbers = @{$dc->get("numbers")};
	my $zn_size = scalar @zn_numbers;
	my $dc_size = scalar @dc_numbers;
	my $diff_size = $zn_size - $dc_size;
	my $up_guess_start = 100*$diff_size;
	my $low_guess_start = 10*$diff_size;
	if($diff_size == 0){
		$up_guess_start = 10;
		$low_guess_start = 1;
	}
	my $up_guess = Volken::ZN->new($up_guess_start);
	my $low_guess = Volken::ZN->new($low_guess_start);

	# printf "try_to_divide zn: %s dc: %s\n", $zn->value, $dc->value;
	while(1){
		my $up = $dc->multiply($up_guess);
		my $low = $dc->multiply($low_guess);
		my $up_compare = $zn->compare($up);
		my $low_compare = $zn->compare($low);
		# printf "%s < %s <%s\n", $low->value, $zn->value, $up->value;
		if($up_compare >0){
			# print "> 너무 크다\n";
			$low_guess = $up_guess;
			$up_guess = $up_guess->multiply(Volken::ZN->new("2"));
		}elsif($low_compare <0){
			# print "> 너무 작다\n";
			$up_guess = $low_guess;
			$low_guess = $low_guess->half;
		}elsif($up_compare == 0){
			# printf "> 찾았다 %s = %s * %s\n", $zn->value, $dc->value, $up_guess->value;
			return $up_guess;
		}elsif($low_compare == 0){
			# printf "> 찾았다 %s = %s * %s\n", $zn->value, $dc->value, $low_guess->value;
			return $low_guess;
		}else{
			# print "> 안에 들어왔다\n";
			if(($up_guess->minus($low_guess))->value < 2){
				my $neo = $up_guess->minus($low_guess);
				# print "> 답이 없다\n";
				return undef;
			}
			my $middle_guess = ($up_guess->plus($low_guess))->half;
			my $middle = $dc->multiply($middle_guess);
			my $middle_compare = $zn->compare($middle);
			# printf "> 중간값 %s\n", $middle->value;
			if($middle_compare == 0){
				# printf ">> 찾았다 %s = %s * %s\n", $zn->value, $dc->value, $middle_guess->value;;
				return $middle_guess;
			}elsif($middle_compare > 0){
				# print ">> 하한을 중간값으로 높인다\n";
				$low_guess = $middle_guess;
			}elsif($middle_compare < 0){
				# print ">> 상한을 중간값으로 낮춘다\n";
				$up_guess = $middle_guess;
			}
		}
	}
}
sub value{
	my ($self) = @_;
	my %pfhash = %{$self->{"pfhash"}};
	my $value = "";
	foreach (sort {$a <=> $b} keys %pfhash){
		$value .= sprintf "%s^%s ", $_, $pfhash{$_};
	}
	$value =~ s/\s+$//;
	$value = "1" if($value eq "");
	return $value;
}
sub internal_prime_factorization{
	my ($self, $clone) = @_;
	if($clone->get("sign") eq "-"){
		$clone->set("sign", "");
	}
	my %pfhash = ();
	my $zn_1 = Volken::ZN->new("1");
	my $divisor = Volken::ZN->new("0");
	my $try_again_flag = 0;
	while($clone->compare($zn_1) != 0){
		if($try_again_flag){
			
		}else{
			$divisor = next_prime_candidate($divisor);
		}
		my $result = try_to_divide($clone, $divisor);
		if(defined($result)){
			my $divisor_value = $divisor->value;
			if(defined($pfhash{$divisor_value})){
				$pfhash{$divisor_value} += 1;
			}else{
				$pfhash{$divisor_value} = 1;
			}
			$clone = $result;
			$try_again_flag = 1;
		}else{
			$try_again_flag = 0;
		}
	}
	$self->{"pfhash"} = \%pfhash;
}

sub multiply{
	my ($self, $right) = @_;
	my %left_pfhash = %{$self->get("pfhash")};
	my %right_pfhash = %{$right->get("pfhash")};
	my %neo_pfhash = ();
	foreach my $key (keys %left_pfhash){
		if(defined($right_pfhash{$key})){
			$neo_pfhash{$key} = $left_pfhash{$key} + $right_pfhash{$key};
		}else{
			$neo_pfhash{$key} = $left_pfhash{$key};
		}
	}
	foreach my $key (keys %right_pfhash){
		unless(defined($left_pfhash{$key})){
			$neo_pfhash{$key} = $right_pfhash{$key};
		}
	}
	my $multiple = Volken::PF->new->set("pfhash", \%neo_pfhash);
	return $multiple->shrink;
}
sub divide{
	my ($self, $right) = @_;
	my %left_pfhash = %{$self->get("pfhash")};
	my %right_pfhash = %{$right->get("pfhash")};
	my %neo_pfhash = ();
	foreach my $key (keys %left_pfhash){
		if(defined($right_pfhash{$key})){
			$neo_pfhash{$key} = $left_pfhash{$key} - $right_pfhash{$key};
		}else{
			$neo_pfhash{$key} = $left_pfhash{$key};
		}
	}
	foreach my $key (keys %right_pfhash){
		unless(defined($left_pfhash{$key})){
			$neo_pfhash{$key} = - $right_pfhash{$key};
		}
	}
	my $division = Volken::PF->new->set("pfhash", \%neo_pfhash);
	return $division->shrink;
}
sub gcd{
	my ($self, $right) = @_;
	my %left_pfhash = %{$self->get("pfhash")};
	my %right_pfhash = %{$right->get("pfhash")};
	my %neo_pfhash = ();
	foreach my $key (keys %left_pfhash){
		if(defined($right_pfhash{$key})){
			$neo_pfhash{$key} = ($left_pfhash{$key} - $right_pfhash{$key}>0)?($right_pfhash{$key}):($left_pfhash{$key});
		}
	}
	my $greatest_common_divisor = Volken::PF->new->set("pfhash", \%neo_pfhash);
	return $greatest_common_divisor->shrink;
}
sub lcm{
	my ($self, $right) = @_;
	my %left_pfhash = %{$self->get("pfhash")};
	my %right_pfhash = %{$right->get("pfhash")};
	my %neo_pfhash = ();
	foreach my $key (keys %left_pfhash){
		if(defined($right_pfhash{$key})){
			$neo_pfhash{$key} = ($left_pfhash{$key} - $right_pfhash{$key}>0)?($left_pfhash{$key}):($right_pfhash{$key});
		}else{
			$neo_pfhash{$key} = $left_pfhash{$key};
		}
	}
	foreach my $key (keys %right_pfhash){
		unless(defined($left_pfhash{$key})){
			$neo_pfhash{$key} = $right_pfhash{$key};
		}
	}
	my $least_common_multiple = Volken::PF->new->set("pfhash", \%neo_pfhash);
	return $least_common_multiple->shrink;
}
sub next_prime_candidate{
	my ($base) = @_;
	return Volken::ZN->new("2") unless(defined($base));
	if($base->value < 2){
		return Volken::ZN->new("2");
	}else{
		my $result = try_to_divide($base, Volken::ZN->new("2"));
		if(defined($result)){
			return $base->plus(Volken::ZN->new("1"));
		}else{
			return $base->plus(Volken::ZN->new("2"));
		}
	}
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

return "Volken::PF";
