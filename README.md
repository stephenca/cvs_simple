# NAME

Cvs::Simple - Perl interface to cvs.

# VERSION

version 0.07\_04

# SYNOPSIS

    use Cvs::Simple;

    # Basic usage:
    chdir('/path/to/sandbox')
      or die "Failed to chdir to sandbox:$!";
    my($cvs) = Cvs::Simple->new();
    $cvs->add('file.txt');
    $cvs->commit();

    # Callback

    my($commit_callback);
    my($commit) = 0;
    {
      my($file) = 'file.txt';
      ($commit_callback) = sub {
        my($cmd,$arg) = @_;
        if($arg=~/Checking in $file;/) { ++$commit }
      };
    }
    my($cvs) = Cvs::Simple->new();
    $cvs->callback(commit => $commit_callback);
    $cvs->add('file.txt');
    $cvs->commit();
    croak "Failed to commit file.txt" unless($commit);
    $cvs->unset_callback('commit');

# DESCRIPTION

`Cvs::Simple` is an attempt to provide an easy-to-use wrapper that allows cvs
commands to be executed from within a Perl program, without the programmer having to
wade through the (many) cvs global and command-specific options.

The methods provided follow closely the recipes list in "Pragmatic Version
Control with CVS" by Dave Thomas and Andy Hunt (see
[http://www.pragmaticprogrammer.com/starter\_kit/vcc/index.html](http://www.pragmaticprogrammer.com/starter\_kit/vcc/index.html)).

## UTILITY METHODS

- new ( \[ CONFIG\_ITEMS \] )

Creates an instance of Cvs::Simple.

CONFIG\_ITEMS is a hash of configuration items.  Recognised configuration items are:

            - cvs\_bin
        - external
    - callback

See the method descriptions below for details of these.   If none are
specified, CVS::Simple will choose some sensible defaults.

- callback ( CMD, CODEREF )

Specify a function pointed to by CODEREF to be executed for every line output
by CMD.  

Permitted values of CMD are `All` (executed on every line of
output), `add`, `commit`, `checkout`, `diff`, `update`.  CMD is also
permitted to be undef, in which case, it will be assumed to be `All`.

cvs\_cmd passes two arguments to callbacks:  the actual command called, and the
line returned by CVS.

See the tests for examples of callbacks.

- unset\_callback ( CMD )

Remove the callback set for CMD.

- cvs\_bin ( PATH ) 

Specifies the location and name of the CVS binary.  Default to
`/usr/bin/cvs`.

- cvs\_cmd ( )

cvs\_cmd() does the actual work of calling the equivalent CVS command.  If any
callbacks have been set, they will be executed for every line received from
the command.  If no callbacks have been set, all output is to STDOUT.

- external( REPOSITORY )

Specify an "external" repository.  This can be a genuinely remote
repository in `:ext:user@repos.tld:/path/to/cvsroot` format, or an
alternative repository on the local host.  This will be passed to the `-d`
CVS global option.

## CVS METHODS 

- add     ( FILE1, \[ .... , FILEx \] )
- add\_bin ( FILE1, \[ .... , FILEx \] )

Add a file or files to the repository; equivalent to `cvs add file1, ....`,
or `cvs add -kb file1, ...` in the case of add\_bin().

- co ( TAG, MODULE )

    Alias for checkout()
- checkout ( MODULE )
- checkout ( TAG, MODULE )

    Note that co() can be used as an alias for checkout().
- ci

    Alias for commit().
- commit ( )
- commit ( FILELIST\_ARRAYREF )
- commit ( TAG )
- commit ( TAG, FILELIST\_ARRAYREF )

These are the equivalent of `cvs commit -m ""`, `cvs commit -m "" file1, file2, ...., fileN`, `cvs commit -r TAG -m ""` and `cvs commit -r TAG -m "" file1, file2, ....,
fileN` respectively.

Note that ci() can be used as an alias for commit().

- diff ( FILE\_OR\_DIR )
- diff ( TAG1, TAG2, FILE\_OR\_DIR )

FILE\_OR\_DIR is a single file, or a directory, in the sandbox.

Performs context diff: equivalent to `cvs diff -c FILE_OR_DIR` or `cvs
diff -c -rTAG1 -rTAG2 FILE_OR_DIR`.

- merge ( OLD\_REV, NEW\_REV, FILENAME )

This is the equivalent of `cvs -q update -jOLD_REV -jNEW_REV FILENAME`.  Note
for callback purposes that this is actually an update().

- backout ( CURRENT\_REV, REVERT\_REV, FILENAME )
- undo ( CURRENT\_REV, REVERT\_REV, FILENAME )

Reverts from CURRENT\_REV to REVERT\_REV.  Equivalent to `cvs update
-jCURRENT_REV -jREVERT_REV FILENAME`.

Note that backout() can be used as an alias for undo().

Note that for callback purposes this is actually an update().

- upd 

    Alias for update().
- update ( )
- update ( FILE1, \[ ...., FILEx \] );

Equivalent to `cvs -q update -d` and `cvs -d update file1, ..., filex`.

Note that updates to a specific revision (`-r`) and sticky-tag resets (`-A`) are not currently supported.

Note that upd() is an alias for update().

- up2date ( )

Short-hand for `cvs -nq update -d`.

- status ( )
- status( file1 \[, ..., ... \] )

Equivalent to `cvs status -v`.

## EXPORT

None by default.

# LIMITATIONS AND CAVEATS

- 1\. Note that `Cvs::Simple` carries out no input validation; everything is
passed on to CVS.  Similarly, the caller will receive no response on the
success (or otherwise) of the transaction, unless appropriate callbacks have
been set.
- 2\. The `cvs_cmd` method is quite simplistic; it's basically a pipe from
the equivalent CVS command line (with STDERR redirected).  If a more
sophisticated treatment, over-ride `cvs_cmd`, perhaps with something based on
`IPC::Run` (as the [Cvs](http://search.cpan.org/perldoc?Cvs) package does).
- 3\. This version of `Cvs::Simple` has been developed against cvs version
1.11.19.  Command syntax may differ in other versions of cvs, and
`Cvs::Simple` method calls may fail in unpredictable ways if other versions
are used.   Cross-version compatibiility is something I intend to address in a
future version.
- 4\. The `diff`, `merge`, and `undo` methods lack proper tests.  More
tests are required generally.

# SEE ALSO

cvs(1), [Cvs](http://search.cpan.org/perldoc?Cvs), [VCS::Cvs](http://search.cpan.org/perldoc?VCS::Cvs)

# AUTHOR

Stephen Cardie <stephenca@ls26.net>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Stephen Cardie.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
