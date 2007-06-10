#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use Cvs::Simple;
use Cwd;

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');

my($cwd) = cwd;
unless ($cwd=~m{/t\z}) {
    chdir("$cwd/t");
    $cwd = cwd;
}

my($testdir) = '/tmp';

qx[$cwd/cleanup.sh $testdir];
qx[$cwd/cvs.sh     $testdir];

my($repos) = "$testdir/cvsdir";
$cvs->external($repos);


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

exit;
__END__

