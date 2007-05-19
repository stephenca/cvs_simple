#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
require "Simple.pm";

my($cvsroot) = 'cvs';
my($cvs) = Cvs::Simple->new(cvsroot=>$cvsroot);

isa_ok($cvs,'Cvs::Simple');


