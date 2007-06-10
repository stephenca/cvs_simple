#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Test::More qw(no_plan);
use Cvs::Simple;
use File::Copy;

my($add_ok) = 0;
my($add_callback) = sub {
    return unless ($_[0]=~/\bupdate\b/);
    local($_) = $_[1];
    if($_[1]=~/A add_test_02.txt/) {
        ++$add_ok;
    }
};

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');
$cvs->callback($add_callback);

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

diag('Add a file');
$cvs->co('Add');
File::Copy::copy('Add/add_test_01.txt', 'Add/add_test_02.txt')
    or die "Can\'t copy file";
chdir('Add') or die $!;
$cvs->add('add_test_02.txt');
$cvs->up2date;
is($add_ok,1);

diag('Simple commit.');
my($commit_ok) = 0;
my($commit_callback) = sub {
    my($cmd,$arg) = @_;
    return unless ($cmd =~/\bcommit\b/);
    $arg=~/revision: \d\.\d/ and ++$commit_ok;
};
$cvs->callback($commit_callback);
$cvs->commit;
is($commit_ok,1);

diag('File list commit');
File::Copy::copy('add_test_01.txt', 'add_test_03.txt')
    or die "Can\'t copy files";
$cvs->add   (  'add_test_03.txt'  );
$cvs->commit([ 'add_test_03.txt' ]);
is($commit_ok,2);

diag('Force revision number');
File::Copy::copy('add_test_01.txt', 'add_test_04.txt')
    or die "Can\'t copy files:$!";
$cvs->add('add_test_04.txt');
$cvs->commit('2.0', [ 'add_test_04.txt' ]);
is($commit_ok,3);

diag('Force revision on all.');
$cvs->commit('3.0');
is($commit_ok,7);
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

