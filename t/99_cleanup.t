#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);

BEGIN {
    use_ok('Cvs::Simple');
}

my($cwd) = cwd;
unless ($cwd=~m{/t\z}) {
    chdir("$cwd/t");
    $cwd = cwd;
}
my($testdir) = '/tmp';
qx[$cwd/cleanup.sh $testdir];

exit;

