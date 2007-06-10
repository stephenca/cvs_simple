#!/usr/bin/perl
package Cvs::Simple;
use strict;
use warnings;
use Carp;
use FileHandle;

our $VERSION = 0.01;

sub new {
    my($class) = shift;
    my($self) = {};
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my($self) = shift;
    my(%args) = @_;

    if(exists $args{cvs_bin}) {
        $self->cvs_bin($args{cvs_bin});
    }
    else {
        $self->cvs_bin('/usr/bin/cvs');
    }

    if(exists $args{external}) {
        $self->external($args{external});
    }

    if(exists $args{callback}) {
        $self->callback($args{callback});
    }
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

sub cvs_bin {
    my($self) = shift;
    my($bin)  = shift;

    if($bin) {
        $self->{cvs_bin} = $bin;
    }

    return $self->{cvs_bin};
}

sub cvs_cmd {
    my($self) = shift;
    my($cmd)  = shift;

    croak "Syntax: cvs_cmd(cmd)" unless (defined($cmd) && $cmd);

    my($fh) = FileHandle->new("$cmd 2>&1 |");
    defined($fh) or croak "Failed to open $cmd:$!";

    while(<$fh>) {
        if($self->callback) {
            $self->callback->($cmd,$_);
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

    croak "Syntax: merge(old_rev,new_rev,file)"
        unless (@args && scalar(@args)==3);

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

    croak "Syntax: backout(current_rev,revert_rev,file)"
        unless (@args && scalar(@args)==3);

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

    my($cvs)  = $self->cvs_bin;

    my($cmd) = 
        $self->external  ?   sprintf("%s -d %s %s ", $cvs,$self->external,$type)
                         :   sprintf("%s %s ",       $cvs,$type);

    return $cmd;
}

sub add {
#   Can only be called as:
#    cvs add file1 [, .... , ]
    my($self) = shift;
    my(@args) = @_;

    croak "Syntax: add(file1, ...)" unless(@args);

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

    croak "Syntax: add_bin(file1, ...)" unless (@args);

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

    croak "Syntax: co(tag,module) or co(module)"
        unless (@args && (scalar(@args)==2 || scalar(@args)==1));

    my($cmd) = $self->_cmd('co');

    $cmd    .= @args==2         ?   sprintf("-r %s %s", @args)
                                :   sprintf("%s", @args);

    return $self->cvs_cmd($cmd);
}

sub co {
    goto &checkout;
}

sub _pattern {
    return join '' => ('%s ' x @{$_[0]});
}

sub commit {
# Can be called as :
# commit()
# commit([file_list])
# commit(tag1)
# commit(tag1, [file_list])
    my($self) = shift;
    my(@args) = @_;

    my($cmd) = $self->_cmd('commit -m ""');
    if(scalar(@args)==0) { # 'cvs commit -m ""'
        return $self->cvs_cmd($cmd);
    }
    elsif(@args==2) { # 'cvs commit -m "" -r TAG file(s)'
        croak "Syntax: commit([rev],[\@filelist])"
            unless (UNIVERSAL::isa($args[1], 'ARRAY'));
        my($pattern) = join '' => '-r %s ', _pattern($args[1]);
        $cmd .= sprintf($pattern, @args);
        return $self->cvs_cmd($cmd);
    }
    elsif(@args==1) { # 'cvs commit -m "" -r TAG' or 
                      # 'cvs commit -m "" file(s)'
        my($pattern);
        if(UNIVERSAL::isa($args[0], 'ARRAY')) {
            $pattern = sprintf(_pattern($args[0]), @{$args[0]});
        }
        else {
            $pattern = sprintf('-r %s', $args[0]);
        }

        $cmd .= $pattern;

        return $self->cvs_cmd($cmd);
    }
    else { # Anything else is an error
        croak "Syntax: commit([rev],[\@filelist])";
    }
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

    croak "Syntax: diff(file) or diff(tag1,tag2,file)"
        unless (@args && (scalar(@args)==1 || scalar(@args)==3));

    my($cmd) = $self->_cmd('diff');

    $cmd .=     @args==3    ?   sprintf("-r %s -r %s %s", @args)
                            :   sprintf("%s"            , @args);

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
=head1 NAME

Cvs::Simple - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Cvs::Simple;
    blah blah blah

=head1 DESCRIPTION

Stub documentation for Cvs::Simple, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Stephen Cardie, E<lt>stephenca@ls26.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Stephen Cardie

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
