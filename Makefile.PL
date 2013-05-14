
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl interface to cvs.",
  "AUTHOR" => "Stephen Cardie <stephenca\@ls26.net>",
  "BUILD_REQUIRES" => {
    "Cwd" => 0,
    "Directory::Scratch" => 0,
    "File::Copy" => 0,
    "File::Find" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Cvs-Simple",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Cvs::Simple",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Class::Std::Utils" => 0,
    "File::Which" => 0,
    "IO::Lines" => 0,
    "IO::Pipe" => 0,
    "Module::Runtime" => 0,
    "Scalar::Util" => 0,
    "Try::Tiny" => 0,
    "common::sense" => 0
  },
  "VERSION" => "0.07_03",
  "test" => {
    "TESTS" => "t/*.t t/lib/cvs/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



