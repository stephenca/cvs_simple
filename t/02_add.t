#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new();

#my($repos) = '../repository';
#qx[cvs_local init $repos];

isa_ok($cvs,'Cvs::Simple');

is($cvs->add(), undef);
is($cvs->add_bin(), undef);

exit;
__END__

