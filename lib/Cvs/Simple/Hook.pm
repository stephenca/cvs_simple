package Cvs::Simple::Hook;
use strict;
use warnings;

# Version set by dist.ini; do not change here.
# VERSION

=pod

=head1 DESCRIPTION

This module lists which CVS commands may have a callback attached.

=head1 FUNCTIONS

=cut

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

=head2 PERM_REQ 

  Returns a regex object consisting of all the keys from the private
%PERMITTED hash.

=cut

    sub PERM_REQ () 
    {
        my($patt) = join '|' => keys %PERMITTED;
        return qr/$patt/;
    }

=head2 permitted ( $value )

Returns true if $value is present in the %PERMITTED hash; false otherwise.

=cut

    sub permitted ($) 
    {
        return exists $PERMITTED{$_[0]} ? 1 : 0;
    }

=head2 get_hook ( $cmd )

Returns the value if $cmd is present as a
key in %PERMITTED, or undef otherwise.

=cut

    sub get_hook ($) 
    {
        my($cmd)      = shift;

        my($PERM_REQ) = PERM_REQ;

        if(($cmd)=~/\b($PERM_REQ)\b/) {
            return $1;
        } else {
            return;
        }
    }
}

1;

# ABSTRACT: limits allowed cvs commands.
