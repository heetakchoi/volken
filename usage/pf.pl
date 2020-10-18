#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::ZN;
use Volken::PF;

foreach ( (100) ){
	printf "%s is factorized as %s\n", $_, (Volken::PF->new(Volken::ZN->new($_)))->value;
}

# my @lefts = (1..3);
# my @rights = (1..10);

# foreach my $left (@lefts){
# 	foreach my $right (@rights){
# 		my $result = Volken::PF->new($left)->multiply(Volken::PF->new($right));
# 		printf "%s * %s = %s\n", $left, $right, $result->value;
# 		printf "%s * %s = %s\n", $left, $right, $left * $right;
# 	}
# }
