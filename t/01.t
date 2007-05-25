#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '../lib';

BEGIN {
    use_ok('Cvs::Simple');
    #require_ok("Simple.pm");
}

my($cvs) = Cvs::Simple->new();
isa_ok($cvs,'Cvs::Simple');

my(@methods) = qw(
	new
    callback
	add	
    add_bin
    checkout    co
    commit  ci
    diff
    external
    status
    update
    up2date
    _cmd
);

can_ok($cvs,@methods);

exit;

