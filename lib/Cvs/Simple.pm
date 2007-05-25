#!/usr/bin/perl
package Cvs::Simple;
use strict;
use warnings;
use Carp;
use FileHandle;

sub new {
    my($class) = shift;
    my($self) = {};
    bless $self, $class;
    return $self;
}

sub callback {
    my($self) = shift;
    my($func) = shift;

    if(defined($func)) {
        UNIVERSAL::isa(($func), 'CODE') or do {
            croak "Argument supplied to callback() should be a coderef.";
        };
        $self->{callback} = $func;
    }

    return $self->{callback};
}

sub cvs_cmd {
    my($self) = shift;
    my($cmd)  = shift;

    return unless (defined($cmd) && $cmd);

    my($fh) = FileHandle->new("$cmd|");
    defined($fh) or croak "Failed to open $cmd:$!";

    while(<$fh>) {
        if($self->callback) {
            $self->callback->($_);
        } 
        else {
            print STDOUT $_;
        }
    }

    $fh->close;

    return 1;
}

sub external {
    my($self)  = shift;
    my($repos) = shift;

    if($repos) {
        $self->{repos} = $repos;
    }
    return $self->{repos};
}

sub add {
#   Can only be called as:
#    cvs add file1 [, .... , ]
    my($self) = shift;
    my(@args) = @_;

    return unless(@args);

    my($cmd) = $self->external  ?   sprintf("cvs %s add ", $self->external)
                                :   sprintf("cvs add ");

    if(@args) {
        $cmd .= join ' ' => @args;
    }

    return $self->cvs_cmd($cmd);
}

sub add_bin {
# Can only be called as :
#    cvs add -kb file1 [, .... , ]
    my($self) = shift;
    my(@args) = @_;

    return unless (@args);

    my($cmd) = $self->external  ?   sprintf("cvs %s add -kb", $self->external)
                                :   sprintf("cvs add -kb ");

    if(@args) {
        $cmd .= join ' ' => @args;
    }

    return $self->cvs_cmd($cmd);
}

sub checkout {


}

sub co {
    goto &checkout;
}

sub commit {
    my($self) = shift;
    my(@args) = @_;
}

sub ci {
    goto &commit;
}

sub diff {
    my($self) = shift;
    my(@args) = @_;

}

sub status {
    my($self) = shift;
    my(@args) = @_;

}

sub update {
    my($self) = shift;
    my(@args) = @_;

}


1;
__END__


