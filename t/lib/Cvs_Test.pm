package Cvs_Test;
use strict;
use warnings;

use Cwd;

use File::Path;
use File::Spec::Functions qw(curdir catdir splitdir rel2abs tmpdir updir);
use File::Which;

# VERSION

sub CVSBIN () { which('cvs');                              }
sub CVSDIR () { return tmpdir()                            }
sub TMPL   () { 'repository'                               }
sub REP    () { 'cvsdir'                                   }
sub LOCAL  () { sprintf(':local:%s', catdir(CVSDIR, REP) ) }

sub cvs_make ($) {
    my($cwd) = shift;

    unless((splitdir($cwd))[-1] eq 't') {
        $cwd = rel2abs(catdir($cwd, 't'));
    }
    chdir($cwd) or die "Failed to chdir to $cwd:$!";

    system( CVSBIN, '-d', LOCAL, 'init' );

    my(@dir)     = splitdir(rel2abs($cwd));
    my($repldir) = catdir(@dir[0 .. @dir-2], TMPL, 'Add');

    chdir($repldir)
       or die "Can\'t chdir:$!";
    system( CVSBIN, '-d', LOCAL, 'import', '-m', q[""], qw(Add V1 E2) );

    chdir($cwd)
        or die "Can\'t chdir:$!";

    return;
}

sub cvs_clean (;$) {

    my($cwd) = shift || rel2abs(curdir());
    unless((splitdir($cwd))[-1] eq 't') {
        chdir(catdir($cwd, 't'))
            or die "Failed to chdir:$!";
        $cwd = curdir();
    }

    chdir($cwd) or die "Can\'t chdir to $cwd:$!";

    rmtree([ 'Add', catdir(tmpdir(),REP) ]);

    return;
}

1;


