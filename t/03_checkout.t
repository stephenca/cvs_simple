#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new(cvsroot=>$cvsroot);

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

exit;
__END__

