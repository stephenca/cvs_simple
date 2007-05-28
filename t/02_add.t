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

my($cwd) = cwd;

my($testdir) = $cwd;
$testdir .= '/t' unless($testdir=~m[/t\z]);

qx[$testdir/cleanup.sh $testdir];
qx[$testdir/cvs.sh $testdir];

my($repos) = "$cwd/repository";
qx[cvs -d $repos init];

isa_ok($cvs,'Cvs::Simple');

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
exit;
__END__

