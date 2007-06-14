#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use Cvs::Simple;
use Cwd;

my($cvs) = Cvs::Simple->new();
$cvs->cvs_bin($ENV{CVS_BIN});

isa_ok($cvs,'Cvs::Simple');

my($cwd) = cwd;
unless ($cwd=~m{/t\z}) {
    chdir("$cwd/t");
    $cwd = cwd;
}

my($testdir) = '/tmp';
my($cvsbin)  = Cvs::Simple::Config::CVS_BIN;
qx[$cwd/cleanup.sh         $testdir];
qx[$cwd/cvs.sh     $cvsbin $testdir];

my($repos) = "$testdir/cvsdir";
$cvs->external($repos);

{
my($cvs) = Cvs::Simple->new();
{
local($@);
eval{$cvs->commit(qw(1 2 3 4 5))};
like($@,qr/Syntax: /, 'Too many args');
}
{
local($@);
eval{$cvs->commit(1, 'filename')};
like($@,qr/Syntax: /);
}

{
local($@);
eval{$cvs->ci(qw(1 2 3 4 5))};
like($@,qr/Syntax: /, 'Too many args');
}
{
local($@);
eval{$cvs->ci(1, 'filename')};
like($@,qr/Syntax: /);
}
}

exit;
__END__

