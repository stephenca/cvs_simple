#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Spec;
use Test::More tests=>5;
use Cvs::Simple;
use Scalar::Util qw(reftype);

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

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple','ISA Cvs::Simple');

# Set our callbacks.  
$cvs->callback(status   => $status_callback   );

is(reftype($cvs->callback('status')), 'CODE','Callback OK');

SKIP: {
skip(q{Cvs not in $cvs->cvs_bin}, 1 ) unless (-x $cvs->cvs_bin );

my($cwd) = File::Spec->curdir();
unless((File::Spec->splitdir($cwd))[-1] eq 't') {
    chdir (File::Spec->catdir($cwd, 't'));
    $cwd = File::Spec->curdir();
}

my($clean)   = File::Spec->catfile($cwd, 'cleanup.pl');
my($cvs_sh)  = File::Spec->catfile($cwd, 'cvs.pl');

my($testdir) = File::Spec->tmpdir();
my($cvs_bin) = Cvs::Simple::Config::CVS_BIN;
my($devnull) = File::Spec->devnull();
qx[$clean ];
qx[$cvs_sh];

my($repos) = File::Spec->catdir($testdir, 'cvsdir');
$cvs->external($repos);

my($basefile) = 'add_test_01.txt';

$cvs->co('Add');
chdir(File::Spec->catdir($cwd,'Add')) or die $!;

$cvs->status($basefile);
is($status_ok,1);

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

exit;
__END__

