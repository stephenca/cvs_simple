#!/usr/bin/perl
use strict;
use warnings;
use File::Spec::Functions qw(curdir catdir splitdir rel2abs tmpdir updir);
use Test::More qw(no_plan);
use lib qw(../blib/lib);

BEGIN {
    use_ok(qw(Cvs::Simple::Config));
}

my($CVSBIN)=Cvs::Simple::Config::CVS_BIN;
my($CVSDIR)=tmpdir();

my($TMPL) ="repository";
my($REP)  ="cvsdir";
my($LOCAL)=join '' => ':local:', catdir($CVSDIR, $REP);

my($cwd) = rel2abs(curdir());
unless((splitdir($cwd))[-1] eq 't') {
    chdir(catdir($cwd, 't'))
        or die "Failed to chdir:$!";
    $cwd = curdir();
}

system( $CVSBIN, '-d', $LOCAL, 'init' );

my(@dir)     = splitdir(rel2abs($cwd));
my($repldir) = catdir(@dir[0 .. @dir-2], $TMPL, 'Add');

chdir($repldir)
    or die "Can\'t chdir:$!";
system( $CVSBIN, '-d', $LOCAL, 'import', '-m', q[""], qw(Add V1 E2) );

chdir($cwd)
    or die "Can\'t chdir:$!";

exit;
__END__
