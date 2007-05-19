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


}

sub cvs_cmd {
    my($self) = shift;
    my($cmd)  = shift;

    return unless (defined($cmd) && $cmd);

    my($fh) = FileHandle->new("$cmd|");
    defined($fh) or croak "Failed to open $cmd:$!";

    

    while(<$fh>) {
        
    }

}

sub add {

}

sub add_bin {


}

sub checkout {


}

sub co {
    goto &checkout;
}

sub commit {

}

sub ci {
    goto &commit;
}

sub diff {

}

sub status {


}

sub update {


}


1;
__END__


