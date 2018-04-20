use strict;
use warnings;

use lib 'inc';
use ExtUtils::MakeMaker::Dist::Zilla::Develop;

WriteMakefile(
    NAME => 'File::ShareDir::Install',
    ABSTRACT => 'Install shared files',
    VERSION_FROM => 'lib/File/ShareDir/Install.pm',
    INSTALLMAN1DIR => 'none',
    INSTALLMAN3DIR => 'none',
    NORECURS => 1,
);
