#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;

use Test::Most;

use Cvs::Simple;

{
    my($cvs) = Cvs::Simple->new((cvs_bin=>'/tmp/foobar'));
    isa_ok($cvs,'Cvs::Simple');
    {
        local($@);
        eval{$cvs->commit(qw(1 2 3 4 5))};
        like($@,qr/Syntax: /, 'Too many args');
    }
    {
        local($@);
        eval{$cvs->commit(1, 'filename')};
        like($@,qr/Syntax: /);
    }

    {
        local($@);
        eval{$cvs->ci(qw(1 2 3 4 5))};
        like($@,qr/Syntax: /, 'Too many args');
    }
    {
        local($@);
        eval{$cvs->ci(1, 'filename')};
        like($@,qr/Syntax: /);
    }
}

done_testing;
