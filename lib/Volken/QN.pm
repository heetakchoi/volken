package Volken::QN;

use strict;
use warnings;

sub new{
	my ($class, $rawdata) = @_;
	my @list = split /\//, $rawdata;
	my $numerator = $list[0];
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
	bless($self, $class);
	return $self;
}
sub plus{
	my ($self, $right) = @_;
	my $left_num = ${$self->get("num")};
	my $left_den = ${$self->get("den")};

	my $right_num = ${$right->get("num")};
	my $right_den = ${$right->get("den")};

	my $lcm_den = $left_den->lcm($right_den);
	my $beta_den = $lcm_den->divide($left_den);
	my $alpha_den = $lcm_den->divide($right_den);

	my $left_part = $left_num->multiply($beta_den);
	my $right_part = $right_num->multiply($alpha_den);

	my $num_zn = ($left_part->get("zn"))->plus($right_part->get("zn"));
	my $rawdata = sprintf "%s/%s", $num_zn->value, ($lcm_den->get("zn"))->value;
	return Volken::QN->new($rawdata);
}
sub reduce{
	my ($self) = @_;
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
	my $rawdata = sprintf "%s/%s", $expr_num, $expr_den;
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
sub pretty_value{
	my ($self) = @_;
	my $value = sprintf "%s/%s", ${$self->{"num"}}->pretty_value, ${$self->{"den"}}->pretty_value;
	return $value;
}

return "QN.pm";

