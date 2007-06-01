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
eval{
chdir("$cwd/t");
};

my($testdir) = '/tmp';

qx[./cleanup.sh $testdir];
qx[./cvs.sh     $testdir];
qx[./02.sh];

my($repos) = "$testdir/cvsdir";
$cvs->external($repos);
File::Copy::copy('Add/add_test_01.txt', 'Add/add_test_02.txt');
chdir('Add') or die $!;
$cvs->add('add_test_02.txt');

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

