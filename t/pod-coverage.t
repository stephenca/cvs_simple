#!/usr/bin/perl -T
use strict;
use warnings;
use Test::More tests=>2;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => 
    "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
pod_coverage_ok('Cvs::Simple');
pod_coverage_ok('Cvs::Simple::Config');
#all_pod_coverage_ok();
#all_modules();

exit;
