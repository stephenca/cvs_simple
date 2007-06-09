#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

my($cvs) = Cvs::Simple->new();

isa_ok($cvs,'Cvs::Simple');

{
local($@);
eval{$cvs->merge()};
like($@,qr/Syntax: /);
}
{
local($@);
eval{$cvs->merge(qw(1))};
like($@,qr/Syntax: /);
}

exit;
__END__

