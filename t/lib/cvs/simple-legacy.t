#!/usr/bin/env perl
use strict;
use warnings;

use Cvs::Simple;

use Directory::Scratch;

use Test::Most;


my $tmpdir = Directory::Scratch->new();

unshift(@INC,"$tmpdir/lib");

$tmpdir->touch( 'lib/Cvs/Simple/Config.pm', <<'CONFIG' );
package Cvs::Simple::Config;
use strict;
use warnings;

sub CVS_BIN  { '/tmp/foobar' }
sub EXTERNAL { 'LOCAL'  }

1;
CONFIG

my $cvs;
lives_ok { $cvs = Cvs::Simple->new(); }
'Call to new() ok.';

is(
    $cvs->cvs_bin(),
    '/tmp/foobar',
    'Find expected value for CVS_BIN' );

is( 
    $cvs->external(),
    'LOCAL',
    'Find expected value for EXTERNAL' );

done_testing;
