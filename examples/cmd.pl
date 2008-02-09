#!/usr/bin/perl
use strict;
use warnings;
use Cvs::Simple;
use Cwd;
# Cvs_Test is included with the Cvs::Simple distribution.
# cvs_make inits a cvs repository, and cvs_clean removes it.
require Cvs_Test;

my($cwd) = getcwd;
Cvs_Test::cvs_make( $cwd ); 
my($cvs) = Cvs::Simple->new();
$cvs->add( 'testfile.txt' );
$cvs->commit();
#
# ...
#
$cvs->update();
$cvs->merge( 1.2, 1.3, 'testfile.txt' );
$cvs->commit();
$cvs->status();

Cvs_Test::cvs_clean();

exit;

__END__
