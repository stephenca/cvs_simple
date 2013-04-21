#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Cvs::Simple;

my($cvs) = Cvs::Simple->new((cvs_bin=>'/tmp/foobar'));

isa_ok($cvs,'Cvs::Simple');

{
    local($@);
    eval{$cvs->diff()};
    like($@,qr/Syntax: /);
}

{
    local($@);
    eval{$cvs->diff(qw(1 2 3 4))};
    like($@,qr/Syntax: /);
}

done_testing;

