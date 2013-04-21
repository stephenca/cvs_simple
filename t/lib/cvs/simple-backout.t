#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Cvs::Simple;

my($cvs) = Cvs::Simple->new((cvs_bin=>'/tmp/foobar'));

isa_ok($cvs,'Cvs::Simple');

{
    local($@);
    eval{$cvs->backout()};
    like($@,qr/Syntax: /);
}
{
    local($@);
    eval{$cvs->backout(qw(1))};
    like($@,qr/Syntax: /);
}

done_testing;
