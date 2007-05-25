#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new(cvsroot=>$cvsroot);

isa_ok($cvs,'Cvs::Simple');

is($cvs->checkout(), undef);
is($cvs->checkout(qw(1 2 3)), undef);

is($cvs->co(), undef);
is($cvs->co(qw(1 2 3)), undef);


exit;
__END__

