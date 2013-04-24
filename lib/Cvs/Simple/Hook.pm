package Cvs::Simple::Hook;
use strict;
use warnings;

# Version set by dist.ini; do not change here.
our $VERSION = '0.07_02'; # VERSION


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


    sub PERM_REQ () 
    {
        my($patt) = join '|' => keys %PERMITTED;
        return qr/$patt/;
    }


    sub permitted ($) 
    {
        return exists $PERMITTED{$_[0]} ? 1 : 0;
    }


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

__END__

=pod

=head1 NAME

Cvs::Simple::Hook - limits allowed cvs commands.

=head1 VERSION

version 0.07_02

=head1 DESCRIPTION

This module lists which CVS commands may have a callback attached.

=head1 FUNCTIONS

=head2 PERM_REQ 

  Returns a regex object consisting of all the keys from the private
%PERMITTED hash.

=head2 permitted ( $value )

Returns true if $value is present in the %PERMITTED hash; false otherwise.

=head2 get_hook ( $cmd )

Returns the value if $cmd is present as a
key in %PERMITTED, or undef otherwise.

=head1 AUTHOR

Stephen Cardie <stephenca@ls26.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Stephen Cardie.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
