#!/usr/bin/perl
package Cvs::Simple;
use strict;
use warnings;
use Carp;

sub new {
    my($class) = shift;
    my($self)  = {};
    bless $self, $class;
    return $self;
}

sub external {
    my($self) = shift;
    carp "@_";
}

sub merge {
    my($self) = shift;
    $self->external(merge => @_);
    return 'print "MERGE\n"; ';
}

sub update {
    return 'print "UPDATE\n"; ';
}

sub add {
    my($self) = shift;
    $self->external(add => @_);
    return 'print "ADD\n"; ';
}

sub commit {
    my($self) = shift;
    $self->external(commit => @_);
    return 'print "COMMIT\n"; ';
}

sub checkout {
    my($self) = shift;
    $self->external(checkout => @_);
    return 'print "CHECKOUT\n"; ';
}

sub diff {
    my($self) = shift;
    $self->external(diff => @_);
    return 'print "DIFF\n"; ';
}

1;

package Cvs::Simple::Cmd;
use strict;
use warnings;
#use Cvs::Simple;
use List::Util qw(first);
use Filter::Simple;

use vars qw($VERSION  %despatch);
$VERSION = '0.01';

BEGIN {

sub SKIP ($) {
    return 'print "Skipping ' . $_[0] . '\n";';
}

    my($cvs) = Cvs::Simple->new();

    (%despatch) = (
        add      => sub { return $cvs->add     (@_) },
        checkout => sub { return $cvs->checkout(@_) },
        external => sub { return $cvs->external(@_) },
        diff     => sub {
            # we currently cnly support -c (context) diffs.
            if($_[0]=~ /^-c\b/ ) {
                my($opt) = shift;
                return $cvs->diff(@_);
            }
            else {
                return SKIP "diff @_";
            }

        },
        update   => sub {
            # -j means a merge.
            if(first { $_ =~ /^-j/i } @_) {
                return $cvs->merge   (@_);
            }
            else {
                return $cvs->update  (@_);
            }
        },
    );

}

sub _filter {
    my($cmd) = shift;

    ($cmd) =~ s/\;$//;
    ($cmd) =~ s/^ci\b/commit/;
    ($cmd) =~ s/^co\b/checkout/;
    ($cmd) =~ s/^upd\b/update/;

    my(@cmds) = split /\s+/, $cmd;

    # Handle cvs commands first.
    # Currently we only support -d.
    if($cmds[0]=~/^-./) {
        my($opt) = shift @cmds;
        if($opt eq '-d') {
            $despatch{external}->(shift @cmds);
        }
        else {
            return SKIP $cmd;
        }
    }

    while(my($c) = shift @cmds) {
        if(exists $despatch{$c}) {
            return $despatch{$c}->(@cmds)
        }
        else {
            return SKIP $cmd;
        }
    }

    # Should never get here, so SKIP it just in case.
    return SKIP $cmd;
}

FILTER  { s/^cvs (.*)$/_filter($1)/egm; };

1;

__END__
