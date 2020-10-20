package Volken::QN;

use strict;
use warnings;

sub new{
	my ($class, $rawdata) = @_;
	my @list = split /\//, $rawdata;
	my $numerator = $list[0];
	my $sign = "";
	if(substr($numerator, 0, 1) eq "-"){
		$sign = "-";
		$numerator = substr($numerator, 1);
	}
	my $denominator;
	if(scalar @list == 1){
		$denominator = "1";
	}else{
		$denominator = $list[1];
	}
	my $num_pf = Volken::PF->new(Volken::ZN->new($numerator));
	my $den_pf = Volken::PF->new(Volken::ZN->new($denominator));
	my $self = {};
	$self->{"rawdata"} = $rawdata;
	$self->{"num"} = \$num_pf;
	$self->{"den"} = \$den_pf;
	$self->{"sign"} = $sign;
	bless($self, $class);
	return $self;
}
sub clone{
	my ($self) = @_;
	return Volken::QN->new($self->get("rawdata"));
}
sub shrink{
	my ($self) = @_;
	my $sign = $self->get("sign");
	my $num = ${$self->{"num"}};
	my $den = ${$self->{"den"}};
	my $gcd = $num->gcd($den);

	my $neo_num = $num->divide($gcd);
	my $neo_den = $den->divide($gcd);
	my %neo_num_pfhash = %{$neo_num->get("pfhash")};
	my $expr_num = Volken::ZN->new("1");
	foreach my $key (keys %neo_num_pfhash){
		my $index = $neo_num_pfhash{$key};
		foreach ( (0..($index-1)) ){
			$expr_num = $expr_num->multiply(Volken::ZN->new($key));
		}
	}
	my %neo_den_pfhash = %{$neo_den->get("pfhash")};
	my $expr_den = Volken::ZN->new("1");
	foreach my $key (keys %neo_den_pfhash){
		my $index = $neo_den_pfhash{$key};
		foreach ( (0..($index-1)) ){
			$expr_den = $expr_den->multiply(Volken::ZN->new($key));
		}
	}
	my $rawdata = sprintf "%s%s/%s", $sign, $expr_num->value, $expr_den->value;
	return Volken::QN->new($rawdata);
}
sub value{
	my ($self) = @_;
	return $self->shrink->get("rawdata");
}

sub plus{
	my ($self, $right) = @_;
	my $left_sign = $self->get("sign");
	my $left_num = ${$self->get("num")};
	my $left_den = ${$self->get("den")};

	my $right_sign = $right->get("sign");
	my $right_num = ${$right->get("num")};
	my $right_den = ${$right->get("den")};

	my $lcm_den = $left_den->lcm($right_den);
	my $beta_den = $lcm_den->divide($left_den);
	my $alpha_den = $lcm_den->divide($right_den);

	my $left_part = $left_num->multiply($beta_den);
	my $right_part = $right_num->multiply($alpha_den);

	my $left_part_zn = $left_part->get("zn");
	my $right_part_zn = $right_part->get("zn");

	my $num_zn;
	if($left_sign ne "-" and $right_sign ne "-"){
		# (+) , (+)
		$num_zn = $left_part_zn->plus($right_part_zn);
	}elsif($left_sign eq "-" and $right_sign eq "-"){
		# (-) , (-)
		$num_zn = $left_part_zn->plus($right_part_zn)->multiply(Volken::ZN->new("-1"));
	}elsif($left_sign eq "-" and $right_sign ne "-"){
		# (-) , (+)
		my $absolute_compare = $left_part_zn->compare($right_part_zn);
		if($absolute_compare >= 0){
			$num_zn = $left_part_zn->minus($right_part_zn)->multiply(Volken::ZN->new("-1"));
		}else{
			$num_zn = $right_part_zn->minus($left_part_zn);
		}
	}elsif($left_sign ne "-" and $right_sign eq "-"){
		# (+) , (-)
		my $absolute_compare = $left_part_zn->compare($right_part_zn);
		if($absolute_compare >= 0){
			$num_zn = $left_part_zn->minus($right_part_zn);
		}else{
			$num_zn = $right_part_zn->minus($left_part_zn)->multiply(Volken::ZN->new("-1"));
		}
	}
	my $rawdata = sprintf "%s/%s", $num_zn->value, ($lcm_den->get("zn"))->value;
	return Volken::QN->new($rawdata);
}
sub minus{
	my ($self, $right) = @_;
	my $right_clone = $right->clone;
	my $right_sign = $right->get("sign");
	if($right_sign eq "-"){
		$right_clone->set("sign", "");
	}else{
		$right_clone->set("sign", "-");
	}
	return $self->plus($right_clone);
}
sub multiply{
	my ($self, $right) = @_;
	my $left_sign = $self->get("sign");
	my $left_num = ${$self->get("num")};
	my $left_den = ${$self->get("den")};

	my $right_sign = $right->get("sign");
	my $right_num = ${$right->get("num")};
	my $right_den = ${$right->get("den")};

	my $sign = "";
	$sign = "-" if($left_sign ne $right_sign);
	my $num = $left_num->multiply($right_num);
	my $den = $left_den->multiply($right_den);
	
	my $rawdata = sprintf "%s%s/%s", $sign, $num->get("zn")->value, $den->get("zn")->value;
	return Volken::QN->new($rawdata);
}
sub divide{
	my ($self, $right) = @_;
	my $left_sign = $self->get("sign");
	my $left_num = ${$self->get("num")};
	my $left_den = ${$self->get("den")};

	my $right_sign = $right->get("sign");
	my $right_num = ${$right->get("den")};
	my $right_den = ${$right->get("num")};

	my $sign = "";
	$sign = "-" if($left_sign ne $right_sign);
	my $num = $left_num->multiply($right_num);
	my $den = $left_den->multiply($right_den);

	my $rawdata = sprintf "%s%s/%s", $sign, $num->get("zn")->value, $den->get("zn")->value;
	return Volken::QN->new($rawdata);
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

return "QN.pm";

