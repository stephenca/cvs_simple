#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Spec;
use Test::More qw(no_plan);
use Cvs::Simple;

my($status_ok) = 0;
my($status_callback) = sub {
    my($cmd,$line) = @_;
    return unless ($cmd=~m{\bstatus\b});
    if($line=~m{\A\s+working revision:\s+\d+\.\d+}i) {
        ++$status_ok;
    }
};

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');

# Set our callbacks.  
$cvs->callback(status   => $status_callback   );

SKIP: {
skip(q{Cvs not in $cvs->cvs_bin}, 1 ) unless (-x $cvs->cvs_bin );

my($cwd) = File::Spec->curdir();
unless ($cwd=~m{/t\z}) {
    chdir (File::Spec->catdir($cwd, 't'));
    $cwd = File::Spec->curdir();
}

my($clean)  = File::Spec->catfile($cwd, 'cleanup.sh');
my($cvs_sh) = File::Spec->catfile($cwd, 'cvs.sh');

my($testdir) = File::Spec->tmpdir();
my($cvs_bin) = Cvs::Simple::Config::CVS_BIN;
qx[$clean               $testdir >>/dev/null 2>&1];
qx[$cvs_sh     $cvs_bin $testdir >>/dev/null 2>&1];

my($repos) = File::Spec->catdir($testdir, 'cvsdir');
$cvs->external($repos);

my($basefile) = 'add_test_01.txt';

$cvs->co('Add');
chdir('Add') or die $!;

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

