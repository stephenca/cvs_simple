#!/usr/bin/env perl
use strict;
use warnings;

use Directory::Scratch;

use File::Copy;
use File::Spec::Functions qw(catfile catdir   curdir 
                             tmpdir  splitdir rel2abs);

use File::Which;
use Test::Most;

use Cvs::Simple;
use Cwd;

use lib qw(t/lib);
use Cvs_Test;

my $cvs_bin = which('cvs');

my($add_ok,$commit_ok,$update_ok,$merge_ok) = (0,0,0,0);
my($add_callback) = sub {
    return unless ($_[0]=~/\bupdate\b/);
    local($_) = $_[1];
    if($_[1]=~/A add_test_02.txt/) {
        ++$add_ok;
    }
};

my($commit_callback) = sub {
    my($cmd,$arg) = @_;
    return unless ($cmd =~/\bcommit\b/);
    $arg=~/revision: \d\.\d/ and ++$commit_ok;
};

my($update_callback) = sub {
    my($cmd,$arg) = @_;
    return unless ($cmd =~ /\bupdate\b/);
    if($cmd=~/\-j/) {
        
    }
    else {
        $arg=~/U add_test_0[34].txt/ and ++$update_ok;
    }
};

my($cvs) = Cvs::Simple->new((cvs_bin=>$cvs_bin));
isa_ok($cvs,'Cvs::Simple');

# Set our callbacks.  Note that the 'add' callback
#  is actually an 'update'.
$cvs->callback(update   => $add_callback   );
$cvs->callback(commit   => $commit_callback);

SKIP: {
skip(q{Cvs not in $cvs->cvs_bin}, 7 ) unless (defined($cvs->cvs_bin) && -x $cvs->cvs_bin );

my($cwd) = getcwd();

unless((splitdir($cwd))[-1] eq 't') {
    $cwd = catfile($cwd, 't');
}
chdir($cwd) or die "Can\'t chdir to $cwd:$!";
my $basedir = $cwd;

my($cvs_bin) = $cvs_bin;
Cvs_Test::cvs_clean(rel2abs($cwd));
Cvs_Test::cvs_make(rel2abs($cwd));

my($testdir) = tmpdir();
my($repos)   = catdir($testdir, 'cvsdir');
$cvs->external($repos);

is($cvs->external, $repos);

my($basefile) = 'add_test_01.txt';

my $tmpdir = Directory::Scratch->new();

chdir("$tmpdir")
  or die("Cannot chdir to tmp $tmpdir:$!");

diag('Add a file');
$cvs->co('Add');
File::Copy::copy(
    catfile('Add',$basefile), 
    catfile('Add','add_test_02.txt'))
    or die "Can\'t copy file $basefile:$!";
chdir('Add') or die $!;
$cvs->add('add_test_02.txt');
$cvs->up2date;
is($add_ok,1);

diag('Simple commit.');
$cvs->commit;
is($commit_ok,1);

diag('File list commit');
File::Copy::copy($basefile, 'add_test_03.txt')
    or die "Can\'t copy files";
$cvs->add   (  'add_test_03.txt'  );
$cvs->commit([ 'add_test_03.txt' ]);
is($commit_ok,2);

diag('Force revision number');
File::Copy::copy($basefile, 'add_test_04.txt')
    or die "Can\'t copy files:$!";
$cvs->add('add_test_04.txt');
$cvs->commit('2.0', [ 'add_test_04.txt' ]);
is($commit_ok,3);

diag('Force revision on all.');
$cvs->commit('3.0');
is($commit_ok,7);

# Remove a file and do an update.
unlink('add_test_04.txt');
$cvs->unset_callback('update');
$cvs->callback(update => $update_callback);
$cvs->update;

is($update_ok,1);

unlink('add_test_03.txt');
$cvs->update('add_test_03.txt');

is($update_ok,2);

chdir($basedir)
  or die("Cannot chdir to $basedir:$!");

} # End of skip

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

done_testing;
