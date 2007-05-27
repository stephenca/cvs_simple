#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;

qx[./cleanup.sh];
qx[./cvs.sh];

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new();

my($cwd) = cwd;

#my($repos) = "$cwd/repository";
#qx[cvs init $repos];
qx[cvs import 

isa_ok($cvs,'Cvs::Simple');

is($cvs->add(),     undef);
is($cvs->add_bin(), undef);

exit;
__END__

