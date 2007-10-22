#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use Test::More qw(no_plan);

BEGIN {
    use_ok('Cvs::Simple');
}

my($cwd) = File::Spec->curdir();
unless ($cwd=~m{/t\z}) {
    chdir(File::Spec->catdir($cwd, 't'));
    $cwd = File::Spec->curdir();
}
my($testdir) = File::Spec->tmpdir();
my($clean) = File::Spec->catfile($cwd, 'cleanup.pl');
qx[$clean ];

exit;

