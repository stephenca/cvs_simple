#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;
use File::Copy;

qx[./cleanup.sh];
qx[./cvs.sh];

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new();

my($cwd) = cwd;

my($repos) = "$cwd/repository";
qx[cvs -d $repos init];

isa_ok($cvs,'Cvs::Simple');

is($cvs->add(),     undef);
is($cvs->add_bin(), undef);

exit;
__END__

