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

sub merge {
# merge(old_rev,new_rev,file);
    my($self) = shift;
    my(@args) = @_;

    return unless (@args && scalar(@args)==3);

    my($cmd) = $self->_cmd('update');
    $cmd .= sprintf("-j%s -j%s %s", @args);

    return $self->cvs_cmd($cmd);
}

sub undo {
    goto &backout;
}

sub backout {
# Revert to previous revision of a file, i.e. backout/undo change(s).
# backout(current_rev,revert_rev,file);
    my($self) = shift;
    my(@args) = @_;

    return unless (@args && scalar(@args)==3);

    return $self->merge(@args);
}

sub external {
    my($self)  = shift;
    my($repos) = shift;

    if($repos) {
        $self->{repos} = $repos;
    }
    return $self->{repos};
}

sub _cmd {
    my($self) = shift;
    my($type) = shift;

    my($cmd) = $self->external  ?   sprintf("cvs %s %s ", $self->external,$type)
                                :   sprintf("cvs %s ",    $type);

    return $cmd;
}

sub add {
#   Can only be called as:
#    cvs add file1 [, .... , ]
    my($self) = shift;
    my(@args) = @_;

    return unless(@args);

    my($cmd) = $self->_cmd('add');

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

    my($cmd) = $self->_cmd('add -kb');

    if(@args) {
        $cmd .= join ' ' => @args;
    }

    return $self->cvs_cmd($cmd);
}

sub checkout {
# Can be called as:
#  cvs co module
#  cvs co -r tag module
#  Calling signature is checkout(tag,module) or checkout(module).
    my($self) = shift;
    my(@args) = @_;

    return unless (@args && (scalar(@args)==2 || scalar(@args)==1));

    my($cmd) = $self->_cmd('co');

    $cmd    .= @args==2         ?   sprintf("-r %s %s", @args)
                                :   sprintf("%s", @args);

    return $self->cvs_cmd($cmd);
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
# Can be called as :
# diff(file_or_dir)
# diff(tag1,tag2,file_or_dir)
    my($self) = shift;
    my(@args) = @_;

    return unless (@args && (scalar(@args)==1 || scalar(@args)==3));

    my($cmd) = $self->_cmd('diff');

    $cmd .=     @args==3    ?   sprintf("-r %s -r %s %s", @args)
                            :   sprintf("%s", @args);

    return $self->cvs_cmd($cmd);
}

sub status {
    my($self) = shift;
    my(@args) = @_;

}
sub upd {
    goto &update;
}

sub update {
# update() -> update workspace (cvs -q update -d).
# update(file) -> update file  (cvs -q update file [file ... ]).
# Doesn't permit -r.
    my($self) = shift;
    my(@args) = @_;

    my($cmd) = $self->_cmd('-q update');

    $cmd .= @args   ? join ' ' => @args
                    : '-d';

    return $self->cvs_cmd($cmd);
}

sub up2date {
# Checks workspace status. No args.
    my($self) = shift;

    my($cmd) = $self->_cmd('-nq update -d');

    return $self->cvs_cmd($cmd);
}


1;
__END__


