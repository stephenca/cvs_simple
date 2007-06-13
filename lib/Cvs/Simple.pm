#!/usr/bin/perl
package Cvs::Simple;
use strict;
use warnings;
use Carp;
use FileHandle;

our $VERSION = 0.01;

my(%PERMITTED) = (
    'All'  => '',
    'add'  => '',
    'checkout'  => '',
    'co'  => '',
    'commit'  => '',
    'ci'  => '',
    'update'  => '',
    'diff'  => '',
    'status' => '',
);
sub PERM_REQ () {
    my($patt) = join '|' => keys %PERMITTED;
    return qr/$patt/;
}
my($PERM_REQ) = PERM_REQ;

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
    my($hook) = shift;
    my($func) = shift;

    # If 'hook' is not supplied, callback is global, i.e. apply to all.
    $hook ||= 'All';

    unless(exists $PERMITTED{$hook}) {
        croak "Invalid hook type in callback: $hook.";
    }

    if(defined($func)) {
        UNIVERSAL::isa(($func), 'CODE') or do {
            croak "Argument supplied to callback() should be a coderef.";
        };
        $self->{callback}{$hook} = $func;
    }

    if(exists $self->{callback}{$hook}) {
        return $self->{callback}{$hook};
    }
    else {
        return;
    }
}

sub unset_callback {
    my($self) = shift;
    my($hook) = shift;

    unless(exists $PERMITTED{$hook}) {
        croak "Invalid hook type in unset_callback: $hook.";
    }

    if(exists $self->{callback}{$hook}) {
        return delete $self->{callback}{$hook};
    }
    else {
        return;
    }
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

    my($hook);
    if(($cmd)=~/\b($PERM_REQ)\b/) {
        $hook = $1;
    }

    my($fh) = FileHandle->new("$cmd 2>&1 |");
    defined($fh) or croak "Failed to open $cmd:$!";

    while(<$fh>) {
        if(defined($hook)) {
            if($self->callback($hook)) {
                $self->callback($hook)->($cmd,$_);
            } 
        }
        else {
            if($self->callback('All')) {
                $self->callback('All')->($cmd, $_);
            }
            else {
                print STDOUT $_;
            }
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
        $cmd .= sprintf($pattern, $args[0], @{$args[1]});
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

    my($cmd) = $self->_cmd('diff -c');

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

Cvs::Simple - Perl interface to cvs

=head1 SYNOPSIS

  use Cvs::Simple;

  my($cvs) = Cvs::Simple->new();
  $cvs->add('file.txt');
  $cvs->commit();


=head1 DESCRIPTION

C<Cvs::Simple> is an attempt to provide an easy-to-use wrapper that allows cvs
commands to be executed from within a Perl program, without the programmer having to
wade through the (many) cvs global and command-specific options.

The methods provided follow closely the recipes list in "Pragmatic Version
Control with CVS" by Dave Thomas and Andy Hunt (see
http://www.pragmaticprogrammer.com/starter_kit/vcc/index.html).

=head2 UTILITY METHODS

=over 4

=item new ( [ CONFIG_ITEMS ] )

  Creates an instance of Cvs::Simple.

  CONFIG_ITEMS is a hash of configuration items.  Recognised configuration items are:

=over 8

=item * 
cvs_bin

=item * 
external

=item * 
callback

=back

See the method descriptions below for details of these.   If none are
specified, CVS::Simple will choose some sensible defaults.

=item callback ( )

=item unset_callback ( )

=item cvs_bin ( ) 

=item cvs_cmd ( )

=head2 CVS METHODS 

=item add ( FILE1, [ .... , FILEx ] )

=item add_bin ( FILE1, [ .... , FILEx ] )

Add a file or files to the repository; equivalent to C<cvs add file1, ....>,
or C<cvs add -kb file1, ...> in the case of add_bin().

=item checkout ( MODULE )

=item checkout ( TAG, MODULE )

  Note that co() can be used as an alias for checkout().

=item commit ( )

=item commit ( FILELIST_ARRAYREF )

=item commit ( TAG )

=item commit ( TAG, FILELIST_ARRAYREF )

Note that ci() can be used as an alias for commit().

=item diff ( FILE_OR_DIR )

=item diff ( TAG1, TAG2, FILE_OR_DIR )

FILE_OR_DIR is a single file, or a directory, in the sandbox.

Performs context diff: equivalent to C<cvs diff -c FILE_OR_DIR> or C<cvs
diff -c -rTAG1 -rTAG2 FILE_OR_DIR>.

=item merge ( OLD_REV, NEW_REV, FILENAME )

This is the equivalent of C<cvs update -jOLD_REV -jNEW_REV FILENAME>.

=item undo ( CURRENT_REV, REVERT_REV, FILENAME )

Note that backout() can be used as an alias for undo().

=item external

Specify an "external" repository.  This can be a genuinely remote
repository in C<:ext:user@repos.tld:/path/to/cvsroot> format, or an
alternative repository on the local host.  This will be passed to the C<-d>
CVS global option.

=item status 

  Not implemented yet: method is a stub.

=item upd ( )

=item update ( )

=item up2date ( )

Short-hand for 'cvs -nq update -d'.


=head2 EXPORT

None by default.

=head1 SEE ALSO

cvs(1)

=head1 AUTHOR

Stephen Cardie, E<lt>stephenca@ls26.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Stephen Cardie

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
