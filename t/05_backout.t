#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests=>4;
use Test::NoWarnings;
use Cvs::Simple;

my($cvs) = Cvs::Simple->new();

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

exit;
__END__

