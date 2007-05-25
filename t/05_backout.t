#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new(cvsroot=>$cvsroot);

isa_ok($cvs,'Cvs::Simple');

is($cvs->backout(), undef);
is($cvs->backout(qw(1)), undef);

exit;
__END__

