use 5;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Cvs::Simple',
    VERSION_FROM      => 'lib/Cvs/Simple.pm', # finds $VERSION
    PREREQ_PM => {
            'File::Copy' => 0,
            'Test::More' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Cvs/Simple.pm', # retrieve abstract from module
       AUTHOR         => 'Stephen Cardie <stephenca@ls26.net>') : ()),
);
