#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);
use lib '../lib';
use Cvs::Simple;
use File::Copy;

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');

my($cwd) = cwd;

my($testdir) = '/tmp';
$cwd .= '/t' unless($cwd=~m[/t\z]);

qx[$cwd/cleanup.sh $testdir];
qx[$cwd/cvs.sh     $testdir];

my($repos) = "$testdir/cvsdir";
qx[cvs -d $repos co Add];
File::Copy::copy('Add/add_test_01.txt', 'Add/add_test_02.txt');

{
local($@);
eval{$cvs->add()};
like($@, qr/Syntax:/);
}
{
local($@);
eval{$cvs->add_bin()};
like($@, qr/Syntax:/);
}

$cvs->add('Add/add_test_02.txt');

exit;
__END__

