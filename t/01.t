#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);

BEGIN {
    use_ok('Cvs::Simple');
    use_ok('Cvs::Simple::Config');
    use_ok('Cvs::Simple::Cmd');
}

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');

my(@methods) = qw(
    new
    backout
    callback
    add	
    add_bin
    checkout    co
    commit  ci
    cvs_bin
    cvs_cmd
    diff
    external
    merge
    status
    undo
    unset_callback
    update    upd
    up2date
    _cmd
);

can_ok($cvs,@methods);

exit;

