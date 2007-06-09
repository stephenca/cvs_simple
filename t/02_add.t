#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);
#use lib '../lib';
use Cvs::Simple;
use File::Copy;

my($add_ok) = 0;
my($callback) = sub {
    return unless ($_[0]=~/\bupdate\b/);
    local($_) = $_[1];
    if($_[1]=~/A add_test_02.txt/) {
        ++$add_ok;
    }
};

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');
$cvs->callback($callback);

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

$cvs->co('Add');
File::Copy::copy('Add/add_test_01.txt', 'Add/add_test_02.txt');
chdir('Add') or die $!;
$cvs->add('add_test_02.txt');
$cvs->up2date;
is($add_ok,1);

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

