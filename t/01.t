#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);

BEGIN {
    use_ok('Cvs::Simple');
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
    status
    update
);

can_ok($cvs,@methods);

exit;

