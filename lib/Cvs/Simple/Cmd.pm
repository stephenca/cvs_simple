#!/usr/bin/perl
package Cvs::Simple::Cmd;
use strict;
use warnings;
use Cvs::Simple;
use Filter::Simple;

use vars qw($VERSION $SEEN_EXTERN %despatch);
$VERSION = '0.03';
$SEEN_EXTERN = '';

BEGIN {

sub SKIP ($) {
    return 'print "Skipping ' . $_[0] . '\n";';
}

sub quote (@) {
    return map { q{'} . $_ . q{'} } @_;
}

sub global_cmd ($) {
    return   defined $_[0] 
           ? $_[0] eq $SEEN_EXTERN 
           ? undef 
           : do { $SEEN_EXTERN = $_[0]; $_[0] . "\n" }
           : undef;
}

    my($cvs) = Cvs::Simple->new();

    (%despatch) = (
        status   => sub {
            my($cmd) = global_cmd shift(@_);
            my($txt) = join ',' => quote @_;
            $cmd .= sprintf('%s%s%s', '$cvs->status(',$txt, ');');
            return $cmd;
        },
        add      => sub {
            my($cmd) = global_cmd shift(@_);
            my($txt) = join ',' => quote @_;
            $cmd .= sprintf('%s%s%s', '$cvs->add(', $txt, ');');
            return $cmd;
        },
        commit   => sub {
            my($cmd) = global_cmd shift(@_);
            $cmd .= '$cvs->commit(';

            if (defined($_[0]) && $_[0]=~/^-r\b/) {
                shift(@_);
                $cmd .= shift(@_) . ',';
            }

            if(@_) {
                $cmd .= sprintf("[ %s ]);", (join '' => quote @_) );
            }
            else {
                $cmd .= ');';
            }
            return $cmd;
        },
        checkout => sub {
            my($cmd) = global_cmd shift(@_);
            shift @_ if $_[0]=~/^-r\b/;

            $cmd     .= '$cvs->co('
                     .  (join ',' => quote @_)
                     .  ');';
            return $cmd;
        },
        external => sub {
            return 
                join '' =>
                   '$cvs->external(q[' ,
                   shift @_,
                   ']);' ;
        },
        diff     => sub {
            # we currently only support -c (context) diffs.
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
            if(grep { $_ =~ /^-j/i } @_) {
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

    my($global_cmd);

    # Handle cvs commands first.
    # Currently we only support -d.
    if($cmds[0]=~/^-./) {
        my($opt) = shift @cmds;
        if($opt eq '-d') {
            $global_cmd = $despatch{external}->(shift @cmds);
        }
        else {
            return SKIP $cmd;
        }
    }

    while(my($c) = shift @cmds) {
        if(exists $despatch{$c}) {
            return $despatch{$c}->($global_cmd, @cmds)
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
