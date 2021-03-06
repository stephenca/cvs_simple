#!/usr/bin/env perl
use strict;
use warnings;

use Directory::Scratch;

use File::Copy;
use File::Spec::Functions qw(catdir curdir splitdir devnull tmpdir);
use File::Which;

use Test::Most;

use Cvs::Simple;
use Cwd;

use Scalar::Util qw();

use lib qw(t/lib);
use Cvs_Test;

my($status_ok) = 0;
my(@stat_line);
my($status_callback) = sub {
    my($cmd,$line) = @_;
    return unless ($cmd=~m{\bstatus\b});

    if($line=~m{\A\s+working revision:\s+\d+\.\d+}i) {
        ++$status_ok;
    }
    push @stat_line, $line;
};

my $cvs_bin = which('cvs');
my($cvs) = Cvs::Simple->new((cvs_bin=>$cvs_bin));
isa_ok($cvs,'Cvs::Simple','ISA Cvs::Simple');

# Set our callbacks.  
$cvs->callback(status   => $status_callback   );

is(Scalar::Util::reftype($cvs->callback('status')), 'CODE','Callback OK');

SKIP: {
    skip(q{Cvs not in $cvs->cvs_bin}, 1 ) unless (defined($cvs->cvs_bin) && -x $cvs->cvs_bin);

    my($cwd) = getcwd();

    unless((splitdir($cwd))[-1] eq 't') {
        chdir (File::Spec->catdir($cwd, 't'));
        $cwd = catdir($cwd, 't');
    }
    chdir($cwd) or die "Can\'t chdir to $cwd:$!";
    my $basedir = $cwd;

    my($testdir) = tmpdir();
    my($devnull) = devnull();
    Cvs_Test::cvs_clean($cwd);
    Cvs_Test::cvs_make($cwd);

    my($repos) = catdir($testdir, 'cvsdir');
    $cvs->external($repos);

    my($basefile) = 'add_test_01.txt';

    my $tmpdir = Directory::Scratch->new();

    chdir("$tmpdir")
        or die( "Can't chdir to tmpdir $tmpdir:$!");

    $cvs->co('Add');
    $cwd = getcwd();
    chdir(catdir($cwd,'Add')) or die $!;

    $cvs->status($basefile);
    is($status_ok,1);

    chdir($basedir);

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
