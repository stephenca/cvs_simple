#!/opt/bin/perl
use strict;
use warnings;
use File::Spec::Functions qw(curdir catdir splitdir rel2abs tmpdir updir);
use Test::More qw(no_plan);
#use lib qw(../blib/lib);

BEGIN {
    use_ok(qw(Cvs::Simple::Config));
}

my($CVSBIN)=Cvs::Simple::Config::CVS_BIN;
my($CVSDIR)=tmpdir();

my($TMPL) ="repository";
my($REP)  ="cvsdir";
my($LOCAL)=sprintf(':local:%s', catdir($CVSDIR, $REP) );

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

    chdir  ( $path        ) or do {warn "Can\'t chdir to $path:$!" and return};
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
$cleardir->(catdir(tmpdir(),$REP),$cleardir);

exit;
