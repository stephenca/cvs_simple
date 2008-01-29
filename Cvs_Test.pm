package Cvs_Test;
use strict;
use warnings;
use File::Spec::Functions qw(curdir catdir splitdir rel2abs tmpdir updir);
use Cvs::Simple::Config;
use Cwd;

sub CVSBIN () { return Cvs::Simple::Config::CVS_BIN        }
sub CVSDIR () { return tmpdir()                            }
sub TMPL   () { 'repository'                               }
sub REP    () { 'cvsdir'                                   }
sub LOCAL  () { sprintf(':local:%s', catdir(CVSDIR, REP) ) }

sub cvs_make {
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

sub cvs_clean {

    my($cwd) = rel2abs(curdir());
    unless((splitdir($cwd))[-1] eq 't') {
        chdir(catdir($cwd, 't'))
            or die "Failed to chdir:$!";
        $cwd = curdir();
    }

    chdir($cwd) or die "Can\'t chdir to $cwd:$!";

    my($cleardir) = sub {
        my($path) = shift;
        my($exec) = shift;

        my($DIR);

        chdir  ( $path        ) or do {
            warn "Can\'t chdir to $path:$!" and return };
        opendir( $DIR, curdir ) or die "Can\'t openddir:$!";

        my(@dir) ;
        for my $t ( grep { $_!~/\A\.+\z/ } readdir $DIR ) {
            if( -f $t ) {
                unlink catdir(curdir(),$t) or die "Can't unlink $t:$!";
            }
            elsif ( -d $t ) {
                my($d) = catdir( rel2abs(curdir), $t );
                $exec->( $d, $exec );
            }
            else {
                die "Don't know what to do with $t";
            }
        }

        closedir $DIR;
        chdir(updir);
        rmdir($path) or die "Can\'t rmdir $path:$!";
    };

    $cleardir->('Add',                $cleardir);
    $cleardir->(catdir(tmpdir(),REP),$cleardir);

    return;
}

1;

__END__


