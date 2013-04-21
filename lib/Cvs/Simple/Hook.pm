package Cvs::Simple::Hook;
use strict;
use warnings;

# Version set by dist.ini; do not change here.
# VERSION

{
my(%PERMITTED) = (
    'All'      => '',
    'add'      => '',
    'checkout' => '',
    'commit'   => '',
    'update'   => '',
    'diff'     => '',
    'status'   => '',
);
sub PERM_REQ () {
    my($patt) = join '|' => keys %PERMITTED;
    return qr/$patt/;
}

sub permitted ($) {
    return exists $PERMITTED{$_[0]} ? 1 : 0;
}

sub get_hook ($) {
    my($cmd)      = shift;

    my($PERM_REQ) = PERM_REQ;

    if(($cmd)=~/\b($PERM_REQ)\b/) {
        return $1;
    }
    else {
        return;
    }
}

}

1;

# ABSTRACT: limits allowed cvs commands.
