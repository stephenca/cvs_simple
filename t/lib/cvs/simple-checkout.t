#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Cvs::Simple;

my($cvs) = Cvs::Simple->new((cvs_bin=>'/tmp/foobar'));
isa_ok($cvs,'Cvs::Simple');

{
    local($@);
    eval{$cvs->checkout()};
    like($@,qr/Syntax: /);
}
{
    local($@);
    eval{$cvs->checkout(qw(1 2 3))};
    like($@,qr/Syntax: /);
}

{
    local($@);
    eval{$cvs->co()};
    like($@,qr/Syntax: /);
}

{
    local($@);
    eval{$cvs->co(qw(1 2 3))};
    like($@,qr/Syntax: /);
}

done_testing;

